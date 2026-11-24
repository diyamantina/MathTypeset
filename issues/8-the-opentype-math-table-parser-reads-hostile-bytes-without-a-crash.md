---
number: 8
title: "The OpenType MATH table parser reads hostile bytes without a crash"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:09:34+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/8
synced: 2026-11-24T12:18:48+01:00 22b08dfba1e9
neutralized: 1
---

## What

Build a corpus of malformed MATH tables and fonts: truncated tables, offsets outside the table, counts that claim more entries than fit, cycles in offsets, zero and maximal values. Each case has an exact expected error (the typed error that is thrown) and none may crash, hang or allocate without bound. State a bound on memory and time per byte of input.

## Why

The parser reads bytes from files the library does not control.

## Oracle first

The reference is the expected error per case, written before the run. Every case is classified accepted, rejected with a named error, or blocked with a reason.

## Acceptance

The corpus is committed, every case passes with its exact error, the bound is stated and tested, and a planted missing bounds check is caught.
