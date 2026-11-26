---
number: 8
title: "The OpenType MATH table parser reads hostile bytes without a crash"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:09:34+01:00
updated: 2026-11-26T03:39:08+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/8
synced: 2026-11-26T03:39:08+01:00 cdac94dd7083
neutralized: 2
---

## What

Build a corpus of malformed MATH tables and fonts: truncated tables, offsets outside the table, counts that claim more entries than fit, cycles in offsets, zero and maximal values. Each case has an exact expected error (the typed error that is thrown) and none may crash, hang or allocate without bound. State a bound on memory and time per byte of input.

## Why

The parser reads bytes from files the library does not control.

## Oracle first

The reference is the expected error per case, written before the run. Every case is classified accepted, rejected with a named error, or blocked with a reason.

## Acceptance

The corpus is committed, every case passes with its exact error, the bound is stated and tested, and a planted missing bounds check is caught.

## Comments

### Mihaela, 2026-11-24T13:22:31+01:00

Correction after reading the code on 2026-11-24. Reads are bounds checked and no offset is followed recursively, so a hang from a cycle is not expected; the corpus should still prove it. The real risks to test: shared offsets (many construction offsets may point at one construction) can make the output grow roughly with the square of the input, and no overlap or total-size limit exists; the error type is internal and its reasons are free text, so an exact expected error needs a typed, public error first (see the API item). The MATH parser and the byte reader have no test at all today.

### Mihaela, 2026-11-26T03:39:08+01:00

Blocked by #2, the MathTypeset 1.0 oracle: the answer key comes before this item (see the checklist in #1).
