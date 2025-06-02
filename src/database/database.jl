module Database

using ..Language: Expression

export DATABASE,
    get_rates_by_template,
    get_rates_by_method,
    get_methods_by_expression,
    get_all_rates,
    get_rates,
    list_templates,
    list_methods,
    list_measures,
    NotFoundError

# === Type definitions === #

"""
    Template

Database entry for an optimization template.
"""
struct Template
    name::Symbol
    expr::Expression
    metadata::Dict{String,String}
end

"""
    Method

Database entry for an optimization method.
"""
struct Method
    name::Symbol
    template::Template
    template_params::Vector{Symbol}
    alg_params::Vector{Symbol}
    metadata::Dict{String,String}
end

"""
    Rate

Database entry for a convergence rate.
"""
struct Rate
    measure::Symbol
    formula::Expression    # quoted function body: (args...)->k->...
    metadata::Dict{String,String}
end

# Custom error type for missing entries
struct NotFoundError <: Exception
    msg::String
end

# Equality & hashing for Template and Method
import Base: ==, hash
==(a::Template, b::Template) = a.name == b.name
hash(a::Template, h::UInt) = hash(a.name, h)

==(a::Method, b::Method) = a.name == b.name
hash(a::Method, h::UInt) = hash(a.name, h)

# Database storage constant
const DATABASE = Dict{Tuple{Template,Method},Vector{Rate}}()

# Include grouped data entries
include("entries.jl")

# Include query and listing API implementations
include("queries.jl")

end # module Database
