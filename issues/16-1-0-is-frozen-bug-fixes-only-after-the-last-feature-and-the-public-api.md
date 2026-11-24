---
number: 16
title: "1.0 is frozen: bug fixes only after the last feature, and the public API is one reviewed file"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:27:12+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/16
synced: 2026-11-24T12:18:48+01:00 6aba6f3b8271
neutralized: 1
---

## What

State the freeze point in this checklist: after the last feature item closes, the package takes bug fixes only until 1.0. List the whole public API in one reviewed file in the repository and add a check that fails on any public symbol that is not in it.

## Why

A frozen API is what a 1.0 version promises.

## Oracle first

The reference is the compiler's own symbol list for the target compared with the reviewed file.

## Acceptance

The reviewed API file exists, the check fails on an unlisted public symbol (planted and caught), and the freeze point is dated.
