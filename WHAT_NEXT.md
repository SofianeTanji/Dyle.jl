# ================
# FILE: structure_loss.jl
# ================
#
# Implement the “Structure-Loss” (a.k.a. Abstraction-Loss) strategy in Julia.
# This code should live in Argo.jl under a module called `StructureLoss`.
#
# GOAL:
#   Given a Julia `Expr` representing a mathematical expression,
#   produce a vector of “abstracted” expressions where each non-atomic
#   sub-expression has been collapsed into a fresh function-call stub.
#   Each fresh stub carries the same properties/oracles as the original subtree.
#
# KEY CONCEPTS:
#   – An **atomic** node is:
#       • A bare `Symbol` (variable) or a literal (numeric constant, string, etc.)
#       • A function-call `:(f(x))` whose **all** arguments are atomic.
#     We do *not* abstract atomic nodes.
#
#   – A **non-atomic** node is:
#       • Any `Expr` representing an operator call (e.g. `:+`, `:*`, `call`) or
#         a function-call whose arguments include deeper calls or non-literals.
#     We *will* abstract non-atomic nodes.
#
#   – For each non-atomic sub-expression `subexpr` we must:
#       1. Pick a fresh symbol, e.g. `_f_g(x)` if `subexpr` was `f(g(x))`.
#       2. Build a `FunctionType` for that fresh symbol with:
#            • Domain = tuple of argument types of `subexpr`’s inputs
#            • Codomain = return type (or inferred output type) of `subexpr`
#       3. Replace `subexpr` with `:(FreshName(args...))` in a copy of the original tree.
#       4. Run
#           ```julia
#           props = infer_properties(subexpr)
#           oracle = get_oracle(subexpr, OracleType)
#           ```
#          and attach those `props` and `oracle` to the fresh symbol’s metadata registry.
#
#   – Also always allow abstraction at the root of the expression (so we can collapse the entire tree).
#
#   – Return a `Vector{Expr}` containing one new “abstracted” expression per non-atomic position.
#
# FUNCTION SIGNATURE:
#   module StructureLoss
#     export structure_loss
#
#     """
#     structure_loss(expr::Expr) -> Vector{Expr}
#
#     Traverse `expr`, find all non-atomic sub-expressions (including `expr` itself).
#     For each such position:
#       • Generate a fresh symbol `Hk` (uniquely named so it does not collide with any existing names).
#       • Replace only that one sub-expression with `:(Hk(arg1, arg2, …))` in a copy of `expr`.
#       • Call `infer_properties(subexpr)` and `get_oracle(subexpr, OracleType)`.
#         Attach the returned metadata to `Hk` (e.g. via a global registry or dictionary).
#     Return the list of all resulting `Expr` trees.
#     """
#     function structure_loss(expr::Expr)::Vector{Expr}
#         # YOUR IMPLEMENTATION HERE
#     end
#   end
#


# ========================
# Step-by-Step Instructions
# ========================

# 1. Define a helper `is_atomic(expr::Expr)::Bool` that returns true if:
#      – `expr.head == :symbol`  (i.e. a bare variable, captured as `Symbol`)
#      – `expr.head == :integer` or `:float` or any literal head
#      – `expr.head == :call` or any operator, but *all* of `expr.args` are atomic
#        (e.g. `:(f(x))` where `x` is a `Symbol`).
#    Otherwise, return false.
#
#    Hint: You can check `isa(expr, Symbol)` or `isa(expr, Number)` for base cases,
#    or inspect `expr.head == :call` and recursively check `args`.
#
# 2. Walk the tree to collect every location (position) of a non-atomic sub-expression.
#    – You need to traverse in pre-order (root first), tracking a list of `(subexpr, path)`
#      pairs. A “path” could be implemented as a small vector of integer indices that
#      tells you how to descend from the root `expr` to that sub-expression.
#    – Always include the root itself if it’s non-atomic.
#    – Skip any sub-expression for which `is_atomic(subexpr) == true`.
#    – Use a recursive helper, e.g. `collect_nonatomic(expr::Expr, path::Vector{Int}, out::Vector{Tuple{Expr, Vector{Int}}})`.
#
# 3. For each collected `(subexpr, path)`:
#    a. Generate a fresh symbol. Use a global counter or UUID logic so names never collide.
#       Example naming rule: If `subexpr` is `:(f(g(x)))`, you could create a name:
#         `Symbol("_sl_", "f", "_", "g", "_", uuid_part)`
#       or simply `gensym(:H)`. But if you want readability, encode `f_g` in the name.
#
#    b. Build a `FunctionType` for the fresh symbol:
#         – Determine the argument symbols of `subexpr`. E.g. if `subexpr` is `:(g(f(x), y+2))`,
#           its input variables are those `Symbol`s that occur at the “leaves” of that subtree.
#           You can assume each input leaf has a known Julia type (e.g. `Float64`)
#           via `infer_type(leaf)`.
#         – Let `arg_syms = unique(sorted list of leaf `Symbol`s in `subexpr`)`.
#         – Let `dom_tuple = Tuple{map(infer_type, arg_syms)...}`.
#         – Let `codomain = infer_type(subexpr)`.
#         – Set:
#             ```julia
#             @eval $(fresh_sym)::FunctionType{ $(dom_tuple), $(codomain) }
#             ```
#           or register that type in your global registry.
#
#    c. Build an expression `stub_call = Expr(:call, fresh_sym, arg_syms...)`.
#
#    d. Copy the original expression `expr_copy = deepcopy(expr)`.
#
#    e. Replace only the subtree at `path` in `expr_copy` with `stub_call`.
#       You can write a helper `replace_at_path!(expr_copy::Expr, path::Vector{Int}, new_sub::Expr)`.
#
#    f. Invoke:
#         ```julia
#         props = infer_properties(subexpr)
#         oracle = get_oracle(subexpr, OracleType)
#         ```
#       Then attach these results to `fresh_sym`, e.g. by doing:
#         ```julia
#         register_properties!(fresh_sym, props, oracle)
#         ```
#       (Assuming you have such a `Dict{Symbol, Tuple{Properties, Oracle}}`.)
#
#    g. Push `expr_copy` onto your output vector.
#
# 4. After processing all collected positions, return the vector of modified copies.
#
# 5. (Optional) If you also want to _iterate_ over “more trivialized” trees (so that after
#    you collapse one subtree, you then collapse a second subtree in the result, you can
#    simply call `structure_loss` again on each element of the result and union all new
#    forms until no new forms appear. But for the first pass, it’s enough to emit all
#    single‐node‐collapsed variants.)
#
#
# =======
# EXAMPLES
# =======
#
# 1) `expr = :(f(x) + g(f(x)))`
#
#    – Nonatomic positions:
#        a. `:(g(f(x)))`      (path = [2])       # since `expr.head == :call` for `:+`
#        b. `:(f(x) + g(f(x)))` (path = [])      # the entire root
#
#    – Let fresh symbols be `H1` for `g(f(x))` and `H2` for `f(x) + g(f(x))`.
#    – Properties:
#        props1 = infer_properties(:(g(f(x))))
#        props2 = infer_properties(:(f(x) + g(f(x))))
#
#    – After abstraction:
#        1) Replace at path [2]:
#           `new1 = :(f(x) + H1(x))`,  attach `props1` to `H1`.
#        2) Replace at path []:
#           `new2 = :(H2(x))`,         attach `props2` to `H2`.
#
#    – Return `[new1, new2]`.
#
#
# 2) `expr = :(f(g(h(x))) + k(x))`
#
#    – Nonatomic positions:
#        a. `:(g(h(x)))`          (path = [1,1])
#        b. `:(f(g(h(x))))`       (path = [1])
#        c. `:(f(g(h(x))) + k(x))` (path = [])
#
#    – Let fresh `H1` for `g(h(x))`, `H2` for `f(g(h(x)))`, `H3` for the sum.
#    – Abstraction outputs:
#        1) `(path [1,1])`: `:(f(H1(x)) + k(x))`
#        2) `(path [1])`:   `:(H2(x) + k(x))`
#        3) `(path [])`:    `:(H3(x))`
#
#    – Attach metadata accordingly.
#
#
# ===========
# UTILITY CODE
# ===========
#
# Below is a sketch of how your module might start. Copilot should be able to fill in
# the helper functions based on these doc-comments:
#
# -------------------------------------------------------------------
# module StructureLoss
# -------------------------------------------------------------------
# using Argo.Core    # for infer_properties, get_oracle, OracleType, etc.
#
# # A global registry mapping fresh symbols to their (properties, oracle):
# const STRUCTURE_REGISTRY = Dict{Symbol, Tuple{Properties, OracleType}}()
#
# """
#   is_atomic(expr::Expr)::Bool
# Returns true if `expr` is a bare variable, literal, or a call whose arguments are all atomic.
# """
# function is_atomic(expr::Expr)::Bool
#     # Copilot: check `isa(expr, Symbol)` or `isa(expr, Number)` for base cases
#     # If `expr.head == :call`, check all `is_atomic(arg)`.
# end
#
# """
#   collect_nonatomic(expr::Expr, path::Vector{Int}, out::Vector{Tuple{Expr, Vector{Int}}})
# Recursively walk and append (subexpr, path) for every non-atomic sub-expression.
# """
# function collect_nonatomic(expr::Expr, path::Vector{Int}, out::Vector{Tuple{Expr, Vector{Int}}})
#     # Copilot: if not is_atomic(expr), push!((expr, copy(path))) into out
#     # Then, for each (index, child) in `enumerate(expr.args)`, append index to path,
#     # and recurse on child. Finally pop! the path.
# end
#
# """
#   replace_at_path!(expr::Expr, path::Vector{Int}, new_sub::Expr)
# Replace the sub-expression at `path` inside `expr` *in-place* with `new_sub`.
# """
# function replace_at_path!(expr::Expr, path::Vector{Int}, new_sub::Expr)
#     # Copilot: iterate through path until you reach the parent of the target,
#     # then do `parent.args[idx] = new_sub`.
# end
#
# """
#   structure_loss(expr::Expr)::Vector{Expr}
# Main entry point. Returns all single-node-collapsed variants of `expr`.
# """
# function structure_loss(expr::Expr)::Vector{Expr}
#     # 1. Create an empty vector `out = Vector{Expr}()`.
#     # 2. Call `collect_nonatomic(expr, Int[], out_positions)`.
#     # 3. For each `(subexpr, path)` in `out_positions`:
#     #     a. `fresh_sym = gensym(:H)`
#     #     b. Determine `arg_syms = unique leaf Symbols in `subexpr` (use a helper)`.
#     #     c. Let `dom_types = map(infer_type, arg_syms)`, `cod_type = infer_type(subexpr)`.
#     #     d. Register the function type:
#     #         `@eval $(fresh_sym)::FunctionType{tuple(dom_types...), cod_type}`.
#     #     e. Build `stub_call = Expr(:call, fresh_sym, arg_syms...)`.
#     #     f. `expr_copy = deepcopy(expr)`.
#     #     g. `replace_at_path!(expr_copy, path, stub_call)`.
#     #     h. `props = infer_properties(subexpr)`.
#     #     i. `oracle = get_oracle(subexpr, OracleType)`.
#     #     j. `STRUCTURE_REGISTRY[fresh_sym] = (props, oracle)`.
#     #     k. `push!(out, expr_copy)`.
#     # 4. Return `out`.
# end
#
# end # module
# -------------------------------------------------------------------
#
# Copilot should now generate the implementations of `is_atomic`, `collect_nonatomic`,
# `replace_at_path!`, and the body of `structure_loss` based on the comments above.
#
# ========
# USAGE:
# ========
#   julia> using StructureLoss
#   julia> expr = :(f(x) + g(f(x)))
#   julia> abstracted = structure_loss(expr)
#   julia> for x in abstracted
#             println(x)
#           end
#
# EXPECTED OUTPUT:
#   :(f(x) + H1(x))
#   :(H2(x))
#
# Both `H1` and `H2` must have been registered in `STRUCTURE_REGISTRY` with the same
# properties and oracles as their original sub-expressions.
#
# — End of Prompt for Copilot —
