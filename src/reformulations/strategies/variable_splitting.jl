raw"""
**Variable Splitting**
  Introduce a copy `z` of the main variable `x` so that
  $$
    \\min_x f(x) + g(x)
    \\;\\longmapsto\\;
    \\min_{x,z} f(x) + g(z)
    \\quad\\text{s.t.}\\quad x - z = 0.
  $$
"""