"""
    simplification(expr::Expression) -> Reformulation

Returns a `Reformulation` holding:
  • `expr` itself
  • `properties = infer_properties(expr)`
  • `oracles = Dict(OracleType => oracle_function, …)`
"""
function structure_loss(expr::Expression)
    props = infer_properties(expr)
    ods = Dict{DataType,Any}()
    for oracle_t in (EvaluationOracle, DerivativeOracle, ProximalOracle)
        f = get_oracle_for_expression(expr, oracle_t)
        f !== nothing && (ods[oracle_t] = f)
    end
    return Reformulation(expr, props, ods)
end
