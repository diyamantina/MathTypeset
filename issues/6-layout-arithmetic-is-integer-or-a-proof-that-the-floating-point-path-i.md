---
number: 6
title: "Layout arithmetic is integer, or a proof that the floating-point path is identical on every platform"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:04:02+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/6
synced: 2026-11-24T12:18:48+01:00 fcceef4657ee
neutralized: 1
---

## What

Decide how the layout computes lengths. Either use fixed-point integer units (the way TeX uses scaled points) so the same input gives the same boxes on every platform, or write the proof and the test that the floating-point operations used are identical on macOS and Linux for the supported inputs (no fused multiply-add differences, no library functions whose result differs). State the decision and its status label: theorem, bounded, sampled or witnessed.

## Why

Layout that differs by one unit between platforms breaks byte-identical output downstream (documents and PDFs).

## Oracle first

The slow reference is exact rational arithmetic on small inputs. The optimized path is the shipped one; the check compares them for a generated set of formulas with a recorded seed and fails on any difference.

## Acceptance

The decision is written with its evidence, a differential test against exact arithmetic passes for the seeded set on macOS and Linux, and a planted rounding fault is caught.
