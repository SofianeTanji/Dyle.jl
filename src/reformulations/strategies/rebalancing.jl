using ..Reformulations: Reformulation, create_reformulation
using ..Language: Expression, Addition, Composition
using ..Reformulations: register_strategy, Strategy

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

# ————— Helpers —————

# Flatten nested additions
function flatten_terms(add::Addition)
    out = Expression[]
    for t in add.terms
        if t isa Addition
            append!(out, flatten_terms(t))
        else
            push!(out, t)
        end
    end
    return out
end

# Wrap a block of terms back into Addition or keep single term
wrap(terms::Vector{Expression}, space) =
    length(terms) == 1 ? terms[1] : Addition(terms, space)

# Rebalance addition by generating all binary regroupings
function rebalance_addition(add::Addition)
    # flatten nested additions
    flat = flatten_terms(add)
    n = length(flat)

    # Only proceed if we have more than 1 term
    if n <= 1
        return Reformulation[]
    end

    # generate all binary regroupings
    out = Reformulation[]
    for i = 1:(n-1)
        A = wrap(flat[1:i], add.space)
        B = wrap(flat[(i+1):n], add.space)

        # Create a new Addition with properly typed array
        new_terms = Expression[A, B]
        new = Addition(new_terms, add.space)

        # Create a reformulation and add it if it's unique
        reformulation = create_reformulation(new)
        if !any(r -> r.expr == reformulation.expr, out)
            push!(out, reformulation)
        end
    end

    return out
end

# Rebalance composition in both associativity directions
function rebalance_composition(comp::Composition)
    out = Reformulation[]
    # f ∘ (g ∘ h) → (f ∘ g) ∘ h
    if comp.inner isa Composition
        g, h = comp.inner.outer, comp.inner.inner
        fg = Composition(comp.outer, g, comp.space)
        push!(out, create_reformulation(Composition(fg, h, comp.space)))
    end
    # (f ∘ g) ∘ h → f ∘ (g ∘ h)
    if comp.outer isa Composition
        f, g = comp.outer.outer, comp.outer.inner
        gh = Composition(g, comp.inner, comp.space)
        push!(out, create_reformulation(Composition(f, gh, comp.space)))
    end
    return out
end

# Register the strategy
register_strategy(:rebalancing, RebalancingStrategy())
