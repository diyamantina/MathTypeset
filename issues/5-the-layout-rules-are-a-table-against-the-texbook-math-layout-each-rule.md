---
number: 5
title: "The layout rules are a table against the TeXbook math layout, each rule tested by a hand-computed example"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T09:55:13+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/5
synced: 2026-11-24T12:18:48+01:00 8c9389371010
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
