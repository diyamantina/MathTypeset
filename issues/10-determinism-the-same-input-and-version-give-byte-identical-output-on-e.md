---
number: 10
title: "Determinism: the same input and version give byte-identical output on every machine"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:10:36+01:00
updated: 2026-11-26T03:39:09+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/10
synced: 2026-11-26T03:39:09+01:00 99a878ee4c86
neutralized: 2
---

## What

Check that the layout and the linearizer give the same output for the same input on macOS and Linux, on a second run, and under a different locale and working directory: no dates, no paths, no dictionary or set iteration order, no locale dependent formatting.

## Why

Downstream documents are compared byte for byte.

## Oracle first

The reference is the committed expected output of the torture test, run on both platforms and twice.

## Acceptance

A test runs the torture input twice in one process and compares, a script runs it on both platforms and compares the hashes, and a planted dictionary order dependence is caught.

## Comments

### Mihaela, 2026-11-26T03:39:09+01:00

Blocked by #2, the MathTypeset 1.0 oracle: the answer key comes before this item (see the checklist in #1).
