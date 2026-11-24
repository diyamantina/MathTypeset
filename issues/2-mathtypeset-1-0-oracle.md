---
number: 2
title: "MathTypeset 1.0 oracle"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T09:55:10+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/2
synced: 2026-11-24T12:18:48+01:00 a278d035bdec
neutralized: 1
---

## What

State, before any production work of the 1.0 series, the answer key of every correctness surface of the package. The surfaces, read from the code: (1) the parser, which turns a TeX math subset into a MathNode tree; (2) the linearizer, which turns the tree into plain text; (3) the layout, which turns the tree into a positioned MathBox with the box-and-glue rules; (4) the OpenType MATH table parser, which reads constants from font bytes; (5) the metrics, which turn those constants into layout parameters. For each surface write: the correctness question; the input domain; the authority (a closed form, a slow reference, a differential path, a live platform witness, an evidence ledger); the equivalence relation (exact by default, a derived or measured and named tolerance only); the failure report; the classification of every case (handled, failed, unsupported, intentionally divergent, ineligible, blocked, with no silent skip); the negative controls (a planted fault that must turn the check red); and the parity of any optimized path with the slow path. List which 1.0 items are blocked until their oracle exists.

## Why

Without an answer key, a passing test only says the code agrees with itself. Every item below that makes a correctness claim needs this first.

## Oracle first

This issue is the oracle: the reference is the oracle-first rule applied surface by surface, and the check is a document in the repository with one section per surface and a test that fails when a surface has no section.

## Acceptance

A document in the repository names the five surfaces above (and any the code review adds) with every field listed, a test fails when a section is missing or empty, and the issues blocked on it say so in a comment.
