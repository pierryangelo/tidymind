#import "@preview/cetz:0.5.2"
#import "style.typ": edge-width, node-body, node-paint, node-spec

// Branch color. An explicit `branch` (1..n) wins over the natural position;
// the root, which belongs to no branch, takes the first palette color.
#let _branch-color(n, palette) = {
  let idx = if n.at("branch", default: none) != none { n.branch - 1 }
    else if n.branch-index < 0 { 0 } else { n.branch-index }
  palette.at(calc.rem(idx, palette.len()))
}

#let _role-color(n, opts) = {
  let role = n.at("emphasis", default: none)
  if role == none { none } else { opts.emphasis-colors.at(role, default: none) }
}

#let _top(n) = n.y - n.h / 2

/// Where edges meet this node, in layout coordinates (y grows downwards).
#let anchor-y(n) = _top(n) + n.a

#let _side(n) = if n.at("side", default: 1) < 0 { -1 } else { 1 }

#let _spec(n, depth, opts) = node-spec(opts.style, depth, emphasized: n.emphasized, surfaced: n.surfaced)

// Parent→child edges, from the parent's anchor to the child's. Recursive.
#let _draw-edges(n, palette, opts, depth) = {
  import cetz.draw: *
  for c in n.children {
    let s = _side(c)
    let a = (if s > 0 { n.x + n.w } else { n.x }, -anchor-y(n))
    let b = (if s > 0 { c.x } else { c.x + c.w }, -anchor-y(c))
    let child-spec = _spec(c, depth + 1, opts)
    // An edge that arrives at a rule arrives with the rule's thickness: that
    // is what makes the two read as one line.
    let w = if child-spec.rule != none { child-spec.rule } else { edge-width(opts.style, depth) }
    let mid = (a.at(0) + b.at(0)) / 2
    bezier(a, b, (mid, a.at(1)), (mid, b.at(1)), stroke: (paint: _branch-color(c, palette), thickness: w, cap: "round"))
  }
  for c in n.children { _draw-edges(c, palette, opts, depth + 1) }
}

// Nodes, with their rule and capsule. Recursive. The body is the one measured.
#let _draw-nodes(n, palette, opts, depth) = {
  import cetz.draw: *
  let color = _branch-color(n, palette)
  let role = _role-color(n, opts)
  let spec = _spec(n, depth, opts)
  let paint = node-paint(spec, depth, color, opts.ink, if n.emphasized { role } else { none },
    role: if n.tag != none { role } else { none })
  let top = _top(n)
  // The rule is a STROKE drawn here, not a border of the box: the edge that
  // arrives at it is the same kind of line, so the join has no step.
  if spec.rule != none {
    let r = spec.rule.pt() / 2
    let y = -(top + n.h - r)
    line((n.x + r, y), (n.x + n.w - r, y), stroke: (paint: paint.rule, thickness: spec.rule, cap: "round"))
  }
  content((n.x, -top), anchor: "north-west", node-body(n.content, spec, paint, opts.font, opts.text-size,
    width: n.w * 1pt, number: n.number, tag: n.tag, mono-font: opts.mono-font))
  // The capsule: 60% of the node's height, centered, fully rounded.
  if spec.capsule {
    let x = n.x + (if spec.frame == "surface" { 4 } else { 1.2 })
    let cy = -(top + n.h / 2)
    line((x, cy + n.h * 0.3), (x, cy - n.h * 0.3), stroke: (paint: paint.capsule, thickness: 2pt, cap: "round"))
  }
  for c in n.children { _draw-nodes(c, palette, opts, depth + 1) }
}

/// Draws the already positioned mind map (the output of `layout-tree`).
#let draw-mindmap(n, palette, opts) = {
  _draw-edges(n, palette, opts, 0)
  _draw-nodes(n, palette, opts, 0)
}
