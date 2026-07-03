# Design

How a TeX-math string becomes a positioned, backend-neutral layout.

## Overview

MathTypeset deliberately splits math rendering into stages with narrow
contracts, so the package can stay free of platform frameworks and every
consumer keeps control of fonts and drawing.

## Stage 1: Parse

`MathParser` accepts a TeX-math subset: fractions, radicals, subscripts and
superscripts, accents, matrices, big operators, spacing commands, scaling and
fixed delimiters, `\text`, and an extended symbol set. It produces:

- a `MathNode` tree (`sequence`, `text`, `symbol`, `fraction`, `radical`,
  `scripts`, `accent`, `matrix`, `scaledDelimiter`, `space`), every case
  `Equatable` and `Sendable`;
- a linearized ASCII reading of the formula, suitable for accessibility
  companions such as PDF ActualText or hidden MathML.

Unsupported input throws a typed `ParseError` rather than degrading silently.

## Stage 2: Metrics

Math layout quality depends on the font's own opinion of math spacing.
`TrueTypeByteReader` provides bounds-checked big-endian access;
`TrueTypeMathTableParser` reads the OpenType `MATH` table into a
`TrueTypeMathTable` value (constants, glyph info, variants, kerns,
assemblies). `MathLayoutMetrics.openType(constants:unitsPerEm:)` converts the
font-unit constants into the point space of the formula. A `.default` metrics
set exists for fonts without a `MATH` table.

## Stage 3: Layout

`MathLayout` runs a box-and-glue pass over the tree. Each node becomes boxes
with width, height, and depth; glue and the MATH constants decide gaps,
shifts, and rule thicknesses. Symbols carry both a Unicode display form and an
ASCII fallback; `SymbolStyle` selects between them, including a
coverage-driven mode for fonts with partial symbol repertoires.

The radical sign is drawn as scaling vector strokes rather than a glyph, so it
grows with its radicand without requiring glyph assembly support.

## Stage 4: Emit

The output `MathBox` holds `width`, `height`, `depth`, and `elements`, where
every element is one of three drawing primitives:

- `.text(run:x:y:)`: a positioned `MathRun` (text, font style, size, color,
  baseline offset);
- `.rule(x:y:width:height:color:)`: an axis-aligned filled rectangle, used
  for fraction bars and overlines;
- `.line(x1:y1:x2:y2:thickness:color:)`: a straight stroked segment for
  shapes a rule cannot express, such as the diagonal strokes of the radical.

All coordinates are baseline-relative with +y up, in typographic points at the
formula's base size. Consumers draw the elements verbatim; no rescaling step
exists or is needed. This is what keeps output identical between backends,
the same `MathBox` feeds MarkdownPDF's PDF output and TileDown's SVG output.
