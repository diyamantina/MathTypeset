# The measurement contract

The load-bearing agreement between MathTypeset and its consumer.

## Overview

The layout never measures glyphs itself; it calls the consumer's
`measureText` closure and trusts the result. For the layout and the
MATH-table metrics to agree, three clauses must hold.

## The clauses

- `measureText(run)` returns the **advance width of `run.text`, set in
  `run.font` at `run.size`, in typographic points** (the same space `run.size`
  is in).
- `MathLayoutMetrics.openType(constants:unitsPerEm:)` must be given the
  `unitsPerEm` of the **same font** the consumer measures against, so the
  MATH constants (font units) normalize to the same point space the advances
  use.
- The resulting `MathBox` (`width`, `height`, `depth`) and every element
  coordinate are in **points at the formula's base size**. Emit at those
  coordinates directly; do not rescale.

## Why it is strict

If the consumer measures with one font but passes another font's
`unitsPerEm`, or measures in a different unit than `run.size`, advances and
metrics disagree and the output drifts: fraction bars miss their numerators,
scripts collide, delimiters stop matching their content. Measure and feed
metrics from one font artifact.

## Baselines

`baselineOffset` on a `MathRun` shifts that run vertically from the run's
baseline (used for scripts). `MathBox.depth` is the extent below the
baseline, which is what a consumer needs to baseline-align inline math with
surrounding prose.
