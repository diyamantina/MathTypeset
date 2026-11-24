import Foundation
@testable import MathTypeset
import Testing

/// The MATH table reader against bytes it does not control: each case is the valid table of `MathTableFixture` with one
/// fault planted at a named byte, and the exact error it must give is written beside it before the run. Every case is
/// classified: accepted (the table is read), rejected with a named error (the exact error), and nothing else; a crash or an
/// error of another kind fails the case.
@Suite("MATH table reader: hostile bytes give the exact error, never a crash")
struct MathTableHostileBytesTests {
    typealias Fixture = MathTableFixture

    enum Expected {
        case accepted
        case truncated(offset: Int, needed: Int)
        case malformed(String)
    }

    struct Case: CustomTestStringConvertible {
        var name: String
        var bytes: [UInt8]
        var expected: Expected
        var testDescription: String {
            name
        }
    }

    private static func truncatedText(offset: Int, needed: Int, length: Int) -> String {
        "The MATH table is truncated at byte \(offset); needed \(needed) bytes in \(length) bytes."
    }

    static var cases: [Case] {
        let valid = Fixture.valid()
        let length = valid.count
        return [
            Case(name: "an empty table", bytes: [], expected: .truncated(offset: 0, needed: 10)),
            Case(name: "a header cut at 9 bytes", bytes: Array(valid[0 ..< 9]), expected: .truncated(offset: 0, needed: 10)),
            Case(
                name: "version 2.0",
                bytes: Fixture.setting(valid, at: 0, to: 2),
                expected: .malformed("version must be 1.0"),
            ),
            Case(
                name: "minor version 1",
                bytes: Fixture.setting(valid, at: 2, to: 1),
                expected: .malformed("version must be 1.0"),
            ),
            Case(
                name: "a null offset to MathConstants",
                bytes: Fixture.setting(valid, at: 4, to: 0),
                expected: .malformed("MathConstants offset must not be null"),
            ),
            Case(
                name: "an offset to MathConstants past the end of the table",
                bytes: Fixture.setting(valid, at: 4, to: 0xFFFF),
                expected: .malformed(
                    "MathConstants offset is out of range: "
                        + truncatedText(offset: 0xFFFF, needed: 214, length: length),
                ),
            ),
            Case(
                name: "a null offset to MathGlyphInfo",
                bytes: Fixture.setting(valid, at: 6, to: 0),
                expected: .malformed("MathGlyphInfo offset must not be null"),
            ),
            Case(
                name: "a null offset to MathVariants",
                bytes: Fixture.setting(valid, at: 8, to: 0),
                expected: .malformed("MathVariants offset must not be null"),
            ),
            Case(
                name: "a device table offset of the first constant past the end",
                bytes: Fixture.setting(valid, at: Fixture.constantsStart + 8 + 2, to: 0xFFFF),
                expected: .malformed(
                    "MathConstants device table offset is out of range: "
                        + truncatedText(offset: Fixture.constantsStart + 0xFFFF, needed: 2, length: length),
                ),
            ),
            Case(
                name: "all four optional offsets of MathGlyphInfo null: accepted, with no glyph data",
                bytes: Fixture.setting(Fixture.setting(valid, at: Fixture.glyphInfoStart, to: 0), at: Fixture.glyphInfoStart + 4, to: 0),
                expected: .accepted,
            ),
            Case(
                name: "an italics count of 4 for a coverage of 3 glyphs",
                bytes: Fixture.setting(valid, at: Fixture.italicsStart + 2, to: 4),
                expected: .malformed("MathItalicsCorrectionInfo count must match its coverage glyph count"),
            ),
            Case(
                name: "an italics coverage glyph beyond numGlyphs",
                bytes: Fixture.setting(valid, at: Fixture.italicsCoverageStart + 4, to: 200),
                expected: .malformed("coverage glyph 200 exceeds maxp.numGlyphs 100"),
            ),
            Case(
                name: "an italics coverage of format 3",
                bytes: Fixture.setting(valid, at: Fixture.italicsCoverageStart, to: 3),
                expected: .malformed("coverage format 3 is unsupported"),
            ),
            Case(
                name: "a coverage range whose start is past its end",
                bytes: Fixture.valid(rangeStart: 7, rangeEnd: 4, extendedShapeAsRange: true),
                expected: .malformed("coverage range start exceeds end"),
            ),
            Case(
                name: "a coverage range that does not start at index 0",
                bytes: Fixture.setting(
                    Fixture.valid(rangeStart: 4, rangeEnd: 6, extendedShapeAsRange: true),
                    at: Fixture.extendedShapeStart + 8,
                    to: 3,
                ),
                expected: .malformed("coverage range start index is not contiguous"),
            ),
            Case(
                name: "a vertical variant count of 2 for a coverage of 1 glyph",
                bytes: Fixture.setting(valid, at: Fixture.variantsStart + 6, to: 2),
                expected: .malformed("vertical variants count must match its coverage glyph count"),
            ),
            Case(
                name: "a null vertical coverage with a positive count",
                bytes: Fixture.setting(valid, at: Fixture.variantsStart + 2, to: 0),
                expected: .malformed("vertical variants coverage is null but count is positive"),
            ),
            Case(
                name: "a vertical count of 65535, far past the end",
                bytes: Fixture.setting(valid, at: Fixture.variantsStart + 6, to: 0xFFFF),
                expected: .truncated(offset: Fixture.variantsStart + 10, needed: 0xFFFF * 2),
            ),
            Case(
                name: "a variant glyph beyond numGlyphs",
                bytes: Fixture.setting(valid, at: Fixture.constructionStart + 4, to: 100),
                expected: .malformed("variant glyph 100 exceeds maxp.numGlyphs 100"),
            ),
            Case(
                name: "an assembly part glyph beyond numGlyphs",
                bytes: Fixture.setting(valid, at: Fixture.assemblyStart + 6, to: 150),
                expected: .malformed("assembly part glyph 150 exceeds maxp.numGlyphs 100"),
            ),
            Case(
                name: "an assembly part count of 65535, far past the end",
                bytes: Fixture.setting(valid, at: Fixture.assemblyStart + 4, to: 0xFFFF),
                expected: .truncated(offset: Fixture.assemblyStart + 6, needed: 0xFFFF * 10),
            ),
        ]
    }

    @Test("each hostile case gives its exact error", arguments: cases)
    func exactError(_ item: Case) {
        let parser = TrueTypeMathTableParser(bytes: item.bytes, numGlyphs: Fixture.numGlyphs)
        switch item.expected {
        case .accepted:
            #expect(throws: Never.self) { try parser.parse() }
        case let .truncated(offset, needed):
            #expect(
                throws: TrueTypeFontError.truncated(table: "MATH", offset: offset, needed: needed, tableLength: item.bytes.count),
            ) { try parser.parse() }
        case let .malformed(reason):
            #expect(throws: TrueTypeFontError.malformedTable(tag: "MATH", reason: reason)) { try parser.parse() }
        }
    }

    /// The valid table with the extended shape coverage written as format 2 with the given ranges (start, end, the index of the
    /// first glyph of the range). The coverage grows by 6 bytes for each range after the first, so the offset of MathVariants in
    /// the header moves by the same amount; every offset inside MathVariants is relative to it and stays.
    private static func withExtendedShapeRanges(_ ranges: [(start: UInt16, end: UInt16, index: UInt16)]) -> [UInt8] {
        let valid = Fixture.valid()
        var coverage: [UInt8] = []
        func u16(_ value: UInt16) {
            coverage += [UInt8(value >> 8), UInt8(value & 0xFF)]
        }
        u16(2)
        u16(UInt16(ranges.count))
        for range in ranges {
            u16(range.start)
            u16(range.end)
            u16(range.index)
        }
        let variantsStart = Fixture.extendedShapeStart + coverage.count
        var bytes = Array(valid[0 ..< Fixture.extendedShapeStart]) + coverage + Array(valid[Fixture.variantsStart...])
        bytes = Fixture.setting(bytes, at: 8, to: UInt16(variantsStart))
        return bytes
    }

    @Test("a coverage of the widest ranges is bounded: two ranges of 65535 glyphs give 131070 ids, and a third cannot start")
    func widestRangesAreBounded() throws {
        // The glyph count of a coverage is bounded by construction: the start index of a range is a 16-bit field and must
        // equal the number of glyphs so far, so after two ranges of the maximal width (0 to 65534, with numGlyphs 65535) the
        // next start index, 131070, cannot be written. The most a hostile table can ask for is 131070 glyph ids: 256 KB.
        let two = Self.withExtendedShapeRanges([(0, 65534, 0), (0, 65534, 65535)])
        let table = try TrueTypeMathTableParser(bytes: two, numGlyphs: 65535).parse()
        #expect(table.glyphInfo.extendedShapeGlyphIDs.count == 131_070)
        #expect(table.glyphInfo.extendedShapeGlyphIDs.first == 0)
        #expect(table.glyphInfo.extendedShapeGlyphIDs.last == 65534)

        let three = Self.withExtendedShapeRanges([(0, 65534, 0), (0, 65534, 65535), (0, 65534, 65535)])
        #expect(throws: TrueTypeFontError.malformedTable(tag: "MATH", reason: "coverage range start index is not contiguous")) {
            try TrueTypeMathTableParser(bytes: three, numGlyphs: 65535).parse()
        }
    }

    @Test("a coverage that claims 65535 ranges in a table that holds three is rejected before any glyph is read")
    func rangeCountPastTheEnd() {
        var bytes = Self.withExtendedShapeRanges([(0, 1, 0), (2, 3, 2), (4, 5, 4)])
        bytes = Fixture.setting(bytes, at: Fixture.extendedShapeStart + 2, to: 0xFFFF)
        let expected = TrueTypeFontError.truncated(
            table: "MATH",
            offset: Fixture.extendedShapeStart + 4,
            needed: 0xFFFF * 6,
            tableLength: bytes.count,
        )
        #expect(throws: expected) {
            try TrueTypeMathTableParser(bytes: bytes, numGlyphs: Fixture.numGlyphs).parse()
        }
    }

    @Test("the valid table is accepted: the faults above are the only reason a case fails")
    func validIsAccepted() {
        #expect(throws: Never.self) {
            try TrueTypeMathTableParser(bytes: Fixture.valid(), numGlyphs: Fixture.numGlyphs).parse()
        }
    }

    @Test("a table cut at every length short of the whole is rejected with a named error, never read as a smaller table")
    func everyTruncation() {
        let valid = Fixture.valid()
        for length in 0 ..< valid.count {
            let parser = TrueTypeMathTableParser(bytes: Array(valid[0 ..< length]), numGlyphs: Fixture.numGlyphs)
            do {
                _ = try parser.parse()
                Issue.record("a table cut at \(length) of \(valid.count) bytes was accepted")
            } catch is TrueTypeFontError {
                // The named error: the case holds.
            } catch {
                Issue.record("a table cut at \(length) bytes gave an error of another kind: \(error)")
            }
        }
    }

    @Test("every single byte of the valid table changed to 0xFF and to 0x00 is accepted or gives a named error, never a crash")
    func everyByteChanged() {
        let valid = Fixture.valid()
        for replacement in [UInt8(0xFF), UInt8(0x00)] {
            for index in 0 ..< valid.count {
                var bytes = valid
                bytes[index] = replacement
                let parser = TrueTypeMathTableParser(bytes: bytes, numGlyphs: Fixture.numGlyphs)
                do {
                    _ = try parser.parse()
                } catch is TrueTypeFontError {
                    // Rejected with a named error: the case holds.
                } catch {
                    Issue.record("byte \(index) set to \(replacement) gave an error of another kind: \(error)")
                }
            }
        }
    }
}
