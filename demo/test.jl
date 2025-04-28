using Dyle
using Dyle.Language
using Dyle.Properties
using Test

Rns = Rn(:n)

@variable x::R()
@variable y::R()
@variable v::Rns

@func f(R(), R())
@func g(Rns, R())
@func h(R(), R())
@func linear_func(R(), R())
@func linear_func2(R(), R())

# Create expressions
expr1 = f(x) + f(x)
expr2 = g(v)
expr3 = f(x) + g(v)

# Register properties for functions
@property f StronglyConvex(1.0) Smooth(2.0)
@property g Convex() Lipschitz(5.0)
@property h Linear(1.0, 3.0)
@property linear_func Linear(1.0, 2.0)
@property linear_func2 Linear(0.5, 1.5)

# Test basic property retrieval
f_props = get_properties(:f)
g_props = get_properties(:g)
h_props = get_properties(:h)

# Test inference for addition expressions
expr1_props = infer_properties(expr1)
expr2_props = infer_properties(expr2)
expr3_props = infer_properties(expr3)

# Test quadratic properties
@func quad1(R(), R())
@func quad2(R(), R())
@property quad1 Quadratic(1.0, 2.0)
@property quad2 Quadratic(0.5, 1.5)

quad_sum = quad1(x) + quad2(x)
quad_sum_props = infer_properties(quad_sum)

expr4 = f(x) + quad1(x) + quad2(x) # (Strongly Convex + Smooth) + Quadratic + Quadratic
expr4_props = infer_properties(expr4)

expr5 = f(x) - f(x)
expr5_props = infer_properties(expr5)

# ==================
# COMPOSITION TESTS
# ==================
println("\n--- Testing Composition Rules ---")

# Test 1: Convex ∘ Linear -> Convex
@func convex_func(R(), R())
@property convex_func Convex()
comp1 = convex_func(h(x))
comp1_props = infer_properties(comp1)
println("Convex ∘ Linear -> Properties: ", comp1_props)
@test any(p isa Convex for p in comp1_props)

# Test 2: StronglyConvex ∘ Linear -> StronglyConvex (when λₘᵢₙ > 0)
comp2 = f(h(x))  # StronglyConvex(1.0) ∘ Linear(1.0, 3.0)
comp2_props = infer_properties(comp2)
println("StronglyConvex ∘ Linear -> Properties: ", comp2_props)
@test any(p isa StronglyConvex for p in comp2_props)

# Test 3: HypoConvex ∘ Linear
@func hypo_func(R(), R())
@property hypo_func HypoConvex(1.5)
comp3 = hypo_func(h(x))
comp3_props = infer_properties(comp3)
println("HypoConvex ∘ Linear -> Properties: ", comp3_props)
@test any(p isa HypoConvex for p in comp3_props)

# Test 4: Smooth ∘ Lipschitz
@func lipschitz_func(R(), R())
@property lipschitz_func Lipschitz(3.0)
comp4 = f(lipschitz_func(x))  # Smooth(2.0) ∘ Lipschitz(3.0)
comp4_props = infer_properties(comp4)
println("Smooth ∘ Lipschitz -> Properties: ", comp4_props)
@test any(p isa Smooth for p in comp4_props)

# Test 5: Lipschitz ∘ Lipschitz
comp5 = lipschitz_func(lipschitz_func(x))  # Lipschitz(3.0) ∘ Lipschitz(3.0)
comp5_props = infer_properties(comp5)
println("Lipschitz ∘ Lipschitz -> Properties: ", comp5_props)
@test any(p isa Lipschitz for p in comp5_props)

# Test 6: Linear ∘ Linear
comp6 = linear_func(linear_func2(x))  # Linear(1.0,2.0) ∘ Linear(0.5,1.5)
comp6_props = infer_properties(comp6)
println("Linear ∘ Linear -> Properties: ", comp6_props)
@test any(p isa Linear for p in comp6_props)

# Test 7: Special case - Monotonically increasing convex ∘ convex = convex
@func mono_convex_func(R(), R())
@property mono_convex_func Convex() MonotonicallyIncreasing()
comp7 = mono_convex_func(convex_func(x))
comp7_props = infer_properties(comp7)
println("MonotonicallyIncreasing Convex ∘ Convex -> Properties: ", comp7_props)
# Check if this special case is correctly implemented
@test any(p isa Convex for p in comp7_props)

println("\nComposition tests completed.")
