# tidymind

Horizontal mind map diagrams for [Typst](https://typst.app), built on
[CeTZ](https://typst.app/universe/package/cetz/). Every node is measured before
the layout runs, so long labels never overlap — the common failure of
fixed-spacing tree drawers.

![A mind map with a filled root and rounded, colored nodes](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/shallow.png)

## What's new in 0.3.0

- Three new styles: `technical`, `bar` and `block`.
- `edge: "straight"` and `edge: "tapered"`, besides the curved edge.
- `direction: "left"` and `direction: "both"`; `align-levels` lines up each depth in one column.
- `surface` turns nodes into tinted cards; `markers: "role"` tags a node's role instead of recoloring it.
- Four levels with their own look (root, branch, point, detail).
- A label ignores the document's justification and hyphenation: inside a justified, hyphenated document it used to split words and open gaps.

![The same map in every style and edge](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/gallery.png)

## Usage

````typ
#import "@preview/tidymind:0.3.0": mindmap, node

#mindmap(node([Root],
  node([Branch A], node([A1]), node([A2])),
  node([Branch B]),
))
````

`node(content, ..children)` builds a tree node; `content` is the label and the
remaining positional arguments are its children (each one another `node(...)` or
raw content). A raw dictionary `(content: .., children: (..))` is also accepted.

## Long labels

This is the case that pushed the package into existence. Node sizes come from
Typst's `measure`, so a label that wraps reserves the vertical band it actually
needs — at any depth, with no manual offsets.

![Two long labels wrapped at node-max-width, neither overlapping the other](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/long_labels.png)

## Styles

`style: "boxed"` (the default) draws every node as a rounded box, the root
filled with its branch color.

`style: "outline"` drops the boxes entirely: the root becomes a heading over a
baseline rule, each first-level branch a label resting on a rule in its own
color, and everything deeper is plain text. Hierarchy comes from size, weight
and color instead of from frames — useful when the map sits inside a document
and boxes would fight with the surrounding text.

![The same tree in the outline style, with no boxes around any node](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/outline.png)

## Technical, bar and block

Three more styles build on the same tree. The examples below all draw this one:

````typ
#let switching = node([Switching techniques],
  node([Circuit switching],
    node([Dedicated channel (`FDM` or `TDM`)]),
    node([Three phases: setup, transfer, teardown]),
    node([Idle time wastes fixed bandwidth], emphasis: "warning"),
  ),
  node([Message switching],
    node([Whole-message store-and-forward], emphasis: "definition"),
    node([No fragmentation]),
  ),
  node([Packet switching],
    node([Statistical multiplexing]),
    node([Modes],
      node([Datagram (connectionless)]),
      node([Virtual circuit], node([`MPLS`], emphasis: "example")),
    ),
  ),
)
````

`style: "technical"` reads like a spec sheet: the root and each first-level
branch sit on a rule that the edge runs into, branches are numbered, and points
get a small square marker.

````typ
#mindmap(switching, style: "technical", markers: "role", align-levels: true)
````

![The technical style: numbered branches on colored rules, square markers on the points](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/technical.png)

`style: "bar"` draws the root and the branches over thick rules, and pairs with
the tapered edge.

````typ
#mindmap(switching, style: "bar", edge: "tapered")
````

![The bar style: thick rules under the root and the branches, tapered edges](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/bar.png)

`style: "block"` fills the root and the first-level branches, numbered, and
leaves everything deeper as plain text.

````typ
#mindmap(switching, style: "block", edge: "straight")
````

![The block style: filled, numbered branches and straight edges](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/block.png)

## Edges

`edge` picks how a parent reaches its children: `"curved"` (the default),
`"straight"`, or `"tapered"`, a filled ribbon that thins from the parent to the
child. Any edge goes with any style; the gallery at the top shows every pair.
Below the first level, edges are drawn lighter in every style but `"boxed"`.

````typ
#mindmap(switching, style: "bar", edge: "tapered")
#mindmap(switching, style: "block", edge: "straight")
````

## Direction and columns

`direction: "left"` grows the map to the left; `direction: "both"` sends the
first branches to the right and the rest to the left, split so both sides carry
about the same height. `align-levels: true` starts every depth at one column per
side instead of right after its parent.

````typ
#mindmap(switching, style: "technical", direction: "both", markers: "role")
````

![The same map growing both ways, one branch to the right and two to the left](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/both.png)

## Surface

`surface: "branches"` puts the first-level branches on tinted cards in their
color; `surface: "all"` does the same for every node.

````typ
#mindmap(switching, style: "outline", surface: "all")
````

![The outline style with every node on a tinted card](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/surface.png)

## Role markers

By default a node's `emphasis` recolors its label (see "Roles and branch
colors" below). `markers: "role"` keeps the label in the normal ink and puts a
short tag in front of it instead, in `mono-font`. `emphasis-labels` changes the
tag text; a partial dictionary merges over the defaults (`key`, `warn`, `def.`,
`e.g.`).

````typ
#mindmap(switching, style: "technical", markers: "role",
  emphasis-labels: (warning: "watch out"))
````

![Role tags in front of the labels, one of them renamed to "watch out"](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/markers.png)

## Labels inside justified text

A label ignores the document's justification (`par(justify: true)`) and
hyphenation: a wrapped label breaks between words and keeps its normal
spacing.

````typ
#set text(lang: "en", hyphenate: true)
#set par(justify: true)
#let long = node([Packet switching techniques],
  node([Statistical multiplexing on demand]),
  node([Fragmentation with pipeline parallelism]),
)
#mindmap(long, style: "outline", node-max-width: 3.2cm)
````

![Wrapped labels in a justified document, with no hyphenated words](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/justified.png)

## Roles and branch colors

A node can carry an `emphasis` — its role — and a `branch` index that overrides
the color it would inherit from its position. Both are given by **name**: the
document says what a node *means*, and the package resolves the color.

````typ
#mindmap(
  node([SQL privileges],
    node([GRANT],
      node([Idempotent], emphasis: "definition"),
      node([Cascades to dependents], emphasis: "warning"),
    ),
    node([REVOKE], branch: 5,
      node([RESTRICT is the default], emphasis: "highlight"),
    ),
  ),
  style: "outline",
)
````

![A map whose leaves are colored by role: definition, warning, highlight and example](https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/emphasis.png)

## Options

| Option | Default | Meaning | Since |
|--------|---------|---------|-------|
| `style` | `"boxed"` | `"boxed"`, `"outline"`, `"technical"`, `"bar"` or `"block"` | 0.2 |
| `palette` | 6 colors | color per first-level branch, cycled | 0.1 |
| `font` | `"Inter"` | label font, or a fallback list | 0.1 |
| `text-size` | `9pt` | base label size; the root and first level scale up from it | 0.1 |
| `node-max-width` | `6cm` | max width before a label wraps | 0.1 |
| `root-max-width` | `auto` | the root's wrap width; `auto` is twice `node-max-width` | 0.3 |
| `max-depth` | `6` | prune nodes deeper than this | 0.1 |
| `h-gap` | `40pt` | horizontal gap between levels | 0.1 |
| `v-gap` | `10pt` | minimum vertical gap between siblings | 0.1 |
| `ink` | `(strong, soft)` | label colors; partial dictionaries merge over the defaults | 0.2 |
| `emphasis-colors` | 4 roles | `highlight`, `warning`, `definition`, `example` | 0.2 |
| `edge` | `"curved"` | `"curved"`, `"straight"` or `"tapered"` | 0.3 |
| `direction` | `"right"` | `"right"`, `"left"` or `"both"` | 0.3 |
| `align-levels` | `false` | each depth starts at one column per side | 0.3 |
| `surface` | `"none"` | `"none"`, `"branches"` or `"all"` | 0.3 |
| `markers` | `"none"` | `"none"` or `"role"` | 0.3 |
| `emphasis-labels` | 4 roles | tag text per role, merged over the defaults | 0.3 |
| `mono-font` | `"DejaVu Sans Mono"` | font of branch numbers and role tags | 0.3 |

Labels take arbitrary Typst content, so markup and emoji work — pass a color
emoji font in the `font` fallback list to get the second one:

````typ
#mindmap(node([Git: #strong[what gets graded]], node([🥇 #strong[Remote sync] (35%)])),
  font: ("Inter", "Noto Color Emoji"))
````

## How it works

The layout is a tidy tree by subtree extent: every subtree reserves a vertical
band equal to the sum of its children's bands (or its own height, if a leaf), and
the parent is centered within that band. Because sibling subtrees occupy disjoint
bands, nodes never overlap — at any depth. It runs in O(n), in two passes: one
up the tree to size the bands, one down to place the nodes.

Node sizes come from Typst's `measure`, so a band accounts for the real rendered
size of each (possibly wrapped) label. Measuring and drawing go through a single
description of the node body (`src/style.typ`), which is what keeps an edge
landing exactly on the node it points at.

## Examples

Every file under [`examples/`](examples) compiles on its own. Files named
`visual_*` produce the images above; files named `_assert_*` exercise the logic
through `#assert`, so compiling them **is** the test suite.

```sh
sh examples/render.sh    # runs the asserts, then regenerates img/
```

| Example | What it covers |
|---------|----------------|
| [`visual_shallow`](examples/visual_shallow.typ) | a root with three leaves |
| [`visual_deep`](examples/visual_deep.typ) | several levels of nesting |
| [`visual_many_siblings`](examples/visual_many_siblings.typ) | vertical spacing under pressure |
| [`visual_long_labels`](examples/visual_long_labels.typ) | labels wrapping at `node-max-width` |
| [`visual_outline`](examples/visual_outline.typ) | the `"outline"` style |
| [`visual_emphasis`](examples/visual_emphasis.typ) | roles and branch overrides |
| [`visual_markdown_emoji`](examples/visual_markdown_emoji.typ) | markup and emoji in labels |
| [`visual_single`](examples/visual_single.typ) | a lone root |
| [`visual_empty`](examples/visual_empty.typ) | empty labels |
| [`visual_gallery`](examples/visual_gallery.typ) | every style against every edge |
| [`visual_technical`](examples/visual_technical.typ) | the `"technical"` style, role tags, `align-levels` |
| [`visual_bar`](examples/visual_bar.typ) | the `"bar"` style with the tapered edge |
| [`visual_block`](examples/visual_block.typ) | the `"block"` style with straight edges |
| [`visual_both`](examples/visual_both.typ) | `direction: "both"` |
| [`visual_surface`](examples/visual_surface.typ) | `surface: "all"` |
| [`visual_markers`](examples/visual_markers.typ) | role tags with a renamed tag |
| [`visual_justified`](examples/visual_justified.typ) | labels inside a justified, hyphenated document |

## Changelog

**0.3.0** — adds the `technical`, `bar` and `block` styles, `edge`, `direction`,
`align-levels`, `surface`, `markers`, `emphasis-labels`, `mono-font` and
`root-max-width`, and a fourth level of styling. **Output changes:** a label no
longer inherits the document's justification and hyphenation (a label inside a
justified document stops splitting words), and in `"outline"` the first-level
rule becomes a rounded capsule and the edges below the first level are drawn
lighter. A root longer than `node-max-width` now wraps at up to twice that
width (`root-max-width: auto`); pass `root-max-width` equal to `node-max-width`
(e.g. `6cm`) for the old layout. Nodes now sit exactly at their layout position
(a sub-point shift) and edges have round caps. `style: "boxed"` otherwise
renders what 0.2.0 rendered.

**0.2.0** — adds `style: "outline"`, the `branch` and `emphasis` attributes on
`node`, and the `ink` / `emphasis-colors` options. The default output is
unchanged: `style: "boxed"` renders exactly what 0.1.1 rendered.

**0.1.1** — long labels wrap instead of overflowing their measured width.

## Sponsor

<a href="https://elitus.com.br"><picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/elitus-dark.svg">
  <img alt="Elitus" src="https://raw.githubusercontent.com/pierryangelo/tidymind/v0.3.0/img/elitus-light.svg" width="96">
</picture></a>

tidymind is developed with support from [Elitus](https://elitus.com.br)
([@souelitus](https://instagram.com/souelitus) on Instagram).

## License

MIT
