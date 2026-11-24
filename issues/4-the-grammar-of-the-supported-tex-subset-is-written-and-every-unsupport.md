---
number: 4
title: "The grammar of the supported TeX subset is written, and every unsupported command is reported by name"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T09:55:11+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/4
synced: 2026-11-24T12:18:48+01:00 161b11598314
neutralized: 1
---

## What

Write the grammar of the supported subset (commands, environments, scripts, delimiters, accents, spacing) in the documentation, with each production tied to a parser test. State what the parser does for a command outside the subset: it must throw a named error that carries the command and the position, never fall back silently. Review the list of unsupported control words and decide for each: add, or name it as a limit.

## Why

A consumer must know exactly which formulas typeset and which are refused. A silent fallback is a hidden defect.

## Oracle first

The reference is the written grammar. Generated cases: every production, every command of the documented list, and every control word of a published list of common math commands, each classified supported or unsupported with the error it gives.

## Acceptance

The grammar document exists, a test walks every production, a table of common commands lists each as supported or as a named limit, and an unknown command throws an error that names it and its position.
