using ..Reformulations: Reformulation, create_reformulation
using ..Language: Expression, Addition, Maximum, Minimum
using ..Reformulations: register_strategy, Strategy, push_unique!

"""
    CommutativityStrategy <: Strategy

Generate permutations of commutative operations like Addition, Maximum, and Minimum.
"""
struct CommutativityStrategy <: Strategy end

"""
    (s::CommutativityStrategy)(expr::Expression) -> Vector{Reformulation}

Apply commutativity to appropriate expression types.
"""
function (s::CommutativityStrategy)(expr::Expression)
    if expr isa Addition
        return commute_addition(expr)
    elseif expr isa Maximum
        return commute_maximum(expr)
    elseif expr isa Minimum
        return commute_minimum(expr)
    else
        return Reformulation[]
    end
end

# ————— Helpers —————

"""
    commute_addition(add::Addition) -> Vector{Reformulation}

Generate unique permutations of terms in an addition.
Recursively handles nested additions.
"""
function commute_addition(add::Addition)
    out = Reformulation[]
    seen = Set{String}()

    # Include the original expression
    push_unique!(out, seen, add)

    # If there's <= 1 term, nothing to commute
    n = length(add.terms)
    if n <= 1
        return out
    end

    # Generate adjacent swaps to create new permutations
    for i = 1:(n-1)
        # Create a new vector with i and i+1 swapped
        swapped_terms = copy(add.terms)
        swapped_terms[i], swapped_terms[i+1] = swapped_terms[i+1], swapped_terms[i]
        swapped = Addition(swapped_terms, add.space)
        push_unique!(out, seen, swapped)
    end

    # Recursively apply commutativity to nested additions
    for (i, term) in enumerate(add.terms)
        if term isa Addition
            # Get commutations of the nested addition
            for sub_commute in commute_addition(term)
                # Replace the nested term with each commutation
                new_terms = copy(add.terms)
                new_terms[i] = sub_commute.expr
                nested_commute = Addition(new_terms, add.space)
                push_unique!(out, seen, nested_commute)
            end
        end
    end

    return out
end

"""
    commute_maximum(maxi::Maximum) -> Vector{Reformulation}

Generate unique permutations of terms in a maximum expression.
"""
function commute_maximum(maxi::Maximum)
    out = Reformulation[]
    seen = Set{String}()

    # Include the original expression
    push_unique!(out, seen, maxi)

    # If there's <= 1 term, nothing to commute
    n = length(maxi.terms)
    if n <= 1
        return out
    end

    # Generate adjacent swaps for new permutations
    for i = 1:(n-1)
        swapped_terms = copy(maxi.terms)
        swapped_terms[i], swapped_terms[i+1] = swapped_terms[i+1], swapped_terms[i]
        swapped = Maximum(swapped_terms, maxi.space)
        push_unique!(out, seen, swapped)
    end

    # Recursively apply commutativity to nested maxima
    for (i, term) in enumerate(maxi.terms)
        if term isa Maximum
            for sub_commute in commute_maximum(term)
                new_terms = copy(maxi.terms)
                new_terms[i] = sub_commute.expr
                nested_commute = Maximum(new_terms, maxi.space)
                push_unique!(out, seen, nested_commute)
            end
        end
    end

    return out
end

"""
    commute_minimum(mini::Minimum) -> Vector{Reformulation}

Generate unique permutations of terms in a minimum expression.
"""
function commute_minimum(mini::Minimum)
    out = Reformulation[]
    seen = Set{String}()

    # Include the original expression
    push_unique!(out, seen, mini)

    # If there's <= 1 term, nothing to commute
    n = length(mini.terms)
    if n <= 1
        return out
    end

    # Generate adjacent swaps for new permutations
    for i = 1:(n-1)
        swapped_terms = copy(mini.terms)
        swapped_terms[i], swapped_terms[i+1] = swapped_terms[i+1], swapped_terms[i]
        swapped = Minimum(swapped_terms, mini.space)
        push_unique!(out, seen, swapped)
    end

    # Recursively apply commutativity to nested minima
    for (i, term) in enumerate(mini.terms)
        if term isa Minimum
            for sub_commute in commute_minimum(term)
                new_terms = copy(mini.terms)
                new_terms[i] = sub_commute.expr
                nested_commute = Minimum(new_terms, mini.space)
                push_unique!(out, seen, nested_commute)
            end
        end
    end

    return out
end

# Register the strategy
register_strategy(:commutativity, CommutativityStrategy())
