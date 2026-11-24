---
number: 5
title: "The layout rules are a table against the TeXbook math layout, each rule tested by a hand-computed example"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T09:55:13+01:00
updated: 2026-11-24T13:36:28+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/5
synced: 2026-11-24T13:36:28+01:00 54d18196777f
neutralized: 1
---

## What

Write the layout rules as a table against the TeXbook chapter on math layout and its appendix: atom classes, the style cascade (display, text, script, scriptscript and the cramped forms), the inter-atom spacing table, fractions, radicals, scripts and limits, delimiters, accents. For each row: the rule, the source section, the parameter it uses, and a test whose expected numbers are computed by hand from the font constants and stated in the test.

## Why

A layout engine is correct only against a stated authority. The authority here is the published algorithm, not the previous output of the engine.

## Oracle first

The reference is the published rules plus hand-computed boxes for small inputs (a fraction, a square root, a superscript and subscript, a spaced relation, a matrix cell). Equivalence is exact on the stated units. Planted faults: swap two rows of the spacing table, drop the cramped style of a denominator, use the wrong parameter for a script shift.

## Acceptance

A table in the documentation lists every rule with its source and its test, every row has a hand-computed example, and each planted fault turns a test red.

## Comments

### Mihaela, 2026-11-24T13:21:09+01:00

Correction after reading the code on 2026-11-24, and a decision this item needs first. The engine does not have what this item tests: there are no atom classes, no inter-atom spacing table, no four-level style cascade and no cramped style (style is one display-or-text flag; child sizes are fixed factors), and left and right delimiters do not grow (only the big family with fixed factors and matrix fences scale). So the item has two parts: (1) decide, rule by rule, whether MathTypeset implements the TeXbook rule or names it as a limit in the documentation; (2) for each implemented rule, the table and its hand-computed example. The planted faults that name a spacing table or a cramped style apply only to rules that get implemented.

### Mihaela, 2026-11-24T13:36:28+01:00

Decision of 2026-11-24 on the scope: MathTypeset 1.0 includes a TeX-grade layout engine, so this item returns to its original meaning. The rules of the TeXbook (atom classes, the inter-atom spacing table, the style cascade with cramped forms, growing delimiters, fractions, radicals, scripts and limits, accents) are implemented rule by rule, each as a row of the table with its source and a test whose expected numbers are computed by hand from the book's own worked cases. The correction comment above stays as the record of what the code did not have on that day. The slices and their order are in the tracking issue.
