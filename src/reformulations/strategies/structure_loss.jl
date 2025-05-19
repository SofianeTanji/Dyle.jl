raw"""
- **Structure Loss**
  Whenever your problem is built by composing or combining several simpler operations—e.g. sums, compositions, maxima—**pick operator nodes** in the expression tree and **collapse its children** into a single function \(h\).
  $$
    F(x) = \mathrm{Op}\bigl(f_1(x),f_2(x),\dots,f_k(x)\bigr)
    \;\longmapsto\;
    F(x) = h(x)
    \quad\text{where}\quad
    h(x) = \mathrm{Op}\bigl(f_1(x),\dots,f_k(x)\bigr).
  $$
"""
using ..Reformulations: Reformulation, create_reformulation
using ..Oracles:
    EvaluationOracle,
    DerivativeOracle,
    ProximalOracle,
    get_oracle_for_expression,
    register_oracle!
using ..Reformulations: register_strategy, Strategy, push_unique!, create_reformulation
using ..Properties: infer_properties
using ..Language:
    Expression,
    Addition,
    Subtraction,
    Maximum,
    Minimum,
    FunctionType,
    FunctionCall,
    Composition
using ..Properties: register_property!

# derive a base symbol from an expression or function call
function name_symbol(e)
    if e isa FunctionCall
        f = e.name
        return f isa FunctionType ? f.name : Symbol(string(f))
    elseif e isa FunctionType
        return e.name
    else
        return Symbol(string(e))
    end
end

struct StructureLossStrategy <: Strategy end

"""
    (s::StructureLossStrategy)(expr::Expression) -> Reformulation
Apply structure loss to the expression.
"""
function (s::StructureLossStrategy)(expr::Expression)::Vector{Reformulation}
    println(">>> structure_loss dispatch: expr=", expr, "   type=", typeof(expr))
    out = Reformulation[]
    seen = Set{String}()

    if expr isa Addition
        collapse_terms!(out, seen, expr, expr.terms)
    elseif expr isa Subtraction
        collapse_terms!(out, seen, expr, expr.terms)
    elseif expr isa Maximum
        collapse_terms!(out, seen, expr, expr.terms)
    elseif expr isa Minimum
        collapse_terms!(out, seen, expr, expr.terms)
    elseif expr isa Composition
        println("  saw a Composition, calling collapse_terms!")
        collapse_terms!(out, seen, expr)
    elseif expr isa FunctionCall
        println("  saw a FunctionCall, calling collapse_comp_call!")
        collapse_comp_call!(out, seen, expr)
    end
    # ensure the unmodified expression is included
    if !(string(expr) in seen)
        @show "  pushing original expression"
        push!(out, create_reformulation(expr))
    end
    return out
end

# --- HELPERS --- #

# Collapse any multi-term operator (Addition, Subtraction, Maximum, Minimum)
function collapse_terms!(
    out::Vector{Reformulation}, seen::Set{String}, expr, terms::Vector{Expression}
)
    # only support nonempty unary call structure
    isempty(terms) && return nothing
    first_term = terms[1]
    !(first_term isa FunctionCall) && return nothing
    args = first_term.args
    length(args) != 1 && return nothing

    # create a base symbol from the operator and child names
    names = [name_symbol(t) for t in terms]
    op = if expr isa Addition
        "+"
    elseif expr isa Subtraction
        "-"
    elseif expr isa Maximum
        "max"
    else
        "min"
    end
    base = Symbol(join(string.(names), op))
    # generate a unique helper symbol
    hsym = gensym(base)
    hfun = FunctionType(hsym, args[1].space, expr.space)
    # new collapsed call h(x)
    new_expr = hfun(args...)

    # infer and register properties on h
    for p in infer_properties(expr)
        register_property!(hsym, p)
    end
    # infer and register oracles on h
    for oracle_type in (EvaluationOracle, DerivativeOracle, ProximalOracle)
        o = get_oracle_for_expression(expr, oracle_type)
        if o !== nothing
            register_oracle!(hsym, o)
        end
    end
    # wrap into a reformulation only if unique
    # push_unique!(out, seen, new_expr)
    return push_unique!(out, seen, new_expr)
end

# helper to flatten nested Composition into list of outer functions
function flatten_comp(expr::Composition)::Vector{Expression}
    head, tail = expr.outer, expr.inner
    left = head isa Composition ? flatten_comp(head) : [head]
    right = tail isa Composition ? flatten_comp(tail) : [tail]
    return vcat(left, right)
end

# Collapse a composition node into all associative regroupings
function collapse_terms!(out::Vector{Reformulation}, seen::Set{String}, expr::Composition)
    funcs = flatten_comp(expr)
    N = length(funcs)
    N < 3 && return nothing  # need at least 3 for a nontrivial split

    # binary regroupings (f∘g)∘h, f∘(g∘h), etc.
    for i in 1:(N - 1)
        # build left composition of funcs[1:i]
        left = funcs[1]
        for j in 2:i
            left = Composition(left, funcs[j], expr.space)
        end
        # build right composition of funcs[(i+1):N]
        right = funcs[i + 1]
        for j in (i + 2):N
            right = Composition(right, funcs[j], expr.space)
        end
        new_expr = Composition(left, right, expr.space)
        push_unique!(out, seen, new_expr)
    end
    # full-collapse: collapse entire chain into one helper function
    # only if all are FunctionTypes
    if all(f -> f isa FunctionType, funcs)
        dom = funcs[end].domain
        cod = expr.space
        names = [name_symbol(f) for f in funcs]
        base = Symbol(join(string.(names), "∘"))
        hsym = gensym(base)
        hfun = FunctionType(hsym, dom, cod)
        # register properties and oracles on helper
        for p in infer_properties(expr)
            register_property!(hsym, p)
        end
        for oracle_type in (EvaluationOracle, DerivativeOracle, ProximalOracle)
            o = get_oracle_for_expression(expr, oracle_type)
            if o !== nothing
                register_oracle!(hsym, o)
            end
        end
        push_unique!(out, seen, hfun)
    end
end

# new helper to split and collapse a composition inside a function call
function collapse_comp_call!(
    out::Vector{Reformulation}, seen::Set{String}, expr::FunctionCall
)
    comp = expr.name
    args = expr.args
    # only handle pure compositions
    if comp isa Composition
        funcs = flatten_comp(comp)
        N = length(funcs)
        # binary regroupings
        for i in 1:(N - 1)
            left = funcs[1]
            for j in 2:i
                left = Composition(left, funcs[j], comp.space)
            end
            right = funcs[i + 1]
            for j in (i + 2):N
                right = Composition(right, funcs[j], comp.space)
            end
            new_name = Composition(left, right, comp.space)
            # Composition name needs explicit space
            new_call = FunctionCall(new_name, args, new_name.space)
            push_unique!(out, seen, new_call)
        end
        # full collapse into one helper
        if all(f -> f isa FunctionType, funcs)
            dom = funcs[end].domain
            cod = comp.space
            names = [name_symbol(f) for f in funcs]
            base = Symbol(join(string.(names), "∘"))
            hsym = gensym(base)
            hfun = FunctionType(hsym, dom, cod)
            # register properties and oracles on the helper
            for p in infer_properties(comp)
                register_property!(hsym, p)
            end
            for oracle_type in (EvaluationOracle, DerivativeOracle, ProximalOracle)
                o = get_oracle_for_expression(comp, oracle_type)
                if o !== nothing
                    register_oracle!(hsym, o)
                end
            end
            # FunctionType name uses its codomain constructor
            new_call = FunctionCall(hfun, args)
            push_unique!(out, seen, new_call)
        end

        # per-node collapse into individual helpers then re-compose
        helpers = Vector{Expression}(undef, N)
        for (idx, f) in enumerate(funcs)
            if f isa FunctionType
                base = name_symbol(f)
                hsym = gensym(base)
                hfun = FunctionType(hsym, f.domain, f.codomain)
                for p in infer_properties(f)
                    register_property!(hsym, p)
                end
                for oracle_type in (EvaluationOracle, DerivativeOracle, ProximalOracle)
                    o = get_oracle_for_expression(f, oracle_type)
                    if o !== nothing
                        register_oracle!(hsym, o)
                    end
                end
                helpers[idx] = hfun
            else
                helpers[idx] = f
            end
        end
        # re-compose helpers
        comp_help = helpers[1]
        for k in 2:length(helpers)
            comp_help = Composition(comp_help, helpers[k], comp.space)
        end
        # Composition helper needs explicit space
        new_call = FunctionCall(comp_help, args, comp_help.space)
        push_unique!(out, seen, new_call)
    end
end

register_strategy(:structure_loss, StructureLossStrategy())