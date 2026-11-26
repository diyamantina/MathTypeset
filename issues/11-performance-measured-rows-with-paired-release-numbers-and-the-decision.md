---
number: 11
title: "Performance: measured rows with paired release numbers, and the decision on an Apple counterpart"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:11:07+01:00
updated: 2026-11-24T13:23:52+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/11
synced: 2026-11-24T13:23:52+01:00 15d127cd6fa9
neutralized: 2
---

## What

Measure the layout of a fixed set of formulas (a single symbol, the quadratic formula, a large matrix, a long sum with limits) in a release build: old and new back to back, medians, load printed, machine named. Record the rows in the repository. The package is pure (no Apple frameworks); state whether an Apple counterpart (SIMD, Accelerate) would give a measured gain and decide by the paired number, with a differential test if one is added.

## Why

A claim of speed needs a number, and a guessed win is not made.

## Oracle first

The reference is the slow, obviously correct path kept as the answer key; the optimized path must equal it exactly.

## Acceptance

The rows are in the repository with the machine, load and date, a decision on the counterpart is written, and no optimization is merged without its paired number.

## Comments

### Mihaela, 2026-11-24T13:23:52+01:00

Correction after reading the code on 2026-11-24. There is one layout path and no benchmark target, so there is no old and new pair and no slow reference to keep. The item starts by adding the benchmark target and the reference formulas, then measures the single path; an optimized path is only added when a measurement names a share worth removing.
