# ``MathTypesetDocumentation``

@Metadata {
    @DisplayName("MathTypeset")
}

A small, dependency-free Swift package that typesets a TeX-math subset into a
neutral, positioned layout.

## Overview

MathTypeset parses `\frac`, `\sqrt`, scripts, accents, matrices, big operators,
scaling and fixed delimiters, and an extended symbol set, then lays them out
with a box-and-glue engine driven by an OpenType `MATH` table. The result is a
backend-neutral `MathBox` that any consumer can emit to PDF, SVG, or MathML.

The engine is extracted from the
[MarkdownPDF](https://codeberg.org/MarkdownPdfHQ/MarkdownPDF) renderer so it
can be shared with other projects without duplicating the layout and metrics
work.

- Pure Swift, only `Foundation`. No PDF, AppKit, CoreGraphics, UIKit, or C
  libraries.
- Builds and tests on macOS and Linux.
- The package never renders pixels and never reads glyph outlines or `hmtx`
  advances. Font measurement and emission are the consumer's job; see
  <doc:MeasurementContract>.

## The pipeline

A formula travels four stages, described in <doc:Design>:

1. **Parse**: `MathParser` turns a TeX-math string into a `MathNode` tree and
   a linearized ASCII reading for accessibility.
2. **Metrics**: `TrueTypeMathTableParser` reads the font's OpenType `MATH`
   table; `MathLayoutMetrics.openType(constants:unitsPerEm:)` normalizes its
   constants into point space.
3. **Layout**: `MathLayout` positions every run, rule, and stroke with a
   box-and-glue pass, returning a `MathBox`.
4. **Emit**: the consumer walks `MathBox.elements` and draws each `.text`,
   `.rule`, and `.line` element in its own backend.

## Public surface

- `MathParser().parse(_:)` returning a parsed formula with its `MathNode` root
- `MathLayout(font:color:measureText:metrics:).layout(_:size:displayStyle:)`
- `MathBox`, `MathLayoutElement`, `MathRun`, `MathFontStyle`, `MathColor`
- `MathLayoutMetrics.openType(constants:unitsPerEm:)` and `.default`
- `TrueTypeMathTableParser(bytes:numGlyphs:).parse()` returning a
  `TrueTypeMathTable`

## Topics

### Design

- <doc:Design>
- <doc:MeasurementContract>
