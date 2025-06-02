# Collaborative document with the LLM

The goal of this document is for me and you to build some specifications for the upcoming Database module of the Argo.jl package so start by reading extensively the package's code.
The way we will build collaboratively these specifications is the following:

- I write some minimal specifications
- I leave a placeholder for you to write a set of questions regarding these specifications. These questions are questions you will ask me that will help you improve the specifications. You will leave me a placeholder for each question and I will answer the questions.
- Once the specifications are improved, I will modify them and correct them and then you will ask new questions regarding these specifications, leaving a placeholder for me to answer. I will answer them and you'll update the specifications.
- We'll keep playing this game until I believe we have a sufficiently detailed set of specifications.

NB: It is possible that the way I write my specification is erroneous and will lead to complications. In that case, you should tell it and tell me why. If I trust you, I will modify the specification accordingly. Otherwise, I will tell you in the chat why you're mistaken.


#### Minimal specifications
Argo.jl requires a database module.
In the database, three core elements should be stored:
- Optimization Templates
- Optimization Methods
- Convergence Rates
The database will take the form of a dictionary (optimization template, optimization method) -> convergence rate.
This dictionary will be written directly in hard in the module and will only written by me, the users won't touch it but they will be to access the dictionary.
Now on to how each object is specified:
- Optimization Templates
  - A symbolic name acting as unique identifier.
  - An `Expression` object. Within this expression will be some symbols representing some functions. These functions may have properties and oracles attached, as usual in Argo.jl.
  - Some metadata, built as a dictionary string -> string.
- Optimization Methods
  - A symbolic name acting as unique identifier.
  - An associated template
  - The parameters of the template that the method requires, if any. Indeed some method may be able to converge only if they know the exact value of the smoothness constant for example.
  - A list of algorithmic parameters (no numerics, just their names in symbolic)
  - Some metadata, built as a dictionary string -> string.
- Convergence rates
  - A symbolic name representing the performance measure (:suboptimality_gap, :min_grad_norm; :grad_norm etc.)
  - A quoted formula whose body returns another function of a single integer $k$ which computes the numeric bound at iteration $k$. The arguments of the quoted formula are the algorithmic parameters, the template parameters and potentially quantities related to the initialization of the method such as some radius ||x0-x*|| or similar.
  - Some metadata, built as a dictionary string -> string.

#### Revised specifications
- Define `struct Template`
  - `name::Symbol`
  - `expr::Expression`
  - `metadata::Dict{String,String}`

- Define `struct Method`
  - `name::Symbol`
  - `template::Template`
  - `template_params::Vector{Symbol}`
  - `alg_params::Vector{Symbol}`
  - `metadata::Dict{String,String}`

- Define `struct Rate`
  - `measure::Symbol`
  - `formula::Expression`  # quoted function body: `(args...)->k->...`
  - `metadata::Dict{String,String}`

- Database storage type:
```julia
const DATABASE = Dict{Tuple{Template,Method},Vector{Rate}}()
```
- Database population & module layout:
  - Files under `src/database/`:
    - `database.jl`: Defines `module Database`, exports `DATABASE`, `get_rates`, `list_*`, `NotFoundError`; includes `entries.jl` and `queries.jl`.
    - `entries.jl`: Contains grouped `DATABASE[...] = [...]` assignments under `# Template: ...` headings.
    - `queries.jl`: Implements all query and listing functions and error type.

- Database file organization:
  - Group `DATABASE[...] = [...]` assignments under headings per `Template` (e.g. `# Template: MyTemplate`) to improve readability.

- Query API:
  - `get_rates_by_template(name::Symbol)::Dict{Method,Vector{Rate}}`
  - `get_rates_by_method(name::Symbol)::Dict{Template,Vector{Rate}}`
  - `get_all_rates()::Dict{Tuple{Template,Method},Vector{Rate}}`
- Extended Query & Listing API:
  - `get_rates(template::Symbol, method::Symbol, measure::Symbol)::Vector{Rate}`
  - `list_templates()::Vector{Template}`
  - `list_methods()::Vector{Method}`
  - `list_measures(template::Symbol, method::Symbol)::Vector{Symbol}`
  - All lookups that find no matching entries throw a custom `NotFoundError("No rate found for ...")`.

- Equality & hashing:
  - Implement `Base.==(a::Template,b::Template) = a.name == b.name` and `Base.hash(t::Template,h) = hash(t.name,h)` (and analogously for `Method`) so only `name` determines identity.

- Testing strategy:
  - Create `tests/test_database.jl` covering:
    - Successful lookups (`get_rates_by_template`, `get_rates`, `get_all_rates`, listing functions).
    - Missing-rate lookups raising `NotFoundError`.
    - Multiple-rate scenarios returning correct vectors.

- Exporting:
  - `module Database` should `export DATABASE, get_rates, list_templates, list_methods, list_measures, NotFoundError`.
