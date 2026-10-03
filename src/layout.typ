#import "style.typ": inset-top, node-body, node-paint, node-spec

// Neutral colors for the measuring pass: the geometry is the drawing's, and
// geometry is all that matters here.
#let _neutral-ink = (strong: black, soft: black, faint: black)

/// What a node shows besides its label, decided ONCE here and carried on the
/// measured node to the drawing pass, so both passes agree.
#let dressing(n, depth, index, opts) = {
  let role = n.at("emphasis", default: none)
  (
    emphasized: role != none and opts.markers == "none",
    surfaced: opts.surface == "all" or (opts.surface == "branches" and depth == 1),
    number: if depth == 1 { (if index < 9 { "0" } else { "" }) + str(index + 1) } else { none },
    tag: if opts.markers == "role" and role != none and depth >= 2 {
      opts.emphasis-labels.at(role, default: none)
    } else { none },
  )
}

/// Measures one node. Returns `(w, h, a)` in points: `a` is where an edge
/// lands, measured from the node's top — on the rule, in the middle of a
/// frame, or on the middle of the first line. MUST be called inside `context`.
#let measure-node(content, depth, opts, dress) = {
  let spec = node-spec(opts.style, depth, emphasized: dress.emphasized, surfaced: dress.surfaced)
  let paint = node-paint(spec, depth, black, _neutral-ink, none,
    role: if dress.tag != none { black } else { none }, neutral: true)
  let body(width) = node-body(content, spec, paint, opts.font, opts.text-size,
    width: width, number: dress.number, tag: dress.tag, mono-font: opts.mono-font)
  let max-w = if depth == 0 { opts.root-max-width } else { opts.node-max-width }
  let natural = measure(body(auto))
  let (w, h) = if natural.width <= max-w { (natural.width, natural.height) } else {
    // The width goes INTO the node's own box, so the label wraps inside the inset.
    (max-w, measure(body(max-w)).height)
  }
  let cap = measure(text(font: opts.font, size: opts.text-size * spec.scale, weight: spec.weight)[X]).height
  let a = if spec.rule != none { h - spec.rule / 2 }
    else if spec.frame in ("box", "filled", "surface") { h / 2 }
    else { inset-top(spec.inset) + cap / 2 }
  (w: w.pt(), h: h.pt(), a: a.pt())
}

/// Annotates every node with `w`, `h`, `a` and its dressing. MUST be called
/// inside `context`. `index` is the node's position among its siblings.
#let measure-tree(n, opts, depth: 0, index: 0) = {
  let dress = dressing(n, depth, index, opts)
  let m = measure-node(n.content, depth, opts, dress)
  (
    ..n,
    ..dress,
    children: n.children.enumerate().map(((i, c)) => measure-tree(c, opts, depth: depth + 1, index: i)),
    w: m.w,
    h: m.h,
    a: m.a,
  )
}

// Pós-ordem: anota cada nó com `ext` (faixa vertical da subárvore, pt).
#let _assign-extent(n, v-gap) = {
  if n.children.len() == 0 {
    return (..n, ext: n.h)
  }
  let kids = n.children.map(c => _assign-extent(c, v-gap))
  let kids-ext = kids.fold(0.0, (a, c) => a + c.ext) + v-gap * (kids.len() - 1)
  (..n, children: kids, ext: calc.max(n.h, kids-ext))
}

// Pré-ordem: atribui x/y/branch-index. `branch-index` é a POSIÇÃO do ramo
// (0..n-1), herdada por toda a descendência; o `branch` que o chamador pediu,
// quando existe, vence no desenho.
#let _place(n, x, top, h-gap, v-gap, branch) = {
  let y = top + n.ext / 2 // centro vertical do nó na sua faixa
  let child-x = x + n.w + h-gap
  // span vertical ocupado pelos filhos (com v-gaps entre eles)
  let kids-span = if n.children.len() == 0 { 0.0 } else {
    n.children.fold(0.0, (a, c) => a + c.ext) + v-gap * (n.children.len() - 1)
  }
  // centra o bloco de filhos dentro da faixa do nó → pai alinhado ao centro deles
  let cursor = top + (n.ext - kids-span) / 2
  let kids = ()
  let i = 0
  for c in n.children {
    let b = if branch == -1 { i } else { branch }
    kids.push(_place(c, child-x, cursor, h-gap, v-gap, b))
    cursor = cursor + c.ext + v-gap
    i = i + 1
  }
  (..n, children: kids, x: x, y: y, branch-index: branch)
}

/// Annotates the (already measured) tree with `x`/`y`/`branch-index`/`ext`.
/// The root gets `branch-index: -1`. Coordinates are floats in points, and `y`
/// grows downwards.
#let layout-tree(n, h-gap, v-gap) = {
  // Aceita length (ex.: 40pt) ou float; trabalha internamente em float pt.
  let hg = if type(h-gap) == length { h-gap.pt() } else { h-gap }
  let vg = if type(v-gap) == length { v-gap.pt() } else { v-gap }
  let e = _assign-extent(n, vg)
  _place(e, 0.0, 0.0, hg, vg, -1)
}
