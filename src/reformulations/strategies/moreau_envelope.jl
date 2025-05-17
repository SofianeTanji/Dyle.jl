raw"""
Replace a nonsmooth `f` by its exact smoothing:
  $$
  f_\mu(x) \;=\; \min_u \Bigl\{\,f(u)\;+\;\tfrac{1}{2\mu}\|u - x\|^2\Bigr\},
  $$
  then solve
  $$\min_x f_\mu(x).$$
  The minimizers coincide and $\nabla f_\mu(x)$ is given via the proximal map of `f`.
"""