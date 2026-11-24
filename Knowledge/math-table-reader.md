# The MATH table reader and how it is checked

## The table is built from its closed form

DOCUMENTED (`Tests/MathTypesetTests/MathTableFixture.swift`): no font file is tracked in the repository, so the tests build a MATH table byte by byte. Every constant is `100 + 3 * place`, so a reader that takes a value from the wrong place returns a different number; every glyph list is written out; every offset is a named constant (a table of 324 bytes). The expected result of a test is computed from the same closed form, not read back from the parser.

DERIVED (the OpenType structure sizes): MathConstants is 4 two-byte fields, 51 value records of 4 bytes and one two-byte field: 8 + 204 + 2 = 214 bytes, which is the size the parser requires (`requireRange(offset:count: 214)`). The byte of the value of constant number `i` is `8 + 4 * i` from the start of MathConstants.

## The order of the constants is the specification's, written out

MEASURED (a diff of the case names of the enumeration against the list in the test, 2026-11-24: no difference; the test `constantOrder` repeats it): the 51 names of `TrueTypeMathTable.Constants.ValueName` are in the order of the OpenType MATH specification. The parser reads the records in the order of `allCases`, so a swap of two cases of the enumeration would silently move two values; the test holds the order as a list of names written out, not derived from the enumeration.

MEASURED (three faults planted in the production code of a copy on 2026-11-24, one at a time): swapping two cases of the enumeration is NOT seen by the test of the closed form, because that test walks the enumeration with its own index and so expects the swapped order too; it is seen by the order test (the order written out in the test) and by the table of the oracle document. A check that derives its expectation from the thing under test cannot see a fault in that thing: keep one expectation written out.

## A coverage cannot ask for more than 131070 glyph ids

DERIVED: in a coverage table of format 2 the parser requires the start index of each range to equal the number of glyph ids read so far (`startCoverageIndex == glyphIDs.count`). The start index is a 16-bit field, so it is at most 65535. The first range can be 0 to 65534 (65535 glyphs, with `numGlyphs` 65535), the second range can start at index 65535 and add 65535 more (131070 in all), and a third would have to start at index 131070, which cannot be written. So a hostile table can ask for at most 131070 glyph ids, which is 256 KB of memory, however many ranges it claims: a count of ranges larger than the table holds is refused before any glyph is read, by the bounds check on `count * 6` bytes. A first suspicion that the amount was gigabytes was wrong; the argument above replaced it. The two named cases in `MathTableHostileBytesTests` pin it.

## The hostile-bytes cases

MEASURED (one run on 2026-11-24: 44 tests in 5 suites passed, and three faults planted in the production code each turned a test red: see `docs/oracle.md`, section 1): `MathTableHostileBytesTests` holds named cases with their exact errors (the text of the truncated or malformed error, with the offsets computed by hand), the table cut at every length short of the whole, and every byte of the table set to 0xFF and to 0x00. The rule of the cases: each is accepted, or rejected with a named `TrueTypeFontError`; a crash or an error of another kind fails the case, and a case that crashes the process is reported as a finding, never weakened.

## Not covered

DOCUMENTED (`docs/oracle.md`, section 1): MathKern records, top accent attachments, horizontal constructions, a coverage with several ranges in the other tables, a real font, and the device tables behind a non-zero device offset.
