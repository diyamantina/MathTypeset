---
number: 18
title: "Spacing and any breaking claim are checked by a slow exhaustive reference on small inputs"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T12:18:28+01:00
updated: 2026-11-26T03:39:10+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/18
synced: 2026-11-26T03:39:10+01:00 488e62ca81d9
neutralized: 2
---

## What

Write a slow, obviously correct reference for the inter-atom spacing and for any claim the documentation makes about breaking or fitting a formula: for every atom class pair and every style, and for every small formula up to a stated size over a stated alphabet, the reference computes the spacing (and, if a claim of optimal breaking is made, the total cost of every possible break and the minimum). The shipped layout must equal the reference exactly on all of them. If the package does not break lines, the documentation says so and the claim is removed.

## Why

The spacing table and any optimal-fit claim are exactly the kind of rule where a plausible result is wrong for a corner. An exhaustive reference leaves no corner unchecked within its stated bound.

## Oracle first

The reference is the exhaustive enumeration itself; the equivalence is exact; the bound (formula size, alphabet) is stated and the count of cases checked is printed. Planted faults: swap two entries of the spacing table, drop a style rule, make a break cost off by one.

## Acceptance

The reference and its bound are committed, the shipped layout equals it on every enumerated case, each planted fault turns the check red, and the documentation states whether the package breaks lines.

## Comments

### Mihaela, 2026-11-24T13:25:56+01:00

Correction after reading the code on 2026-11-24. MathTypeset does not break lines (layout takes no width) and has no inter-atom spacing table, so this item has two parts: (1) state in the documentation that the package does not break lines, and remove any claim that implies it; (2) the exhaustive reference for spacing exists only after the layout rules item decides whether the spacing rules are implemented. Until then this item is blocked by that decision.

### Mihaela, 2026-11-24T13:37:09+01:00

Decision of 2026-11-24 on the scope: the exhaustive reference for the spacing returns to its original meaning, because the spacing table is implemented (see issue 5). Line breaking is a separate named slice of the engine: it is in 1.0 or it is a named limit, decided after the layout rules are done; until then the documentation says that the package does not break lines.

### Mihaela, 2026-11-26T03:39:10+01:00

Blocked by #2, the MathTypeset 1.0 oracle: the answer key comes before this item (see the checklist in #1).
