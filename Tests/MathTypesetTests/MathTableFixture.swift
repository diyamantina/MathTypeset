import Foundation

/// A MATH table built from its closed form, byte by byte, with no font file and no help from the parser.
///
/// Every value is a function of its place (`constantValue(index:)`), so a reader that takes a value from the wrong place
/// returns a different number, and the expected result of a test is computed from the same closed form rather than read back
/// from the parser. The layout is fixed and every offset is a named constant, so a test can plant a fault at a named byte.
///
/// Layout (offsets from the start of the table; sub-table offsets in the bytes are relative to their parent):
///
///     0   header: version 1.0, offsets to MathConstants (10), MathGlyphInfo (224), MathVariants (268)
///     10  MathConstants, 214 bytes: 4 two-byte fields, 51 value records of 4 bytes, 1 two-byte field
///     224 MathGlyphInfo, 8 bytes: offsets to italics correction (8), top accent (0, none), extended shapes (34), kerns (0, none)
///     232 MathItalicsCorrectionInfo: coverage offset (16), count 3, three value records; coverage format 1 at 248: glyphs 3, 5, 9
///     258 ExtendedShapeCoverage: format 1, glyphs 4, 6, 7 (or format 2, one range, in the variant of the builder)
///     268 MathVariants: overlap 20, vertical coverage (12), no horizontal coverage, one vertical glyph, no horizontal glyphs,
///         the offset of the one construction (18); coverage at 280: glyph 10; construction at 286: assembly offset (12), two
///         variants (10, 100) and (11, 200); assembly at 298: italics correction 5, two parts
///     324 end
enum MathTableFixture {
    static let numGlyphs: UInt16 = 100

    // The places of the layout, as offsets from the start of the table.
    static let headerSize = 10
    static let constantsStart = 10
    static let constantsSize = 214
    static let glyphInfoStart = 224
    static let italicsStart = 232
    static let italicsCoverageStart = 248
    static let extendedShapeStart = 258
    static let variantsStart = 268
    static let verticalCoverageStart = 280
    static let constructionStart = 286
    static let assemblyStart = 298
    static let totalSize = 324

    /// The number of value records of MathConstants between the four leading fields and the trailing percent.
    static let valueRecordCount = 51

    /// The closed form of a constant: its place decides its value (index 0 is MathLeading, 50 is RadicalKernAfterDegree).
    static func constantValue(index: Int) -> Int16 {
        Int16(100 + 3 * index)
    }

    static let scriptPercentScaleDown: Int16 = 70
    static let scriptScriptPercentScaleDown: Int16 = 50
    static let delimitedSubFormulaMinHeight: UInt16 = 1300
    static let displayOperatorMinHeight: UInt16 = 1500
    static let radicalDegreeBottomRaisePercent: Int16 = 60

    static let italicsGlyphs: [UInt16] = [3, 5, 9]
    static let italicsValues: [Int16] = [40, 41, 42]
    static let extendedShapeGlyphs: [UInt16] = [4, 6, 7]

    /// The valid table. `extendedShapeAsRanges` writes the extended shape coverage as format 2 (one range, glyphs 4 to 6 and
    /// then... see `rangeStart` and `rangeEnd`): the same size as format 1 with three glyphs, so no offset moves.
    static func valid(rangeStart: UInt16 = 4, rangeEnd: UInt16 = 6, extendedShapeAsRange: Bool = false) -> [UInt8] {
        var bytes: [UInt8] = []
        func u16(_ value: UInt16) {
            bytes += [UInt8(value >> 8), UInt8(value & 0xFF)]
        }
        func i16(_ value: Int16) {
            u16(UInt16(bitPattern: value))
        }

        // Header.
        u16(1)
        u16(0)
        u16(UInt16(constantsStart))
        u16(UInt16(glyphInfoStart))
        u16(UInt16(variantsStart))

        // MathConstants.
        i16(scriptPercentScaleDown)
        i16(scriptScriptPercentScaleDown)
        u16(delimitedSubFormulaMinHeight)
        u16(displayOperatorMinHeight)
        for index in 0 ..< valueRecordCount {
            i16(constantValue(index: index))
            u16(0)
        }
        i16(radicalDegreeBottomRaisePercent)

        // MathGlyphInfo.
        u16(8)
        u16(0)
        u16(34)
        u16(0)

        // MathItalicsCorrectionInfo.
        u16(16)
        u16(UInt16(italicsGlyphs.count))
        for value in italicsValues {
            i16(value)
            u16(0)
        }
        u16(1)
        u16(UInt16(italicsGlyphs.count))
        for glyph in italicsGlyphs {
            u16(glyph)
        }

        // ExtendedShapeCoverage.
        if extendedShapeAsRange {
            u16(2)
            u16(1)
            u16(rangeStart)
            u16(rangeEnd)
            u16(0)
        } else {
            u16(1)
            u16(UInt16(extendedShapeGlyphs.count))
            for glyph in extendedShapeGlyphs {
                u16(glyph)
            }
        }

        // MathVariants.
        u16(20)
        u16(12)
        u16(0)
        u16(1)
        u16(0)
        u16(18)
        u16(1)
        u16(1)
        u16(10)
        // Construction.
        u16(12)
        u16(2)
        u16(10)
        u16(100)
        u16(11)
        u16(200)
        // Assembly.
        i16(5)
        u16(0)
        u16(2)
        u16(10)
        u16(0)
        u16(20)
        u16(100)
        u16(1)
        u16(11)
        u16(20)
        u16(0)
        u16(150)
        u16(0)

        return bytes
    }

    /// A copy of `bytes` with the two bytes at `offset` replaced by `value`.
    static func setting(_ bytes: [UInt8], at offset: Int, to value: UInt16) -> [UInt8] {
        var copy = bytes
        copy[offset] = UInt8(value >> 8)
        copy[offset + 1] = UInt8(value & 0xFF)
        return copy
    }

    /// The byte offset of the value of constant number `index` (0 is MathLeading), from the start of the table: the four
    /// leading fields take 8 bytes and each value record 4.
    static func constantValueOffset(index: Int) -> Int {
        constantsStart + 8 + 4 * index
    }
}
