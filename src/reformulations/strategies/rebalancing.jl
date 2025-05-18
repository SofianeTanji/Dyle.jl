using ..Reformulations: Reformulation, create_reformulation
using ..Language: Expression, Addition, Composition
using ..Reformulations: register_strategy, Strategy, push_unique!

"""
    RebalancingStrategy <: Strategy

Explore all associative regroupings for Addition and Composition.
"""
struct RebalancingStrategy <: Strategy end

"""
    (s::RebalancingStrategy)(expr::Expression) -> Vector{Reformulation}

Dispatch to addition or composition rebalancing.
"""
function (s::RebalancingStrategy)(expr::Expression)
    if expr isa Addition
        return rebalance_addition(expr)
    elseif expr isa Composition
        return rebalance_composition(expr)
    else
        return Reformulation[]
    end
end

function (s::RebalancingStrategy)(fc::FunctionCall)
    # only act if the “function” is itself a Composition
    if fc.name isa Composition
        # get all the associative flips on that inner Composition
        comps = rebalance_composition(fc.name)
        # reattach the same argument list + space to each
        return [create_reformulation(FunctionCall(c, fc.args, fc.space)) for c in comps]
    else
        return Reformulation[]
    end
end

# ————— Helpers —————

"""
    flatten_terms(add::Addition) -> Vector{Expression}

Recursively flatten nested additions into a single vector of terms.
"""
function flatten_terms(add::Addition)
    terms = Expression[]
    for t in add.terms
        if t isa Addition
            append!(terms, flatten_terms(t))
        else
            push!(terms, t)
        end
    end
    return terms
end

"""
    wrap_one(terms::Vector{Expression}, space) -> Expression

Wrap one or more terms into an Addition expression if needed.
"""
function wrap_one(terms::Vector{Expression}, space)
    return length(terms) == 1 ? terms[1] : Addition(terms, space)
end

"""
    rebalance_addition(add::Addition) -> Vector{Reformulation}

Generate all possible regroupings of an addition expression.
"""
function rebalance_addition(add::Addition)
    # Flatten nested additions first
    flat = flatten_terms(add)
    n = length(flat)

    # Nothing to rebalance if fewer than 3 terms
    if n < 3
        return Reformulation[]
    end

    out = Reformulation[]
    seen = Set{String}()

    # Generate the fully flattened version first
    flat_expr = Addition(flat, add.space)
    push_unique!(out, seen, flat_expr)

    # Generate all possible binary regroupings
    for i in 1:(n - 1)
        # Left grouping: (terms[1:i]) + (terms[i+1:end])
        left = wrap_one(flat[1:i], add.space)
        right = wrap_one(flat[(i + 1):n], add.space)
        binary_expr = Addition([left, right], add.space)
        push_unique!(out, seen, binary_expr)
    end

    return out
end

"""
    rebalance_composition(comp::Composition) -> Vector{Reformulation}

Rebalance composition according to associativity: f ∘ (g ∘ h) ⟷ (f ∘ g) ∘ h
"""
function rebalance_composition(comp::Composition)
    out = Reformulation[]
    seen = Set{String}()
    @show "Got inside rebalance_composition"
    # f ∘ (g ∘ h) → (f ∘ g) ∘ h
    if comp.inner isa Composition
        @show "Got inside if comp.inner isa Composition"
        g, h = comp.inner.outer, comp.inner.inner
        fg = Composition(comp.outer, g, comp.space)
        fg_h = Composition(fg, h, comp.space)
        push_unique!(out, seen, fg_h)
    end

    # (f ∘ g) ∘ h → f ∘ (g ∘ h)
    if comp.outer isa Composition
        @show "Got inside if comp.outer isa Composition"
        f, g = comp.outer.outer, comp.outer.inner
        gh = Composition(g, comp.inner, comp.space)
        f_gh = Composition(f, gh, comp.space)
        push_unique!(out, seen, f_gh)
    end

    return out
end

# Register the strategy
register_strategy(:rebalancing, RebalancingStrategy())
