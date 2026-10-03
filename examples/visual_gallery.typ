// Every style against every edge, on one small tree.
#import "@preview/tidymind:0.3.0": mindmap, node
#set page(width: auto, height: auto, margin: 10pt)
#set text(font: "Inter", size: 8pt)
#let small = node([Topic], node([Branch A], node([Point]), node([Point])), node([Branch B], node([Point])))
#grid(
  columns: 4, gutter: 14pt, align: center + horizon,
  [], [*curved*], [*straight*], [*tapered*],
  ..("boxed", "outline", "technical", "bar", "block").map(style => (
    [*#style*],
    ..("curved", "straight", "tapered").map(edge => mindmap(small, style: style, edge: edge, text-size: 7pt, h-gap: 22pt, v-gap: 5pt)),
  )).flatten(),
)
