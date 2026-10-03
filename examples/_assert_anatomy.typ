// The anatomy of a node in every style: what the layout reserves is what the
// drawing emits, where the edge lands, and what the node shows besides its
// label (branch number, leaf marker, role tag, tinted surface).
#import "../src/options.typ": make-opts
#import "../src/style.typ": node-body, node-paint, node-spec, styles
#import "../src/tree.typ": normalize
#import "../src/layout.typ": dressing, measure-node, measure-tree
#set page(width: auto, height: auto)

#context {
  let label = [Sample label]
  for style in styles {
    for surface in ("none", "all") {
      for markers in ("none", "role") {
        let opts = make-opts(style: style, surface: surface, markers: markers)
        for depth in (0, 1, 2, 3) {
          let n = normalize((content: label, emphasis: "warning"))
          let dress = dressing(n, depth, 2, opts)
          let reserved = measure-node(label, depth, opts, dress)
          let spec = node-spec(style, depth, emphasized: dress.emphasized, surfaced: dress.surfaced)
          let paint = node-paint(spec, depth, red, opts.ink, if dress.emphasized { blue } else { none }, role: if dress.tag != none { blue } else { none })
          let drawn = measure(node-body(label, spec, paint, opts.font, opts.text-size, number: dress.number, tag: dress.tag, mono-font: opts.mono-font))
          let where = style + "/" + surface + "/" + markers + "/depth " + str(depth)
          assert(
            calc.abs(reserved.w - drawn.width.pt()) < 0.001 and calc.abs(reserved.h - drawn.height.pt()) < 0.001,
            message: "reserved box differs from drawn box: " + where,
          )
          // The anchor is inside the node.
          assert(reserved.a > 0 and reserved.a <= reserved.h, message: "anchor outside the node: " + where)
          // A rule sits at the bottom: the anchor is on it.
          if spec.rule != none {
            assert(calc.abs(reserved.a - (reserved.h - spec.rule.pt() / 2)) < 0.001, message: "anchor off the rule: " + where)
          }
        }
      }
    }
  }

  // Four levels: a detail (depth 3) is smaller than a point (depth 2), except in "boxed".
  for style in ("outline", "technical", "bar", "block") {
    assert(node-spec(style, 3).scale < node-spec(style, 2).scale, message: style + ": depth 3 should be smaller")
    assert(node-spec(style, 7) == node-spec(style, 3), message: style + ": depth 3 covers everything deeper")
  }

  // Branch number only on the first level, two digits.
  let opts = make-opts(style: "technical")
  let n = normalize((content: [B],))
  assert(dressing(n, 1, 0, opts).number == "01")
  assert(dressing(n, 1, 11, opts).number == "12")
  assert(dressing(n, 2, 0, opts).number == none)

  // Role tag: only with markers "role", only from depth 2, and an unknown role gets no tag (no error).
  let warn = normalize((content: [L], emphasis: "warning"))
  let odd = normalize((content: [L], emphasis: "mystery"))
  let role = make-opts(style: "technical", markers: "role", emphasis-labels: (warning: "atenção"))
  assert(dressing(warn, 2, 0, role).tag == "atenção")
  assert(dressing(warn, 1, 0, role).tag == none)
  assert(dressing(odd, 2, 0, role).tag == none)
  assert(dressing(warn, 2, 0, make-opts(style: "technical")).tag == none)
  // With "role", the role no longer makes the label heavier or recolors it.
  assert(dressing(warn, 2, 0, role).emphasized == false)
  assert(dressing(warn, 2, 0, make-opts(style: "outline")).emphasized == true)

  // Surface: "branches" tints only the first level; a filled node is never tinted.
  let br = make-opts(style: "technical", surface: "branches")
  assert(dressing(n, 1, 0, br).surfaced and not dressing(n, 2, 0, br).surfaced)
  assert(node-spec("block", 1, surfaced: true).frame == "filled")
  assert(node-spec("technical", 1, surfaced: true).frame == "surface")
  assert(node-spec("technical", 1, surfaced: true).rule == none, message: "a surface replaces the rule")

  // The measured tree carries the dressing to the drawing pass.
  let t = measure-tree(normalize((content: [R], children: ((content: [A],), (content: [B],)))), opts)
  assert(t.children.at(1).number == "02")
}
#[OK]
