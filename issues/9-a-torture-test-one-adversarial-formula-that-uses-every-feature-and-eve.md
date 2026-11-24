---
number: 9
title: "A torture test: one adversarial formula that uses every feature and every edge at once"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:10:05+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/9
synced: 2026-11-24T12:18:48+01:00 0fabe0e398e2
neutralized: 1
---

## What

In the spirit of the TeX trip test: one input document of formulas that exercises every command, every environment, nesting to the documented depth, empty groups, maximal sizes, malformed and hostile input. Its complete output (the parse tree, the linearized text and the layout boxes) is committed as the expected answer and compared byte for byte.

## Why

A single committed answer catches every change of behaviour, intended or not.

## Oracle first

The expected output is written and reviewed by hand once, then frozen; a change needs a reviewed diff of the expected file.

## Acceptance

The input and the expected output are committed, the test compares byte for byte, and a planted fault in any one rule turns it red.
