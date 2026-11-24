---
number: 7
title: "The font parameters are read from the font's own MATH constants, and each is measured against its source"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:04:32+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/7
synced: 2026-11-24T12:18:48+01:00 c9de30418d2b
neutralized: 1
---

## What

List every parameter the layout uses (axis height, fraction rule thickness, script shifts, radical gaps, delimiter factors, and the rest of the MATH table constants) and where it comes from: the font table, or a fixed fallback with a reason. For each constant read from a font, measure it against the table bytes of a shipped font and record the value, the font and the table offset.

## Why

A parameter that is guessed instead of read gives a layout that looks plausible and is wrong for another font.

## Oracle first

The reference is the font file itself: the bytes at the table offset, read by an independent minimal reader in the test. Exact equality with the value the parser returns.

## Acceptance

A table lists every parameter with its source and a measured value for at least two fonts, a test compares the parser with the independent read, and a planted wrong offset is caught.
