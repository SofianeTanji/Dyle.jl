"""
Oracle type definitions.
This file defines the concrete oracle types that represent different computational capabilities.
"""

import Base: ==, hash

"""
Abstract type for all oracles in the system.
"""
abstract type Oracle end

"""
    EvaluationOracle <: Oracle

Oracle for computing function values: f(x).
"""
struct EvaluationOracle <: Oracle
    implementation::Function
    metadata::OracleMetadata

    # Default constructor for exact oracle
    EvaluationOracle(implementation::Function) =
        new(implementation, OracleMetadata(exactness = Exact()))

    # Constructor with exactness
    EvaluationOracle(implementation::Function, exactness::Exactness) =
        new(implementation, OracleMetadata(exactness = exactness))

    # Constructor with metadata
    EvaluationOracle(implementation::Function, metadata::OracleMetadata) =
        new(implementation, metadata)
end

"""
    DerivativeOracle <: Oracle

Oracle for computing derivatives: ∇f(x).
"""
struct DerivativeOracle <: Oracle
    implementation::Function
    metadata::OracleMetadata

    # Default constructor for exact oracle
    DerivativeOracle(implementation::Function) =
        new(implementation, OracleMetadata(exactness = Exact()))

    # Constructor with exactness
    DerivativeOracle(implementation::Function, exactness::Exactness) =
        new(implementation, OracleMetadata(exactness = exactness))

    # Constructor with metadata
    DerivativeOracle(implementation::Function, metadata::OracleMetadata) =
        new(implementation, metadata)
end

"""
    ProximalOracle <: Oracle

Oracle for computing proximal operators: prox_λf(x) = argmin_y { f(y) + (1/2λ)‖y-x‖² }.
"""
struct ProximalOracle <: Oracle
    implementation::Function
    metadata::OracleMetadata

    # Default constructor for exact oracle
    ProximalOracle(implementation::Function) =
        new(implementation, OracleMetadata(exactness = Exact()))

    # Constructor with exactness
    ProximalOracle(implementation::Function, exactness::Exactness) =
        new(implementation, OracleMetadata(exactness = exactness))

    # Constructor with metadata
    ProximalOracle(implementation::Function, metadata::OracleMetadata) =
        new(implementation, metadata)
end

# Callable interface for oracles
(oracle::Oracle)(args...) = oracle.implementation(args...)


==(o1::EvaluationOracle, o2::EvaluationOracle) =
    o1.metadata.exactness == o2.metadata.exactness
hash(o::EvaluationOracle, h::UInt) = hash(o.metadata.exactness, h)

# Do similarly for DerivativeOracle and ProximalOracle:
==(o1::DerivativeOracle, o2::DerivativeOracle) =
    o1.metadata.exactness == o2.metadata.exactness
hash(o::DerivativeOracle, h::UInt) = hash(o.metadata.exactness, h)

==(o1::ProximalOracle, o2::ProximalOracle) = o1.metadata.exactness == o2.metadata.exactness
hash(o::ProximalOracle, h::UInt) = hash(o.metadata.exactness, h)
