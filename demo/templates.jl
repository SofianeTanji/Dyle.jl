"""
    demo/templates.jl

Example usage of the Templates module in Dyle.jl.
"""

using Dyle
using Dyle.Language
using Dyle.Properties
using Dyle.Oracles
using Dyle.Templates

# Define spaces and variables
println("\n== Defining spaces and variables ==")
@variable x::R()
@variable y::R()
@variable v::Rn(3)

# Define functions
println("\n== Defining functions ==")
@func f(R(), R())  # f: ℝ → ℝ
@func g(R(), R())  # g: ℝ → ℝ
@func h(Rn(3), R())  # h: ℝ³ → ℝ

# Register properties for functions
println("\n== Registering properties for functions ==")
@property f Convex() Smooth(1.0)
println("f: Convex, Smooth(L=1.0)")

@property g StronglyConvex(0.1) Smooth(0.5) Convex()
println("g: StronglyConvex(μ=0.1), Smooth(L=0.5)")

@property h Convex() Lipschitz(2.0)
println("h: Convex, Lipschitz(M=2.0)")

# Register oracles for functions
println("\n== Registering oracles for functions ==")
@oracle f EvaluationOracle(x -> x^2)
@oracle f DerivativeOracle(x -> 2 * x)
println("f(x) = x², f'(x) = 2x")

@oracle g EvaluationOracle(x -> 0.05 * x^2 + x)
@oracle g ProximalOracle(x -> x) # dummy
println("g(x) = 0.05x² + x, g'(x) = 0.1x + 1")

@oracle h EvaluationOracle(v -> sum(v .^ 2))
@oracle h DerivativeOracle(v -> 2 * v)
println("h(v) = ||v||², h'(v) = 2v")

# Define templates
println("\n== Defining optimization templates ==")

# Template 1: Smooth convex minimization
smooth_convex_template =
    @template(:smooth_convex_min, "Minimization of a smooth convex function", f(x))

# Add function requirements
smooth_convex_req = @require_function(
    :f,
    "Smooth convex objective function",
    [Convex, Smooth],
    [EvaluationOracle, DerivativeOracle],
    Dict{Symbol,Any}(:L => 1.0)
)

@add_requirements(:smooth_convex_min, smooth_convex_req)
println("Created template 'smooth_convex_min' with requirements for 'f'")

# Template 2: Strongly convex minimization
strongly_convex_template =
    @template(:strongly_convex_min, "Minimization of a strongly convex function", g(x))

strongly_convex_req = @require_function(
    :g,
    "Strongly convex objective function",
    [StronglyConvex, Smooth],
    [EvaluationOracle, DerivativeOracle],
    Dict{Symbol,Any}(:L => 1.0, :μ => 0.1)
)

@add_requirements(:strongly_convex_min, strongly_convex_req)
println("Created template 'strongly_convex_min' with requirements for 'g'")

# Template 3: Composite minimization
composite_template = @template(
    :composite_min,
    "Minimization of a composite function (sum of convex functions)",
    f(x) + g(x)
)

composite_f_req = @require_function(
    :f,
    "First convex function in sum",
    [Convex],
    [EvaluationOracle, DerivativeOracle]
)

composite_g_req = @require_function(
    :g,
    "Second convex function in sum",
    [Convex],
    [EvaluationOracle, ProximalOracle]
)

@add_requirements(:composite_min, composite_f_req, composite_g_req)
println("Created template 'composite_min' with requirements for 'f' and 'g'")

# Template 4: Vector-to-scalar minimization
vector_template =
    @template(:vector_min, "Minimization of a convex function on a vector domain", h(v))

vector_h_req = @require_function(
    :h,
    "Convex function with vector domain",
    [Convex],
    [EvaluationOracle, DerivativeOracle]
)

@add_requirements(:vector_min, vector_h_req)
println("Created template 'vector_min' with requirements for 'h'")

# Register methods with convergence rates
println("\n== Registering optimization methods with convergence rates ==")

# Methods for smooth convex minimization
println("\n--- Methods for smooth convex minimization ---")

# Gradient Descent
gd_method = @method(
    "Gradient Descent",
    "Standard first-order method using gradients with 1/L step size",
    :smooth_convex_min,
    "Nesterov, Y. (2004). Introductory Lectures on Convex Optimization."
)

gd_rate = @rate(
    "Sublinear",
    "Sublinear 1/k convergence",
    SuboptimalityGap,
    (k, initial, params) -> (params[:L] / (2 * k)) * initial,
    "O(1/k)",
    Dict{Symbol,Tuple{Symbol,Symbol}}(:L => (:f, :L)),
    Dict{Symbol,Any}(:step_size => "1/L")
)

@add_method(:smooth_convex_min, gd_method, gd_rate)
println("Added Gradient Descent method with sublinear O(1/k) convergence rate")

# Accelerated Gradient Descent (Nesterov)
agd_method = @method(
    "Accelerated Gradient Descent",
    "Nesterov's accelerated gradient method",
    :smooth_convex_min,
    "Nesterov, Y. (1983). A method for solving the convex programming problem with convergence rate O(1/k²)."
)

agd_rate = @rate(
    "Accelerated Sublinear",
    "Accelerated sublinear 1/k² convergence",
    SuboptimalityGap,
    (k, initial, params) -> (4 * params[:L] / ((k + 1)^2)) * initial,
    "O(1/k²)",
    Dict{Symbol,Tuple{Symbol,Symbol}}(:L => (:f, :L)),
    Dict{Symbol,Any}(:step_sequence => "Nesterov sequence")
)

@add_method(:smooth_convex_min, agd_method, agd_rate)
println(
    "Added Accelerated Gradient Descent method with accelerated O(1/k²) convergence rate",
)

# Methods for strongly convex minimization
println("\n--- Methods for strongly convex minimization ---")

# Gradient Descent for strongly convex functions
scgd_method = @method(
    "Gradient Descent (Strongly Convex)",
    "Gradient descent optimized for strongly convex functions",
    :strongly_convex_min,
    "Nesterov, Y. (2004). Introductory Lectures on Convex Optimization."
)

scgd_rate = @rate(
    "Linear",
    "Linear convergence with rate dependent on condition number",
    SuboptimalityGap,
    (k, initial, params) -> (1 - params[:μ] / params[:L])^k * initial,
    "O((1-μ/L)ᵏ)",
    Dict(:μ => (:g, :μ), :L => (:g, :L)),
    Dict{Symbol,Any}(:step_size => "1/L")
)

@add_method(:strongly_convex_min, scgd_method, scgd_rate)
println("Added Gradient Descent method with linear O((1-μ/L)ᵏ) convergence rate")

# Accelerated Gradient Descent for strongly convex functions
scagd_method = @method(
    "Accelerated Gradient Descent (Strongly Convex)",
    "Nesterov's accelerated method for strongly convex functions",
    :strongly_convex_min,
    "Nesterov, Y. (2004). Introductory Lectures on Convex Optimization."
)

scagd_rate = @rate(
    "Accelerated Linear",
    "Accelerated linear convergence with improved dependence on condition number",
    SuboptimalityGap,
    (k, initial, params) -> (1 - sqrt(params[:μ] / params[:L]))^k * initial,
    "O((1-√(μ/L))ᵏ)",
    Dict(:μ => (:g, :μ), :L => (:g, :L)),
    Dict{Symbol,Any}(:step_sequence => "Nesterov strongly convex sequence")
)

@add_method(:strongly_convex_min, scagd_method, scagd_rate)
println(
    "Added Accelerated Gradient Descent method with accelerated linear O((1-√(μ/L))ᵏ) convergence rate",
)

# Methods for composite minimization
println("\n--- Methods for composite minimization ---")

# Proximal Gradient Descent
pgd_method = @method(
    "Proximal Gradient Descent",
    "Gradient step on smooth part followed by proximal step on non-smooth part",
    :composite_min,
    "Beck, A., & Teboulle, M. (2009). A fast iterative shrinkage-thresholding algorithm for linear inverse problems."
)

pgd_rate = @rate(
    "Sublinear",
    "Sublinear 1/k convergence for composite functions",
    SuboptimalityGap,
    (k, initial, params) -> (2 * params[:L] / k) * initial,
    "O(1/k)",
    Dict(:L => (:f, :L)),
    Dict{Symbol,Any}(:step_size => "1/L")
)

@add_method(:composite_min, pgd_method, pgd_rate)
println("Added Proximal Gradient Descent method with sublinear O(1/k) convergence rate")

# Display template information
println("\n== Template Details ==")
@template_details(:smooth_convex_min)

# Test matching expressions with templates
println("\n== Testing Template Matching ==")

# Example 1: Simple function minimization
println("\n--- Example 1: f(x) ---")
expr1 = f(x)
matching_templates1 = @find_templates(expr1)
println("Expression: f(x)")
println("Matching templates: ", matching_templates1)

# Example 2: Strongly convex function minimization
println("\n--- Example 2: g(x) ---")
expr2 = g(x)
matching_templates2 = @find_templates(expr2)
println("Expression: g(x)")
println("Matching templates: ", matching_templates2)

# Example 3: Composite function minimization
println("\n--- Example 3: f(x) + g(x) ---")
expr3 = f(x) + g(x)
matching_templates3 = @find_templates(expr3)
println("Expression: f(x) + g(x)")
println("Matching templates: ", matching_templates3)

# Example 4: Vector function minimization
println("\n--- Example 4: h(v) ---")
expr4 = h(v)
matching_templates4 = @find_templates(expr4)
println("Expression: h(v)")
println("Matching templates: ", matching_templates4)

# Get method recommendations
println("\n== Method Recommendations ==")

println("\n--- Recommendations for f(x) ---")
@recommend(f(x))

println("\n--- Recommendations for g(x) ---")
@recommend(g(x))

println("\n--- Recommendations for f(x) + g(x) ---")
@recommend(f(x) + g(x))

println("\n--- Recommendations for h(v) ---")
@recommend(h(v))

println("\n== Demo Completed ==")
