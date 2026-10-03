// `markers: "role"` tags a node's role instead of recoloring it; tag text is overridable.
#import "@preview/tidymind:0.3.0": mindmap, node
#set page(width: auto, height: auto, margin: 10pt)
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
      node([Virtual circuit], node([e.g. `MPLS`], emphasis: "example")),
    ),
  ),
)
#mindmap(switching, style: "technical", markers: "role", emphasis-labels: (warning: "watch out"))
