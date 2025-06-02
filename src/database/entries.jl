# Entries for Database
# Group `DATABASE[(Template, Method)] = [Rate, ...]` under template headings

# Example:
#
# # Template: SmoothMinimization
# t = Template(:smooth_minimization, some_expression, Dict())
# m = Method(:gradient_descent, t, [:L], [:α], Dict())
# r = Rate(:SuboptimalityGap, :(L, α)->k->L * (1 - α * L) ^ k, Dict())
# DATABASE[(t, m)] = [r]

using ..Database
using ..Language: Literal, R

# Dummy entry for testing
# Template expression: a literal zero in real space
t_dummy = Template(:dummy_template, f(x), Dict())
# Method with no parameters
m_dummy = Method(:dummy_method, t_dummy, Symbol[], Symbol[], Dict())
# Rate returns zero bound
r_dummy = Rate(:SuboptimalityGap, Literal(0, R()), Dict())
# Add to database
DATABASE[(t_dummy, m_dummy)] = [r_dummy]
