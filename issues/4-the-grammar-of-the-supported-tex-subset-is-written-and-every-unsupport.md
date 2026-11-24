---
number: 4
title: "The grammar of the supported TeX subset is written, and every unsupported command is reported by name"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T09:55:11+01:00
updated: 2026-11-24T13:20:27+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/4
synced: 2026-11-24T13:20:27+01:00 314da6046391
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

## Comments

### Mihaela, 2026-11-24T13:20:27+01:00

Correction after reading the code on 2026-11-24. No parse error carries a position today, so the acceptance must add it (a position in the source text). There is no list of unsupported control words to review: the list has to be written. Silent behaviour to decide, each as supported, error or named limit: an end of an environment is not compared with its begin; an ampersand, tilde, percent or hash outside a matrix becomes literal text; a scaled delimiter given as a dot yields an empty node; a trailing lone backslash reports an empty command name; control words accept any Unicode letter.
