raw"""
Apply a strictly increasing scalar function `h` to the objective without changing minimizers:
  $$\min_x f(x)\;\longmapsto\;\min_x h\bigl(f(x)\bigr),$$
  e.g. `h(u)=\sqrt{u}` or `h(u)=\log(1+u)`.
"""