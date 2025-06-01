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
    function EvaluationOracle(implementation::Function)
        return new(implementation, OracleMetadata(; exactness=Exact()))
    end

    # Constructor with exactness
    function EvaluationOracle(implementation::Function, exactness::Exactness)
        return new(implementation, OracleMetadata(; exactness=exactness))
    end

    # Constructor with metadata
    function EvaluationOracle(implementation::Function, metadata::OracleMetadata)
        return new(implementation, metadata)
    end
end

"""
    DerivativeOracle <: Oracle

Oracle for computing derivatives: ∇f(x).
"""
struct DerivativeOracle <: Oracle
    implementation::Function
    metadata::OracleMetadata

    # Default constructor for exact oracle
    function DerivativeOracle(implementation::Function)
        return new(implementation, OracleMetadata(; exactness=Exact()))
    end

    # Constructor with exactness
    function DerivativeOracle(implementation::Function, exactness::Exactness)
        return new(implementation, OracleMetadata(; exactness=exactness))
    end

    # Constructor with metadata
    function DerivativeOracle(implementation::Function, metadata::OracleMetadata)
        return new(implementation, metadata)
    end
end

"""
    ProximalOracle <: Oracle

Oracle for computing proximal operators: prox_λf(x) = argmin_y { f(y) + (1/2λ)‖y-x‖² }.
"""
struct ProximalOracle <: Oracle
    implementation::Function
    metadata::OracleMetadata

    # Default constructor for exact oracle
    function ProximalOracle(implementation::Function)
        return new(implementation, OracleMetadata(; exactness=Exact()))
    end

    # Constructor with exactness
    function ProximalOracle(implementation::Function, exactness::Exactness)
        return new(implementation, OracleMetadata(; exactness=exactness))
    end

    # Constructor with metadata
    function ProximalOracle(implementation::Function, metadata::OracleMetadata)
        return new(implementation, metadata)
    end
end

# Callable interface for oracles
(oracle::Oracle)(args...) = oracle.implementation(args...)

function ==(o1::EvaluationOracle, o2::EvaluationOracle)
    return o1.metadata.exactness == o2.metadata.exactness
end
hash(o::EvaluationOracle, h::UInt) = hash(o.metadata.exactness, h)

# Do similarly for DerivativeOracle and ProximalOracle:
function ==(o1::DerivativeOracle, o2::DerivativeOracle)
    return o1.metadata.exactness == o2.metadata.exactness
end
hash(o::DerivativeOracle, h::UInt) = hash(o.metadata.exactness, h)

==(o1::ProximalOracle, o2::ProximalOracle) = o1.metadata.exactness == o2.metadata.exactness
hash(o::ProximalOracle, h::UInt) = hash(o.metadata.exactness, h)
