using Test
using Dyle
using Dyle.Language
using Dyle.Oracles

@testset "Oracle Interface Tests" begin
    # Create a default provider
    provider = DefaultOracleProvider()

    # Define test variables and functions
    @variable x::R()
    @func f(R(), R())

    # Test registering oracles through the provider
    f_eval = EvaluationOracle(x -> x^2)
    f_deriv = DerivativeOracle(x -> 2 * x)

    @test begin
        register_oracle(provider, :f, f_eval)
        register_oracle(provider, :f, f_deriv)
        true
    end

    # Test getting oracles
    retrieved_eval = get_oracle(provider, :f, EvaluationOracle)
    retrieved_deriv = get_oracle(provider, :f, DerivativeOracle)

    @test retrieved_eval == f_eval
    @test retrieved_deriv == f_deriv

    # Test has_oracle
    @test has_oracle(provider, :f, EvaluationOracle)
    @test has_oracle(provider, :f, DerivativeOracle)
    @test !has_oracle(provider, :f, ProximalOracle)

    # Test evaluating oracles
    test_point = 2.0
    @test retrieved_eval(test_point) ≈ test_point^2
    @test retrieved_deriv(test_point) ≈ 2 * test_point

    # Test get_oracle_for_expression with a simple expression
    expr = f(x)
    expr_eval = get_oracle_for_expression(provider, expr, EvaluationOracle)
    expr_deriv = get_oracle_for_expression(provider, expr, DerivativeOracle)

    @test expr_eval !== nothing
    @test expr_deriv !== nothing
    @test expr_eval(test_point) ≈ test_point^2
    @test expr_deriv(test_point) ≈ 2 * test_point

    # Test with more complex expressions
    @func g(R(), R())
    register_oracle(provider, :g, EvaluationOracle(x -> sin(x)))
    register_oracle(provider, :g, DerivativeOracle(x -> cos(x)))

    # Addition
    add_expr = f(x) + g(x)
    add_eval = get_oracle_for_expression(provider, add_expr, EvaluationOracle)
    add_deriv = get_oracle_for_expression(provider, add_expr, DerivativeOracle)

    @test add_eval !== nothing
    @test add_deriv !== nothing
    @test add_eval(test_point) ≈ test_point^2 + sin(test_point)
    @test add_deriv(test_point) ≈ 2 * test_point + cos(test_point)

    # Composition
    comp_expr = f(g(x))
    comp_eval = get_oracle_for_expression(provider, comp_expr, EvaluationOracle)
    comp_deriv = get_oracle_for_expression(provider, comp_expr, DerivativeOracle)

    @test comp_eval !== nothing
    @test comp_deriv !== nothing
    @test comp_eval(test_point) ≈ sin(test_point)^2
    @test comp_deriv(test_point) ≈ 2 * sin(test_point) * cos(test_point)

    # Test special combinations
    special_handler = expr -> x -> 42.0  # A dummy handler that always returns 42
    register_special_combination(
        provider,
        Addition,
        [:f, :g],
        ProximalOracle,
        special_handler,
    )

    @test has_special_combination(provider, Addition, [:f, :g], ProximalOracle)
    special_oracle = get_oracle_for_expression(provider, add_expr, ProximalOracle)
    @test special_oracle !== nothing
    @test special_oracle(test_point) == 42.0

    # Test clear_oracles
    clear_oracles(provider, :f)
    @test !has_oracle(provider, :f, EvaluationOracle)
    @test !has_oracle(provider, :f, DerivativeOracle)
    @test has_oracle(provider, :g, EvaluationOracle)  # g oracles should still exist
end
