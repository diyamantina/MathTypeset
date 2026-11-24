# MathTypeset 1.0: where the work stands, 2026-11-24

For whoever works on MathTypeset next, so that the work starts from this file and not from anyone's memory. Labels: MEASURED (read from a file or counted, with its path), DOCUMENTED (a document says it), UNVERIFIED (not run or not read). Nothing in this file was built or run: every statement about the code comes from reading it.

## 1. The decision that shapes everything

MathTypeset 1.0 includes a TeX-grade layout engine. The three libraries TileDown, MarkdownPDF and MathTypeset go to 1.0 together, and the release waits for the engine. The reason is the rule that the better route for the person using the product wins, even when it is harder or slower to build: a formula that looks wrong is the user-facing flaw of a math library. The decision can be reversed until the engine work starts. The estimate for the engine is 6 to 10 weeks of focused work (UNVERIFIED: nothing has been built).

The order of the three releases is MathTypeset 1.0, then MarkdownPDF 1.0, then TileDown 1.0. Before the engine work, the extended Markdown is extracted from MarkdownPDF into its own package with the current math output unchanged, so that the byte-for-byte corpus has a baseline; the corpus is then re-baselined once, and each engine slice re-baselines the formula pictures on purpose with a reviewed diff.

## 2. What the code is today (MEASURED by reading the sources)

- One target, `Sources/MathTypeset`, 14 files, one public type per file, flat names with a `Math` prefix (`MathBox`, `MathNode`, `MathParser`, `MathLayout`, `MathLayoutMetrics`, `MathRun`, `MathColor`, `MathFontStyle`, `MathLinearizer`, `MathLayoutElement`) and `TrueTypeMathTable`, `TrueTypeMathTableParser`, `TrueTypeByteReader`. `TrueTypeFontError` is internal, so the public MATH table parser throws a type consumers cannot name. Every file imports only Foundation.
- The parser turns a TeX math subset into a `MathNode` tree; the layout turns it into a positioned `MathBox`; the linearizer turns it into plain text. Layout takes no width and does not break lines.
- Layout is floating point (`Double`) throughout, one path, with no slow reference.
- The layout reads 15 of the 51 value records of the font's MATH table (plus `scriptPercentScaleDown` and `displayOperatorMinHeight`); 36 records and `scriptScriptPercentScaleDown` are parsed and never used. Many other parameters are fixed constants (text height 0.72 and depth 0.22, child size factors, paddings, the radical gap, accent gap and size, matrix gaps). A constant of zero or below is treated as absent and replaced by a fallback.
- It has NO atom classes, NO inter-atom spacing table, NO four-level style cascade and no cramped form (style is one display-or-text flag; child sizes are fixed factors), and `\left ... \right` does not grow (only the `\big` family with fixed factors and matrix fences scale). These are what the engine adds.
- Parser behaviour that is silent today: an environment end is not compared with its begin; `&`, `~`, `%` and `#` outside a matrix become literal text; a scaled delimiter given as a dot yields an empty node; a trailing lone backslash reports an empty command name; control words accept any Unicode letter. No parse error carries a position.
- Tests: 25 (13 parser, 12 layout), Swift Testing, none disabled. No test reaches the MATH table parser or the byte reader. No font file is tracked in the repository. The layout tests use `@testable import`.
- Documentation: a DocC catalogue with `Design.md`, `MeasurementContract.md` and the landing page. Two defects: the measurement contract and the README say `baselineOffset` is used for scripts, but the layout never sets it; the README usage example does not compile (its `switch` omits the `.line` case of the layout element).
- Packaging: AGPL plus commercial terms (`LICENSE`, `COMMERCIAL.md`); macOS and Linux workflows build and test; tags 0.1.0 to 0.4.0 are annotated and 0.5.0 to 0.7.0 are lightweight; no release steps are documented; the manifest depends on the DocC plugin hosted on GitHub and declares no platforms.

## 3. The issues (the list lives in the host's issue tracker and in `issues/`)

- Tracking: issue 1 (the checklist, the cross-library gate, the engine plan). Oracle first: issue 2 (the answer key of every correctness surface, stated before the work).
- Engine: issue 5 (the layout rules as a table against the TeXbook, each rule tested by a hand-computed example), issue 18 (a slow exhaustive reference for spacing and for any breaking claim), issue 6 (integer arithmetic, or a proof that the floating-point path is identical on every platform), issue 7 (the font parameters read from the MATH constants, each measured against its source).
- Safety and quality: issue 3 (public API reviewed and nested under the package name), issue 4 (the grammar and every unsupported command reported by name, with a position), issue 8 (hostile MATH table bytes, with exact typed errors), issue 9 (a torture test), issue 10 (determinism).
- Release: issues 11 (performance), 12 (literate documentation), 13 (the not-verified list), 14 (gaps found by TileDown), 15 (platforms, packaging and the release path), 16 (the freeze and the reviewed API file), 17 (the errata log).
- Each issue carries correction comments written after an independent read of the code on 2026-11-24; read the comments with the body.

## 4. The oracle plan (what to write before any engine code)

1. The rules as a table: atom classes, the style cascade (display, text, script, scriptscript and the cramped forms), the inter-atom spacing table, fractions, radicals, scripts and limits, delimiters, accents, each with its source section in the book and the parameter it uses.
2. For each row a test whose expected numbers are computed by hand from the font constants and written in the test, from the book's own worked cases where it has them.
3. A slow exhaustive reference for the spacing: every atom class pair in every style, and every small formula up to a stated size over a stated alphabet; the shipped layout must equal it exactly.
4. The font side: the MATH table reader gets its tests first (an independent minimal reader of the table bytes in the test, exact equality with the parser), and a hostile-bytes corpus with exact typed errors.
5. Planted faults that must turn each check red: swap two entries of the spacing table, drop the cramped form of a denominator, use the wrong parameter for a script shift.
6. A canonical serialization of the parse tree and the layout boxes, so that the torture test and the determinism check can compare bytes (it does not exist today).

## 5. Slices, in the order of visible value (estimates are UNVERIFIED)

0. The oracle and the font-table reader tests (1 week).
1. Atom classes and the inter-atom spacing table (2 weeks).
2. The style cascade with cramped forms (1.5 weeks).
3. Growing delimiters for left and right (1 week).
4. The remaining Appendix G rules (2 weeks).
5. Line breaking as its own named slice: it is in 1.0 or a named limit, decided after slice 4 (2 to 3 weeks if in).

## 6. Facts about the consumers

- MarkdownPDF hands formulas to MathTypeset through one adapter (`MathTypesetAdapter`) and measures text itself; MarkdownPDF currently depends on MathTypeset by branch, and at 1.0 by a released version.
- TileDown shows formulas in pages through the same package (the TileDown issue for math formulas in pages waits for the engine).
- The measurement contract (`MeasurementContract.md`) is the interface to every consumer: the consumer supplies text measurement and the package never draws.

## 7. Rules of the work

- The top namespace is the package name; every public type is nested as `MathTypeset.Area.Name`, one type per file named after the full nested name. The migration from the flat names is issue 3 and is breaking: it belongs before 1.0.
- The package stays pure: Foundation only, no Apple framework; an Apple counterpart is decided by a paired release measurement (issue 11).
- Oracle first: the answer key is stated before the production change; exact equality unless a tolerance is derived and named; every case handled, failed, unsupported, intentionally divergent, ineligible or blocked, never skipped silently.
- No external tools to read or check results; own tools plus `git`, `swift build` and `swift test`. No em dashes. Every push to a shared branch is approved for one exact hash and goes through the repository's own hook.
- The repository's hook runs `swift build && swift test` with the default package cache; in a fresh worktree the first build can fail with "unable to read tree" when two runs write the shared cache at once. Pre-resolve the dependencies in the worktree with a private `--cache-path`, or run one build at a time.

## 8. Not read and not done

The bodies of the two test files beyond their names; the MATH table value records one by one; any consumer's use of the package beyond the adapter; any build or run. No font file is chosen for the measurements yet, and its licence must be recorded.
