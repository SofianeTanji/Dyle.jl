"""
Metadata system for oracles.
Provides structures to store information about oracles such as computational costs and error bounds.
"""

"""
    OracleMetadata

Metadata for an oracle including cost and exactness.
"""
struct OracleMetadata
    cost::Union{CostModel,Nothing}
    exactness::Exactness

    OracleMetadata(; cost = nothing, exactness = Exact()) = new(cost, exactness)
end
