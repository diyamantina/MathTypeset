---
number: 13
title: "The not-verified list shrinks to named limits"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:25:40+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/13
synced: 2026-11-24T12:18:48+01:00 97633ad89604
neutralized: 1
---

## What

Write the file that lists what is not verified, each with a name, a reason and a place: for example glyph drawing (the package never draws), the consumers' text measurement (the contract), fonts without a MATH table. Nothing is left as an unnamed gap. A check fails when a disabled or skipped test is not listed.

## Why

The 1.0 claim must say exactly what is not covered.

## Oracle first

The reference is the list of every disabled, skipped or conditional test and every documented assumption.

## Acceptance

One section lists every limit with a name and a reason, and a check fails when a disabled test or an assumption is missing from it.
