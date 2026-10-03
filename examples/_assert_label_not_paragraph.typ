// A node label is a label, not a paragraph. Inside a justified, hyphenated
// document (the common case for a mind map embedded in a report), the label
// used to inherit both: words split with a hyphen and gaps opened between
// them. And the root, capped at the leaves' width, broke mid-word too.
#import "../src/tree.typ": normalize
#import "../src/layout.typ": measure-tree
#set page(width: auto, height: auto)
#set text(lang: "pt", hyphenate: true)
#set par(justify: true)

#context {
  // "Comutação" would be split as "Comuta-ção" at this width when hyphenation leaks in.
  let root = [Técnicas de Comutação]
  let t = normalize((content: root, children: ((content: [x],),)))

  // The root gets its own cap: at 4cm for leaves and auto (8cm) for the root, it stays on one line.
  let m = measure-tree(t, 4cm, "Inter", 9pt, "outline", root-max-width: 8cm)
  let one-line = measure(text(font: "Inter", size: 9pt * 1.5, weight: "bold")[Técnicas de Comutação])
  assert(m.w < 8cm.pt(), message: "the root should fit its own cap")
  assert(m.w >= one-line.width.pt(), message: "the root should keep its natural width on one line")

  // A root longer than its cap wraps BETWEEN words: no hyphen means the
  // wrapped width never exceeds the cap and every line is a whole word.
  let long = normalize((content: [Comutação Comutação Comutação Comutação Comutação], children: ()))
  let ml = measure-tree(long, 4cm, "Inter", 9pt, "outline", root-max-width: 5cm)
  let word = measure(text(font: "Inter", size: 9pt * 1.5, weight: "bold")[Comutação]).height.pt()
  assert(ml.w <= 5cm.pt() + 0.1, message: "a long root is capped at root-max-width")
  assert(ml.h > word * 2, message: "a long root wraps onto more lines")
}
#[OK]
