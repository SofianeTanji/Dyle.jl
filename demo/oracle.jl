println("\n==== Testing Oracle Module ====")

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

println("  (f + g)($test_point) = $(expr_add_eval(test_point))")
println("  (f + g)'($test_point) = $(expr_add_deriv(test_point))")

@test expr_add_eval(test_point) ≈
      f_eval(test_point) + get_oracle(:g, EvaluationOracle)(test_point)
@test expr_add_deriv(test_point) ≈
      f_deriv(test_point) + get_oracle(:g, DerivativeOracle)(test_point)
println("  ✓ Addition oracles combined correctly")

# Composition
println("\n3.2 Composition: f(g(x))")
expr_comp = f(g(x))       # (sin(x))^2
expr_comp_eval = get_oracle_for_expression(expr_comp, EvaluationOracle)
expr_comp_deriv = get_oracle_for_expression(expr_comp, DerivativeOracle)

println("  (f ∘ g)($test_point) = $(expr_comp_eval(test_point))")
println("  (f ∘ g)'($test_point) = $(expr_comp_deriv(test_point))")

g_x = get_oracle(:g, EvaluationOracle)(test_point)
expected_comp_eval = f_eval(g_x)
expected_comp_deriv = f_deriv(g_x) * get_oracle(:g, DerivativeOracle)(test_point)

@test expr_comp_eval(test_point) ≈ expected_comp_eval
@test expr_comp_deriv(test_point) ≈ expected_comp_deriv
println("  ✓ Composition oracles combined correctly")

# Complex expression
println("\n3.3 Complex expression: f(x) + h(g(x))")
expr_complex = f(x) + h(g(x))  # x^2 + exp(sin(x))
expr_complex_eval = get_oracle_for_expression(expr_complex, EvaluationOracle)

println("  (f + h∘g)($test_point) = $(expr_complex_eval(test_point))")
expected_complex_eval = f_eval(test_point) + get_oracle(:h, EvaluationOracle)(g_x)
@test expr_complex_eval(test_point) ≈ expected_complex_eval
println("  ✓ Complex expression oracle combined correctly")

println("\n==== Oracle Module Tests Completed ====")
