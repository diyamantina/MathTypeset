---
number: 12
title: "Literate: each correctness-critical algorithm has its reason, its invariant and a worked example in the DocC catalog"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:25:09+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/12
synced: 2026-11-24T12:18:48+01:00 aa2c8cd02021
neutralized: 1
---

## What

List the correctness-critical algorithms (the parser's precedence and recovery, the style cascade, the fraction and radical construction, script placement, delimiter growth, the MATH table read, the measurement contract). For each one: the reason, the invariant, the measurement next to the code, and a worked example with concrete numbers in the DocC catalog. Check that the MeasurementContract page matches the code.

## Why

A reader must be able to understand and re-implement the algorithm from the documentation.

## Oracle first

The reference is the worked example, computed by hand, which the same test reproduces.

## Acceptance

A list of the algorithms is in the documentation, each has its three parts and a worked example that a test reproduces, and the DocC catalog builds without warnings.
