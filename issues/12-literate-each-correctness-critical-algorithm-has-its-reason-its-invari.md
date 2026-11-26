---
number: 12
title: "Literate: each correctness-critical algorithm has its reason, its invariant and a worked example in the DocC catalog"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:25:09+01:00
updated: 2026-11-24T13:24:34+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/12
synced: 2026-11-24T13:24:34+01:00 b6042f0d85f7
neutralized: 2
---

## What

List the correctness-critical algorithms (the parser's precedence and recovery, the style cascade, the fraction and radical construction, script placement, delimiter growth, the MATH table read, the measurement contract). For each one: the reason, the invariant, the measurement next to the code, and a worked example with concrete numbers in the DocC catalog. Check that the MeasurementContract page matches the code.

## Why

A reader must be able to understand and re-implement the algorithm from the documentation.

## Oracle first

The reference is the worked example, computed by hand, which the same test reproduces.

## Acceptance

A list of the algorithms is in the documentation, each has its three parts and a worked example that a test reproduces, and the DocC catalog builds without warnings.

## Comments

### Mihaela, 2026-11-24T13:24:34+01:00

Correction after reading the code on 2026-11-24. The list of algorithms must match what exists: the parser has no precedence rules and no recovery (it throws at the first error), there is no style cascade (see the layout rules item) and delimiter growth is only for matrix fences and the big family. Two documentation defects to fix in this item: the measurement contract page and the README say baselineOffset is used for scripts, but the layout never sets it (scripts move through element positions); and the README usage example does not compile because its switch omits the line case of the layout element, and its public surface list omits that case, the linearizer, the byte reader and the symbol style API. The documentation workflow builds the catalogue but does not fail on warnings.
