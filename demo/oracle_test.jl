using Dyle
using Dyle.Language
using Dyle.Properties
using Dyle.Oracles
using Test

@testset "Oracle Module Validation Tests" begin
    # Define spaces and variables for testing
    @variable x::R()

    @testset "Basic Oracle Registration and Retrieval" begin
        @func f(R(), R())
        @oracle f EvaluationOracle(x -> x^2)

        # Test oracle retrieval
        f_oracle = get_oracle(:f, EvaluationOracle())
        @test f_oracle !== nothing
        @test f_oracle(3.0) ≈ 9.0
    end

    @testset "Inexact Oracle Handling" begin
        @func g(R(), R())
        # Register an inexact oracle
        @oracle g DerivativeOracle(Inexact(AbsoluteError(0.1)))(x -> 2 * x)

        # Test oracle retrieval
        g_oracle = get_oracle(:g, DerivativeOracle(Inexact(AbsoluteError(0.1))))
        @test g_oracle !== nothing
        @test g_oracle(3.0) ≈ 6.0

        # Test metadata retrieval
        metadata = get_oracle_metadata(:g, DerivativeOracle)
        @test metadata !== nothing
        @test metadata.exactness isa Inexact
        @test error_bound(metadata.exactness) ≈ 0.1
    end

    @testset "Cost Model and Metadata" begin
        @func h(R(), R())
        # Register with cost model
        @oracle h EvaluationOracle(x -> x^3) linear_cost(:n)

        # Test metadata retrieval
        metadata = get_oracle_metadata(:h, EvaluationOracle)
        @test metadata !== nothing
        @test metadata.cost !== nothing
        @test evaluate_cost(metadata.cost, Dict(:n => 10)) ≈ 10.0
    end

    @testset "Expression Combination - Addition" begin
        @func add1(R(), R())
        @func add2(R(), R())

        @oracle add1 EvaluationOracle(x -> x^2)
        @oracle add2 EvaluationOracle(x -> 2 * x)

        # Create addition expression
        expr_add = add1(x) + add2(x)

        # Test oracle combination
        combined_oracle = get_oracle_for_expression(expr_add, EvaluationOracle())
        @test combined_oracle !== nothing
        @test combined_oracle(3.0) ≈ (3.0^2 + 2 * 3.0)
    end

    @testset "Expression Combination - Composition" begin
        @func outer(R(), R())
        @func inner(R(), R())

        @oracle outer EvaluationOracle(x -> x^2)
        @oracle inner EvaluationOracle(x -> x + 1)

        # Create composition expression
        expr_comp = outer(inner(x))

        # Test oracle combination
        combined_oracle = get_oracle_for_expression(expr_comp, EvaluationOracle())
        @test combined_oracle !== nothing
        @test combined_oracle(3.0) ≈ ((3.0 + 1)^2)
    end

    @testset "Complex Expression" begin
        @func term1(R(), R())
        @func term2(R(), R())
        @func term3(R(), R())

        @oracle term1 EvaluationOracle(x -> x^2)
        @oracle term2 EvaluationOracle(x -> 2 * x)
        @oracle term3 EvaluationOracle(x -> x + 1)

        # Create complex expression: term1(x) + term2(term3(x))
        expr_complex = term1(x) + term2(term3(x))

        # Test oracle combination
        combined_oracle = get_oracle_for_expression(expr_complex, EvaluationOracle())
        @test combined_oracle !== nothing
        @test combined_oracle(3.0) ≈ (3.0^2 + 2 * (3.0 + 1))
    end

    @testset "Special Combinations" begin
        # Register a special combination
        dummy_handler = expr -> (x -> 42.0)
        Dyle.Oracles.register_special_combination(
            Addition,
            [:special1, :special2],
            EvaluationOracle,
            dummy_handler,
        )

        @func special1(R(), R())
        @func special2(R(), R())

        @oracle special1 EvaluationOracle(x -> x)
        @oracle special2 EvaluationOracle(x -> 2 * x)

        # Create expression that should match the special combination
        expr_special = special1(x) + special2(x)

        # Test special combination
        special_oracle = get_oracle_for_expression(expr_special, EvaluationOracle())
        @test special_oracle !== nothing
        @test special_oracle(3.0) ≈ 42.0
    end
end

println("All Oracle module tests complete!")
