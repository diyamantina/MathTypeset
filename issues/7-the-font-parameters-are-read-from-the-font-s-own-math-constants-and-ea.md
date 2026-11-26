---
number: 7
title: "The font parameters are read from the font's own MATH constants, and each is measured against its source"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:04:32+01:00
updated: 2026-11-26T03:39:07+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/7
synced: 2026-11-26T03:39:07+01:00 dafd6eef5442
neutralized: 2
---

## What

List every parameter the layout uses (axis height, fraction rule thickness, script shifts, radical gaps, delimiter factors, and the rest of the MATH table constants) and where it comes from: the font table, or a fixed fallback with a reason. For each constant read from a font, measure it against the table bytes of a shipped font and record the value, the font and the table offset.

## Why

A parameter that is guessed instead of read gives a layout that looks plausible and is wrong for another font.

## Oracle first

The reference is the font file itself: the bytes at the table offset, read by an independent minimal reader in the test. Exact equality with the value the parser returns.

## Acceptance

A table lists every parameter with its source and a measured value for at least two fonts, a test compares the parser with the independent read, and a planted wrong offset is caught.

## Comments

### Mihaela, 2026-11-24T13:21:50+01:00

Correction after reading the code on 2026-11-24. Many layout parameters are fixed constants even when the font has a MATH table (text height and depth, child size factors, paddings, the radical gap, the accent gap and size, matrix gaps), the delimiter factors are hard-coded in the parser and the matrix layout, a constant of zero or below is treated as absent and replaced by a fallback, and 36 of the 51 value records are parsed and never used. The table of this item must list every parameter in one of three states: read from the font, fixed constant with its reason, parsed and unused. No font file is tracked in the repository, so the measured fonts and their licences must be chosen and recorded; and the parser receives the MATH table bytes, not a font file, so the table offset is outside this package.

### Mihaela, 2026-11-26T03:39:07+01:00

Blocked by #2, the MathTypeset 1.0 oracle: the answer key comes before this item (see the checklist in #1).
