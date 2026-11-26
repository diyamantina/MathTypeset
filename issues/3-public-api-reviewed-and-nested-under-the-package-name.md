---
number: 3
title: "Public API reviewed and nested under the package name"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T09:55:10+01:00
updated: 2026-11-24T13:19:46+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/3
synced: 2026-11-24T13:19:46+01:00 dc030b01a4e3
neutralized: 2
---

## What

Every public type is nested as MathTypeset.Area.Name. Today the public types are flat names with a Math prefix (MathBox, MathNode, MathParser, MathLayout, MathLayoutMetrics, MathRun, MathColor, MathFontStyle, MathLinearizer, MathLayoutElement) and TrueType names (TrueTypeMathTable, TrueTypeMathTableParser, TrueTypeByteReader, TrueTypeFontError). Review each public symbol: keep, rename into a namespace that mirrors the folder, or make internal. Record the decision for each. This is a breaking change and belongs before 1.0, with a CHANGELOG entry and a migration table old name to new name.

## Why

The top namespace is the package name. After 1.0 a rename is a major version.

## Oracle first

The reference is the list of public symbols produced by the compiler for the target (the symbol graph), compared with the reviewed list in the repository.

## Acceptance

Every public symbol is nested under MathTypeset, one type per file named after the full nested name, the reviewed list is in the repository, the CHANGELOG carries the old to new table, and a check fails on a flat public name.

## Comments

### Mihaela, 2026-11-24T13:19:46+01:00

Correction after reading the code on 2026-11-24. TrueTypeFontError is internal, not public: the public MATH table parser throws a type consumers cannot name; decide whether it becomes public or the parser throws a public error. The review must also cover the nested public types that are not listed (MathParser.ParsedFormula, MathParser.ParseError, MathLayout.SymbolStyle, MathFontStyle.Variant and the twelve types nested in TrueTypeMathTable). The source folder is one flat folder, so there is no area folder to mirror yet: the migration creates the folders. Most of the public types are not Sendable (parser, linearizer, layout, byte reader, the MATH parser and table): decide each. The namespacing check today only counts file-scope types per file; it does not fail on a flat public name.
