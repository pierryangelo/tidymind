// #import "@preview/tidymind:0.3.0": mindmap, node
#import "../lib.typ": mindmap, node
#set page(width: auto, height: auto, margin: 10pt)
#let switching = [
  - Network switching
    - Circuit switching
      - Dedicated channel
        - `FDM` splits the frequency band
        - `TDM` splits time into slots
      - Setup, transfer and teardown
      - [warning] Idle time wastes reserved bandwidth
    - Message switching
      - [definition] Whole-message store-and-forward
      - No fragmentation
    - Packet switching
      - Statistical multiplexing
      - Modes
        - Datagram (connectionless)
        - Virtual circuit
          - [example] `MPLS`, Frame Relay
]
#mindmap(switching, style: "bar", edge: "tapered", markers: "role")
