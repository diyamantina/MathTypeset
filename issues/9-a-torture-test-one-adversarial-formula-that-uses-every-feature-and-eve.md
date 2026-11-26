---
number: 9
title: "A torture test: one adversarial formula that uses every feature and every edge at once"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:10:05+01:00
updated: 2026-11-26T03:39:09+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/9
synced: 2026-11-26T03:39:09+01:00 38573d98a4e0
neutralized: 2
---

## What

In the spirit of the TeX trip test: one input document of formulas that exercises every command, every environment, nesting to the documented depth, empty groups, maximal sizes, malformed and hostile input. Its complete output (the parse tree, the linearized text and the layout boxes) is committed as the expected answer and compared byte for byte.

## Why

A single committed answer catches every change of behaviour, intended or not.

## Oracle first

The expected output is written and reviewed by hand once, then frozen; a change needs a reviewed diff of the expected file.

## Acceptance

The input and the expected output are committed, the test compares byte for byte, and a planted fault in any one rule turns it red.

## Comments

### Mihaela, 2026-11-24T13:23:11+01:00

Correction after reading the code on 2026-11-24. Comparing byte for byte needs a canonical serialization of the parse tree and the layout boxes, which does not exist (the types are only Equatable). The item must add it first. No nesting limit is defined or documented: the parser, linearizer and layout recurse without a bound, so the torture input needs a stated depth and a decision on what happens beyond it.

### Mihaela, 2026-11-26T03:39:09+01:00

Blocked by #2, the MathTypeset 1.0 oracle: the answer key comes before this item (see the checklist in #1).
