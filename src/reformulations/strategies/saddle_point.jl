raw"""
 Rewrite
  $$\min_x\;f(x) + g(Ax)$$
  as
  $$
  \min_x \max_y\;\bigl\{\,f(x)\;+\;\langle A x,y\rangle\;\-\;g^*(y)\bigr\}.
  $$
  Introduces dual variable `y` and exposes primal–dual structure for methods like Chambolle–Pock.

"""