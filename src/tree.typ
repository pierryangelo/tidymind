/// Substitui rótulo vazio por um marcador para não gerar nó nulo.
#let _nonempty(c) = {
  if c == [] or c == "" or c == none { [—] } else { c }
}

/// Remove leading empty nodes from an array. This is used to clean up the children of a node, which may have been generated with empty content.
#let _trim_array(arr) = {
  let trimmed = arr
  while trimmed.len() > 0 and trimmed.first() in ([ ], parbreak()) { let _ = trimmed.remove(0) }
  return trimmed
}

/// Normalizes any input into `(content, children, branch, emphasis)`.
/// Accepts a dictionary carrying `content` (plus optional attributes), or raw
/// content, which becomes a leaf.
///
/// `branch` is the INDEX of a branch color (1..n), for when the caller wants to
/// override the natural position; `emphasis` is the ROLE of the node. Both
/// arrive by NAME — the package is never handed a color, it resolves one.
#let normalize(n) = {
  if type(n) == dictionary and "content" in n {
    let children = n.at("children", default: ())
    return (
      content: _nonempty(n.content),
      children: children.map(normalize),
      branch: n.at("branch", default: none),
      emphasis: n.at("emphasis", default: none),
    )
  }
  let root = if "children" in n.fields() and n.children.filter(c => c not in ([ ], parbreak())).len() == 1 {
    _trim_array(n.children).first()
  } else { n }
  if root.func() == list.item {
    let (content, children, emphasis) = if "children" in root.body.fields() {
      let rest = _trim_array(root.body.children.filter(c => c.func() != list.item))
      if rest.first() == [#"["] {
        (_trim_array(rest.slice(3)).sum(), root.body.children.filter(c => c.func() == list.item), rest.at(1).text)
      } else { (rest.sum(), root.body.children.filter(c => c.func() == list.item), none) }
    } else { (root.body, (), none) }
    return (content: content, children: children.map(normalize), branch: none, emphasis: emphasis)
  }
  // conteúdo cru → folha
  (content: _nonempty(n), children: (), branch: none, emphasis: none)
}

/// Prunes the tree at `max-depth` (root = depth 0). Past the limit, children
/// are dropped — this is what keeps a runaway tree from growing a huge canvas.
#let prune(n, max-depth, depth: 0) = {
  if depth >= max-depth {
    return (..n, children: ())
  }
  (..n, children: n.children.map(c => prune(c, max-depth, depth: depth + 1)))
}
