import Foundation
@testable import MathTypeset
import Testing

/// The MATH table reader against the closed form of a table built byte by byte (`MathTableFixture`), and against an
/// independent read of the same bytes. The oracle is the closed form and the bytes, never the parser's own output.
@Suite("MATH table reader: the parser against the closed form and an independent read of the bytes")
struct MathTableReaderTests {
    /// The names of the 51 value records of MathConstants in the order of the OpenType specification (the byte order of the
    /// table), written out here and not derived from the enumeration under test.
    static let specOrder: [String] = [
        "mathLeading", "axisHeight", "accentBaseHeight", "flattenedAccentBaseHeight",
        "subscriptShiftDown", "subscriptTopMax", "subscriptBaselineDropMin",
        "superscriptShiftUp", "superscriptShiftUpCramped", "superscriptBottomMin", "superscriptBaselineDropMax",
        "subSuperscriptGapMin", "superscriptBottomMaxWithSubscript", "spaceAfterScript",
        "upperLimitGapMin", "upperLimitBaselineRiseMin", "lowerLimitGapMin", "lowerLimitBaselineDropMin",
        "stackTopShiftUp", "stackTopDisplayStyleShiftUp", "stackBottomShiftDown", "stackBottomDisplayStyleShiftDown",
        "stackGapMin", "stackDisplayStyleGapMin",
        "stretchStackTopShiftUp", "stretchStackBottomShiftDown", "stretchStackGapAboveMin", "stretchStackGapBelowMin",
        "fractionNumeratorShiftUp", "fractionNumeratorDisplayStyleShiftUp",
        "fractionDenominatorShiftDown", "fractionDenominatorDisplayStyleShiftDown",
        "fractionNumeratorGapMin", "fractionNumDisplayStyleGapMin", "fractionRuleThickness",
        "fractionDenominatorGapMin", "fractionDenomDisplayStyleGapMin",
        "skewedFractionHorizontalGap", "skewedFractionVerticalGap",
        "overbarVerticalGap", "overbarRuleThickness", "overbarExtraAscender",
        "underbarVerticalGap", "underbarRuleThickness", "underbarExtraDescender",
        "radicalVerticalGap", "radicalDisplayStyleVerticalGap", "radicalRuleThickness", "radicalExtraAscender",
        "radicalKernBeforeDegree", "radicalKernAfterDegree",
    ]

    private func parsed(_ bytes: [UInt8] = MathTableFixture.valid()) throws -> TrueTypeMathTable {
        try TrueTypeMathTableParser(bytes: bytes, numGlyphs: MathTableFixture.numGlyphs).parse()
    }

    @Test("the layout of the fixture is the size of the OpenType structures: 8 + 51 records of 4 + 2 = 214, and the table 324")
    func fixtureSizes() {
        #expect(Self.specOrder.count == MathTableFixture.valueRecordCount)
        #expect(8 + 4 * MathTableFixture.valueRecordCount + 2 == MathTableFixture.constantsSize)
        #expect(MathTableFixture.valid().count == MathTableFixture.totalSize)
        #expect(MathTableFixture.valid(extendedShapeAsRange: true).count == MathTableFixture.totalSize)
    }

    @Test("the enumeration of constants is the order of the specification, name by name")
    func constantOrder() {
        #expect(TrueTypeMathTable.Constants.ValueName.allCases.map(\.rawValue) == Self.specOrder)
    }

    @Test("every constant is the value its place decides in the closed form")
    func everyConstantIsItsClosedForm() throws {
        let table = try parsed()
        for (index, name) in TrueTypeMathTable.Constants.ValueName.allCases.enumerated() {
            let record = try #require(table.constants.value(name), "constant \(name.rawValue) is missing")
            #expect(record.value == MathTableFixture.constantValue(index: index), "constant \(name.rawValue), place \(index)")
            #expect(record.deviceOffset == 0, "constant \(name.rawValue) has no device table")
        }
        #expect(table.constants.values.count == MathTableFixture.valueRecordCount)
    }

    @Test("every constant is the number an independent read of its bytes gives, at 8 + 4 * place from the constants")
    func everyConstantIsTheIndependentRead() throws {
        let bytes = MathTableFixture.valid()
        let table = try parsed(bytes)
        for (index, name) in TrueTypeMathTable.Constants.ValueName.allCases.enumerated() {
            let offset = MathTableFixture.constantValueOffset(index: index)
            let independent = Int16(bitPattern: UInt16(bytes[offset]) << 8 | UInt16(bytes[offset + 1]))
            #expect(table.constants.value(name)?.value == independent, "constant \(name.rawValue) at byte \(offset)")
        }
    }

    @Test("the four leading fields and the trailing percent are read from their own bytes")
    func fixedFields() throws {
        let constants = try parsed().constants
        #expect(constants.scriptPercentScaleDown == MathTableFixture.scriptPercentScaleDown)
        #expect(constants.scriptScriptPercentScaleDown == MathTableFixture.scriptScriptPercentScaleDown)
        #expect(constants.delimitedSubFormulaMinHeight == MathTableFixture.delimitedSubFormulaMinHeight)
        #expect(constants.displayOperatorMinHeight == MathTableFixture.displayOperatorMinHeight)
        #expect(constants.radicalDegreeBottomRaisePercent == MathTableFixture.radicalDegreeBottomRaisePercent)
    }

    @Test("the italics corrections and the extended shapes are the glyphs and values of the closed form")
    func glyphInfo() throws {
        let info = try parsed().glyphInfo
        #expect(info.italicsCorrections.map(\.glyphID) == MathTableFixture.italicsGlyphs)
        #expect(info.italicsCorrections.map(\.value.value) == MathTableFixture.italicsValues)
        #expect(info.extendedShapeGlyphIDs == MathTableFixture.extendedShapeGlyphs)
        #expect(info.topAccentAttachments.isEmpty)
        #expect(info.mathKerns.isEmpty)
    }

    @Test("a coverage written as one range of format 2 gives the glyphs of the range, in order")
    func coverageAsRange() throws {
        let info = try parsed(MathTableFixture.valid(rangeStart: 4, rangeEnd: 6, extendedShapeAsRange: true)).glyphInfo
        #expect(info.extendedShapeGlyphIDs == [4, 5, 6])
    }

    @Test("the vertical construction has its variants and its assembly parts as written")
    func variants() throws {
        let variants = try parsed().variants
        #expect(variants.minConnectorOverlap == 20)
        #expect(variants.horizontalConstructions.isEmpty)
        let construction = try #require(variants.verticalConstructions.first)
        #expect(variants.verticalConstructions.count == 1)
        #expect(construction.glyphID == 10)
        #expect(construction.variants.map(\.glyphID) == [10, 11])
        #expect(construction.variants.map(\.advanceMeasurement) == [100, 200])
        let assembly = try #require(construction.assembly)
        #expect(assembly.italicsCorrection.value == 5)
        #expect(assembly.parts.map(\.glyphID) == [10, 11])
        #expect(assembly.parts.map(\.startConnectorLength) == [0, 20])
        #expect(assembly.parts.map(\.endConnectorLength) == [20, 0])
        #expect(assembly.parts.map(\.fullAdvance) == [100, 150])
        #expect(assembly.parts.map(\.partFlags) == [1, 0])
    }

    @Test("planted fault: records written one place late disagree with the closed form, so the comparison can fail")
    func plantedLateRecords() throws {
        // Move every constant value one record later (the first record takes the value of the last): a reader with this
        // fault, or a table built with it, must differ from the closed form at every place.
        var bytes = MathTableFixture.valid()
        var shifted: [UInt8] = []
        for index in 0 ..< MathTableFixture.valueRecordCount {
            let from = MathTableFixture.constantValueOffset(index: (index + MathTableFixture.valueRecordCount - 1) % MathTableFixture.valueRecordCount)
            shifted += [bytes[from], bytes[from + 1]]
        }
        for index in 0 ..< MathTableFixture.valueRecordCount {
            let at = MathTableFixture.constantValueOffset(index: index)
            bytes[at] = shifted[2 * index]
            bytes[at + 1] = shifted[2 * index + 1]
        }
        let table = try parsed(bytes)
        var disagreements = 0
        for (index, name) in TrueTypeMathTable.Constants.ValueName.allCases.enumerated()
            where table.constants.value(name)?.value != MathTableFixture.constantValue(index: index)
        {
            disagreements += 1
        }
        #expect(disagreements == MathTableFixture.valueRecordCount, "every place must disagree with the closed form")
    }
}
