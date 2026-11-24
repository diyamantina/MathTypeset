# The oracle: the answer key of every correctness surface of MathTypeset

Status: written before any engine work of the 1.0 series (issue 2). It states, for each surface, what is checked against what, and what is not checked at all. Nothing here changes behaviour. Labels: MEASURED (read in a file or a run, with the path), DOCUMENTED (a document says it), UNVERIFIED (not read or not run).

The nine fields of every section are the same: the question, the input domain, the authority, the equivalence, the failure report, the classification of every case, the negative controls, the parity with any optimized path, and the status.

## 1. The font table reader (the MATH table and its byte reader)

- **Question:** does the reader return exactly the values the font's bytes hold, and refuse any other bytes with a named error and no crash?
- **Input domain:** the bytes of an OpenType MATH table: the header, MathConstants (4 fields, 51 value records, 1 field: 214 bytes), MathGlyphInfo (italics corrections, top accent attachments, extended shapes, kerns), MathVariants (vertical and horizontal constructions with variants and assemblies), and coverage tables of formats 1 and 2. Files: `Sources/MathTypeset/TrueTypeMathTableParser.swift`, `TrueTypeByteReader.swift`.
- **Authority:** a table built byte by byte from a closed form in the test (`Tests/MathTypesetTests/MathTableFixture.swift`): every constant is `100 + 3 * place`, every glyph list is written out, every offset is a named constant; and an independent read of the same bytes at `8 + 4 * place` from the start of MathConstants, which does not use the parser. The order of the 51 records is written out in the test in the order of the OpenType specification, not derived from the enumeration under test.
- **Equivalence:** exact (integers).
- **Failure report:** `TrueTypeFontError.truncated(table, offset, needed, tableLength)` for a read past the end, and `TrueTypeFontError.malformedTable(tag, reason)` with the reason as a fixed string; a case of the corpus names its exact error.
- **Classification:** accepted, or rejected with a named error. MEASURED (one run on 2026-11-24, 44 tests in 5 suites, all passed, no compile error; `MathTableHostileBytesTests`): 21 named cases with exact errors, two named cases of the widest coverage ranges (the bound is derived in `Knowledge/math-table-reader.md`), the table cut at every length short of the whole (each rejected with a named error), and every byte of the table set to 0xFF and to 0x00 (each accepted or rejected with a named error, none a crash).
- **Negative controls:** a table with the 51 records written one place late must disagree with the closed form at every place (`plantedLateRecords`). MEASURED (three faults planted in the production code of a copy, one at a time, each reverted, and the clean tree run green afterwards): (a) the count-match guard of `parseGlyphValues` removed: 1 test red, the case `an italics count of 4 for a coverage of 3 glyphs`; (b) `scriptScriptPercentScaleDown` read at offset + 4: 1 test red, `the four leading fields and the trailing percent are read from their own bytes`; (c) two cases of the constants enumeration swapped: 3 issues in 2 tests red, the order test and the table of the oracle document. The closed-form test of the constants does NOT see fault (c), because it walks the enumeration with its own index: it is the order test, with the order written out, that sees it.
- **Parity:** not applicable.
- **Status:** tests are written for the constants, the italics corrections, the extended shapes, the variants and the assemblies; they passed on their first run (MEASURED, above). NOT covered yet: MathKern records (the strictly increasing heights rule), top accent attachments, horizontal constructions, a coverage of format 2 with several ranges, a real font (no font file is tracked in the repository), and the Device tables behind a non-zero device offset (only the offset range is checked).

The 51 value records of MathConstants, their place, their byte offset from the start of the table in the fixture, and the value of the closed form:

| place | name | byte offset | closed form |
|---|---|---|---|
| 0 | mathLeading | 18 | 100 |
| 1 | axisHeight | 22 | 103 |
| 2 | accentBaseHeight | 26 | 106 |
| 3 | flattenedAccentBaseHeight | 30 | 109 |
| 4 | subscriptShiftDown | 34 | 112 |
| 5 | subscriptTopMax | 38 | 115 |
| 6 | subscriptBaselineDropMin | 42 | 118 |
| 7 | superscriptShiftUp | 46 | 121 |
| 8 | superscriptShiftUpCramped | 50 | 124 |
| 9 | superscriptBottomMin | 54 | 127 |
| 10 | superscriptBaselineDropMax | 58 | 130 |
| 11 | subSuperscriptGapMin | 62 | 133 |
| 12 | superscriptBottomMaxWithSubscript | 66 | 136 |
| 13 | spaceAfterScript | 70 | 139 |
| 14 | upperLimitGapMin | 74 | 142 |
| 15 | upperLimitBaselineRiseMin | 78 | 145 |
| 16 | lowerLimitGapMin | 82 | 148 |
| 17 | lowerLimitBaselineDropMin | 86 | 151 |
| 18 | stackTopShiftUp | 90 | 154 |
| 19 | stackTopDisplayStyleShiftUp | 94 | 157 |
| 20 | stackBottomShiftDown | 98 | 160 |
| 21 | stackBottomDisplayStyleShiftDown | 102 | 163 |
| 22 | stackGapMin | 106 | 166 |
| 23 | stackDisplayStyleGapMin | 110 | 169 |
| 24 | stretchStackTopShiftUp | 114 | 172 |
| 25 | stretchStackBottomShiftDown | 118 | 175 |
| 26 | stretchStackGapAboveMin | 122 | 178 |
| 27 | stretchStackGapBelowMin | 126 | 181 |
| 28 | fractionNumeratorShiftUp | 130 | 184 |
| 29 | fractionNumeratorDisplayStyleShiftUp | 134 | 187 |
| 30 | fractionDenominatorShiftDown | 138 | 190 |
| 31 | fractionDenominatorDisplayStyleShiftDown | 142 | 193 |
| 32 | fractionNumeratorGapMin | 146 | 196 |
| 33 | fractionNumDisplayStyleGapMin | 150 | 199 |
| 34 | fractionRuleThickness | 154 | 202 |
| 35 | fractionDenominatorGapMin | 158 | 205 |
| 36 | fractionDenomDisplayStyleGapMin | 162 | 208 |
| 37 | skewedFractionHorizontalGap | 166 | 211 |
| 38 | skewedFractionVerticalGap | 170 | 214 |
| 39 | overbarVerticalGap | 174 | 217 |
| 40 | overbarRuleThickness | 178 | 220 |
| 41 | overbarExtraAscender | 182 | 223 |
| 42 | underbarVerticalGap | 186 | 226 |
| 43 | underbarRuleThickness | 190 | 229 |
| 44 | underbarExtraDescender | 194 | 232 |
| 45 | radicalVerticalGap | 198 | 235 |
| 46 | radicalDisplayStyleVerticalGap | 202 | 238 |
| 47 | radicalRuleThickness | 206 | 241 |
| 48 | radicalExtraAscender | 210 | 244 |
| 49 | radicalKernBeforeDegree | 214 | 247 |
| 50 | radicalKernAfterDegree | 218 | 250 |

## 2. The parser of the TeX subset

- **Question:** does the parser accept exactly the documented subset and refuse the rest by name, with a position?
- **Input domain:** a TeX math string; `Sources/MathTypeset/MathParser.swift`. 81 commands are in use in the sources of the consumers (the list of commands in use, 2026-11-24); only `\boxed` and `\textcolor` of them are not known to the parser.
- **Authority today:** hand-written expected trees in 13 parser tests (`Tests/MathTypesetTests/MathParserTests.swift`). There is no written grammar and no reference parser. Issue 4 adds both.
- **Equivalence:** exact on the tree.
- **Failure report:** MEASURED (read in the sources): some mistakes are reported (an unknown command by name, a trailing lone backslash with an empty command name), others are silent: an environment end is not compared with its begin; `&`, `~`, `%` and `#` outside a matrix become literal text; a scaled delimiter given as a dot gives an empty node.
- **Classification:** parsed, a named error, or parsed silently into something else (the silent cases are defects named in issue 4).
- **Negative controls:** none.
- **Parity:** not applicable.
- **Status:** weak. Blocks issues 4, 9.

## 3. The layout rules

- **Question:** does the layout place every box where the TeXbook's rules (Appendix G) and the font constants put it?
- **Input domain:** a parsed tree and the constants of the font; `Sources/MathTypeset/MathLayout.swift` and `MathLayoutMetrics.swift`.
- **Authority today:** 12 layout tests with hand-written numbers. There is no table of the rules, no reference implementation, and no slow exhaustive reference. Issues 5 and 18 add them.
- **Equivalence:** exact on integers, or a tolerance derived and named (issue 6); today the arithmetic is floating point on one path.
- **Failure report:** none: the layout does not report that a rule is missing.
- **Classification:** laid out by a rule, or laid out by a fixed constant where the rule is missing. MEASURED (read in the sources): there are no atom classes, no inter-atom spacing table, no four-level style cascade and no cramped form; `\left` and `\right` do not grow.
- **Negative controls:** none.
- **Parity:** not applicable.
- **Status:** no answer key. Issues 5, 6, 18 wait for this section; the engine slices 1 to 4 each start by writing their rows here.

## 4. The measurement contract and the output boxes

- **Question:** does a consumer get boxes whose numbers follow from the contract, and plain text that is the formula's text?
- **Input domain:** `MathBox`, `MathRun`, `MathLinearizer`, and the contract in the documentation catalogue.
- **Authority today:** the tests of the layout read boxes; the linearizer has no test of its own. DOCUMENTED: the contract and the README say `baselineOffset` is used for scripts, and MEASURED (read in the sources) the layout never sets it.
- **Equivalence:** exact on box numbers.
- **Failure report:** none.
- **Classification:** not classified.
- **Negative controls:** none.
- **Parity:** not applicable.
- **Status:** weak. The canonical serialization of boxes (issue 10) does not exist yet.

## 5. Determinism and numeric behaviour

- **Question:** are the same formula, font and version laid out to the same bytes on every machine?
- **Input domain:** every formula; the layout is floating point on one path.
- **Authority today:** none: no test compares two runs and no test compares two machines (issue 10).
- **Equivalence:** byte equality of a canonical serialization, once it exists.
- **Failure report:** none.
- **Classification:** not checked.
- **Negative controls:** none.
- **Parity:** the decision of an Apple counterpart waits for a paired release measurement (issue 11).
- **Status:** no answer key.

## The check

`Tests/MathTypesetTests/MathOracleDocumentTests.swift` fails when a section lacks one of the nine fields, when the table of the 51 value records disagrees with the enumeration of the constants in place, name or byte offset, or with the closed form of the fixture.
