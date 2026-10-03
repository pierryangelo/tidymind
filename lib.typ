#import "@preview/cetz:0.5.2"
#import "src/tree.typ": normalize, prune
#import "src/options.typ": make-opts
#import "src/layout.typ": measure-tree, layout-tree
#import "src/draw.typ": draw-mindmap
#import "src/style.typ": default-emphasis-colors, default-emphasis-labels, default-ink, styles

#let default-palette = (
  rgb("#2563eb"), rgb("#16a34a"), rgb("#dc2626"),
  rgb("#9333ea"), rgb("#ea580c"), rgb("#0891b2"),
)

/// Builds a tree node. `content` is the label and the remaining positional
/// arguments are its children. `branch` (1..n) overrides the palette color;
/// `emphasis` is the node's role. Both are given by NAME.
#let node(content, ..children, branch: none, emphasis: none) = normalize((
  content: content,
  children: children.pos(),
  branch: branch,
  emphasis: emphasis,
))

#let _one-of(value, allowed, name) = assert(
  value in allowed,
  message: "tidymind: unknown " + name + " \"" + str(value) + "\", expected one of " + allowed.join(", "),
)

/// Draws a complete mind map: measure, tidy layout, then CeTZ drawing.
///
/// - `style`: `"boxed"` (default), `"outline"`, `"technical"`, `"bar"`, `"block"`.
/// - `surface`: `"none"`, `"branches"` or `"all"` turn nodes into tinted cards.
/// - `markers`: `"none"` (a role recolors the label) or `"role"` (a short tag
///   from `emphasis-labels` in front of the label, in `mono-font`).
/// - `root-max-width`: the root's wrap width; `auto` is twice `node-max-width`.
/// - `edge`: `"curved"` (default), `"straight"` or `"tapered"` (a filled
///   ribbon that thins from the parent to the child).
/// - `direction`: `"right"` (default), `"left"` or `"both"` (the first
///   branches go right, the rest left, balanced by size).
/// - `align-levels`: every depth starts at one column per side.
#let mindmap(
  root,
  style: "boxed",
  palette: default-palette,
  font: "Inter",
  text-size: 9pt,
  node-max-width: 6cm,
  root-max-width: auto,
  max-depth: 6,
  h-gap: 40pt,
  v-gap: 10pt,
  ink: (:),
  emphasis-colors: (:),
  surface: "none",
  markers: "none",
  emphasis-labels: (:),
  mono-font: "DejaVu Sans Mono",
  edge: "curved",
  direction: "right",
  align-levels: false,
) = context {
  _one-of(style, styles, "style")
  _one-of(surface, ("none", "branches", "all"), "surface")
  _one-of(markers, ("none", "role"), "markers")
  _one-of(edge, ("curved", "straight", "tapered"), "edge")
  _one-of(direction, ("right", "left", "both"), "direction")
  let opts = make-opts(style: style, font: font, text-size: text-size,
    node-max-width: node-max-width, root-max-width: root-max-width, mono-font: mono-font,
    markers: markers, surface: surface, emphasis-labels: emphasis-labels, ink: ink,
    emphasis-colors: emphasis-colors, edge: edge)
  let t = prune(normalize(root), max-depth)
  let placed = layout-tree(measure-tree(t, opts), h-gap, v-gap, direction: direction, align-levels: align-levels)
  cetz.canvas(length: 1pt, draw-mindmap(placed, palette, opts))
}
