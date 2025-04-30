using Dyle
using Dyle.Language
using Dyle.Properties
using Dyle.Oracles
using Dyle.Reformulations
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

reforms = generate_reformulations(f(x) + g(v) + f(x))

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

println("==== Testing Oracle Module ====")

# Define spaces and variables
@variable x::R()
@variable y::R()

# Define functions
@func f g h

# Register oracles for functions
println("\n1. Registering oracles for functions")
@oracle f EvaluationOracle(x -> x^2)
@oracle f DerivativeOracle(x -> 2 * x)
println("  Registered oracles for f(x) = x^2")

@oracle g EvaluationOracle(x -> sin(x))
@oracle g DerivativeOracle(x -> cos(x))
println("  Registered oracles for g(x) = sin(x)")

@oracle h EvaluationOracle(x -> exp(x))
@oracle h DerivativeOracle(x -> exp(x))
println("  Registered oracles for h(x) = exp(x)")

# Test individual oracles
println("\n2. Testing individual oracles")
f_eval = get_oracle(:f, EvaluationOracle)
f_deriv = get_oracle(:f, DerivativeOracle)

test_point = 2.0
println("  f($test_point) = $(f_eval(test_point))")
println("  f'($test_point) = $(f_deriv(test_point))")

@test f_eval(test_point) ≈ test_point^2
@test f_deriv(test_point) ≈ 2 * test_point

# Create composite expressions
println("\n3. Testing oracle combinations for composite expressions")

# Addition
println("\n3.1 Addition: f(x) + g(x)")
expr_add = f(x) + g(x)   # x^2 + sin(x)
expr_add_eval = get_oracle_for_expression(expr_add, EvaluationOracle)
expr_add_deriv = get_oracle_for_expression(expr_add, DerivativeOracle)

if expr_add_eval !== nothing && expr_add_deriv !== nothing
    println("  (f + g)($test_point) = $(expr_add_eval(test_point))")
    println("  (f + g)'($test_point) = $(expr_add_deriv(test_point))")

    @test expr_add_eval(test_point) ≈
          f_eval(test_point) + get_oracle(:g, EvaluationOracle)(test_point)
    @test expr_add_deriv(test_point) ≈
          f_deriv(test_point) + get_oracle(:g, DerivativeOracle)(test_point)
    println("  ✓ Addition oracles combined correctly")
else
    println("  ✗ Failed to combine addition oracles")
end

# Composition
println("\n3.2 Composition: f(g(x))")
expr_comp = f(g(x))       # (sin(x))^2

expr_comp_eval = get_oracle_for_expression(expr_comp, EvaluationOracle)
expr_comp_deriv = get_oracle_for_expression(expr_comp, DerivativeOracle)

if expr_comp_eval !== nothing && expr_comp_deriv !== nothing
    println("  (f ∘ g)($test_point) = $(expr_comp_eval(test_point))")
    println("  (f ∘ g)'($test_point) = $(expr_comp_deriv(test_point))")

    g_x = get_oracle(:g, EvaluationOracle)(test_point)
    expected_comp_eval = f_eval(g_x)
    expected_comp_deriv = f_deriv(g_x) * get_oracle(:g, DerivativeOracle)(test_point)

    @test expr_comp_eval(test_point) ≈ expected_comp_eval
    @test expr_comp_deriv(test_point) ≈ expected_comp_deriv
    println("  ✓ Composition oracles combined correctly")
else
    println("  ✗ Failed to combine composition oracles")
end

# Testing proxy and special combinations
println("\n4. Testing proximal oracle and special combinations")

# Try a proximal oracle (which we haven't defined)
has_proximal = get_oracle_for_expression(expr_add, ProximalOracle) !== nothing
println("  Has proximal oracle for addition: $has_proximal")
@test has_proximal == false

# Register a simple special combination for demonstration
println("\n5. Testing special combination registration")
special_handler = expr -> x -> 42.0  # A dummy handler that always returns 42
register_special_combination(Addition, [:f, :g], ProximalOracle, special_handler)

# Check if the special combination is registered
has_special = has_special_combination(Addition, [:f, :g], ProximalOracle)
println("  Special combination registered: $has_special")
@test has_special == true

# Try to get the special combination
special_handler_retrieved = get_special_combination(Addition, [:f, :g], ProximalOracle)
println("  Special handler is callable: $(special_handler_retrieved !== nothing)")
@test special_handler_retrieved !== nothing

# Create the specific expression that should match our special case
special_expr = f(x) + g(x)
special_oracle = get_oracle_for_expression(special_expr, ProximalOracle)

if special_oracle !== nothing
    result = special_oracle(test_point)
    println("  Special oracle result: $result")
    @test result == 42.0
    println("  ✓ Special combination works correctly")
else
    println("  ✗ Failed to get special oracle")
end

println("\n==== Oracle Module Tests Completed ====")
