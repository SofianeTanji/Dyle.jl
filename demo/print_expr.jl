using Revise
using Argo
using Argo.Language
using Argo.Properties
using Argo.Oracles
using Argo.Reformulations
using Test

@variable x::R()

@func f(R(), R())
@func g(R(), R())
@func h(R(), R())

@func A(R(), R())

@property f Convex() Smooth(2.0)
@property g Convex()
@property A Linear(5.0)
expr = f(x) + g(A(x)) + h(x)

function collect_edges(
    expr,
    parent=nothing,
    edges=Vector{Tuple{String,String}}(),
    eval_counter=Ref(0),
    var_counter=Dict{String,Int}(),
)
    # Initialize edges list if not provided
    edges === nothing && (edges = Vector{Tuple{String,String}}())
    # Determine node label and children based on expression type
    if expr isa Argo.Language.Addition
        label = "+"
        children = expr.terms
    elseif expr isa Argo.Language.Subtraction
        label = "-"
        children = expr.terms
    elseif expr isa Argo.Language.FunctionCall
        # For function calls, we need to create intermediate evaluation nodes
        fname =
            expr.name isa Argo.Language.FunctionType ? expr.name.name : string(expr.name)

        # Check if the argument is a variable or another function call
        if length(expr.args) == 1
            arg = expr.args[1]
            if arg isa Argo.Language.Variable
                # f(x) -> create @ node between f and x
                eval_counter[] += 1
                eval_label = ".$(eval_counter[])"  # Always use numbered @ for uniqueness
                if parent !== nothing
                    push!(edges, (parent, eval_label))
                end                # @ connects to f and unique variable instance (but display as same name)
                var_name = string(arg.name)
                if !haskey(var_counter, var_name)
                    var_counter[var_name] = 0
                end
                var_counter[var_name] += 1
                # Create unique internal label but will display as just the variable name
                unique_var_label = "$(var_name)_$(var_counter[var_name])"

                push!(edges, (eval_label, string(fname)))
                push!(edges, (eval_label, unique_var_label))
                return edges
            elseif arg isa Argo.Language.FunctionCall
                # g(A(x)) -> create ∘ node for composition
                comp_label = "∘"
                if parent !== nothing
                    push!(edges, (parent, comp_label))
                end
                # ∘ connects to g and the inner function call
                push!(edges, (comp_label, string(fname)))
                collect_edges(arg, comp_label, edges, eval_counter, var_counter)
                return edges
            end
        end

        # Fallback to original behavior
        label = string(fname)
        children = expr.args
    elseif expr isa Argo.Language.Composition
        label = "∘"
        children = (expr.outer, expr.inner)
    elseif expr isa Argo.Language.Variable
        label = string(expr.name)
        children = []
    elseif expr isa Argo.Language.Literal
        label = string(expr.value)
        children = []
    else
        # fallback label and no children
        label = string(expr)
        children = []
    end
    # record edge from parent to this node
    if parent !== nothing
        push!(edges, (parent, label))
    end
    # recurse on each child
    for child in children
        collect_edges(child, label, edges, eval_counter, var_counter)
    end
    return edges
end

using Plots, GraphRecipes

function make_plot(expr)
    edges = collect_edges(expr)
    parents = getindex.(edges, 1)
    children = getindex.(edges, 2)
    node_labels = unique(vcat(parents, children))
    display_labels = [
        replace(replace(label, r"\.\d+" => "."), r"([a-zA-Z]+)_\d+" => s"\1") for
        label in node_labels
    ]
    label_to_id = Dict(label => i for (i, label) in enumerate(node_labels))
    parent_ids = [label_to_id[p] for p in parents]
    child_ids = [label_to_id[c] for c in children]
    return p = graphplot(parent_ids, child_ids; names=display_labels, method=:tree)
end

expr = f(x) + g(x) + h(x)

make_plot(expr)