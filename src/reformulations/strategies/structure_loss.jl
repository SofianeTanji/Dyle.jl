raw"""
- **Structure Loss**
  Whenever your problem is built by composing or combining several simpler operations—e.g. sums, compositions, maxima—**pick operator nodes** in the expression tree and **collapse its children** into a single function \(h\).
  $$
    F(x) = \mathrm{Op}\bigl(f_1(x),f_2(x),\dots,f_k(x)\bigr)
    \;\longmapsto\;
    F(x) = h(x)
    \quad\text{where}\quad
    h(x) = \mathrm{Op}\bigl(f_1(x),\dots,f_k(x)\bigr).
  $$
"""