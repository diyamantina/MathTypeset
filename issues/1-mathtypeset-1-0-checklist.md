---
number: 1
title: "MathTypeset 1.0 checklist"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T09:55:09+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/1
synced: 2026-11-24T12:18:48+01:00 44dfab9d143a
neutralized: 1
---

## What

The checklist of everything that must be closed or decided before MathTypeset 1.0 is tagged. Each line is an issue labelled `before-1.0`.

### Gate

MathTypeset goes to 1.0 together with TileDown and MarkdownPDF. None of the three is released as 1.0 alone: TileDown 1.0 is released only when MathTypeset and MarkdownPDF each have their own 1.0 checklist done. The order of the releases is MathTypeset 1.0 first, then MarkdownPDF 1.0, then TileDown 1.0.

### First: the oracle

- [ ] #2 MathTypeset 1.0 oracle: the answer key of every correctness surface, stated before the work. The items marked "blocked by #2" below wait for it.

### Promise

- [ ] #3 Public API reviewed and nested under the package name
- [ ] #16 1.0 is frozen: bug fixes only after the last feature, and the public API is one reviewed file
- [ ] #15 Platforms, packaging and the release path

### Correctness (blocked by #2)

- [ ] #4 The grammar of the supported TeX subset is written, and every unsupported command is reported by name
- [ ] #5 The layout rules are a table against the TeXbook math layout, each rule tested by a hand-computed example
- [ ] #6 Layout arithmetic is integer, or a proof that the floating-point path is identical on every platform
- [ ] #7 The font parameters are read from the font's own MATH constants, and each is measured against its source
- [ ] #8 The OpenType MATH table parser reads hostile bytes without a crash
- [ ] #18 Spacing and any breaking claim are checked by a slow exhaustive reference on small inputs
- [ ] #9 A torture test: one adversarial formula that uses every feature and every edge at once
- [ ] #10 Determinism: the same input and version give byte-identical output on every machine

### Speed

- [ ] #11 Performance: measured rows with paired release numbers, and the decision on an Apple counterpart

### Documentation and release

- [ ] #12 Literate: each correctness-critical algorithm has its reason, its invariant and a worked example in the DocC catalog
- [ ] #13 The not-verified list shrinks to named limits
- [ ] #14 Gaps that the TileDown 1.0 work finds in MathTypeset
- [ ] #17 Errata log: every defect found after the 1.0 candidate is recorded

## Why

One place to see how far 1.0 is, and to tell a reader what is promised and what is not.

## Oracle first

The checklist is complete when every item above is closed and `issuesync --check` agrees. The reference for "every issue labelled `before-1.0` is on the list" is the host's own issue list filtered by that label; a labelled issue that is missing from the list, or a list item whose issue lacks the label, is a defect of this issue. The list is counted once at tagging time and that count is the floor.

## Acceptance

Every checkbox above is ticked, every linked issue is closed or has its decision written down, and `issuesync --repo . --check` prints nothing and exits 0.

## Not in scope

Work not tied to one of the issues above.
