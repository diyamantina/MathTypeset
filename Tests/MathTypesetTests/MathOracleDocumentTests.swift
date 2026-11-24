import Foundation
@testable import MathTypeset
import Testing

/// The oracle document (`docs/oracle.md`) is checked, so that it cannot drift from the code: every section has its nine
/// fields, and the table of the 51 value records agrees with the enumeration and with the closed form of the fixture.
@Suite("Oracle document: every section has its nine fields and the table of constants is the code's")
struct MathOracleDocumentTests {
    static let fields = [
        "Question", "Input domain", "Authority", "Equivalence", "Failure report", "Classification",
        "Negative controls", "Parity", "Status",
    ]

    /// The text of docs/oracle.md, found from this file's path (Tests/MathTypesetTests/<file> is three levels below the root).
    static func documentText() throws -> String {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("docs/oracle.md"), encoding: .utf8)
    }

    /// The sections of the document: the text after each line that starts with two number signs and a digit and a full stop.
    static func sections(in text: String) -> [(title: String, body: String)] {
        var result: [(title: String, body: String)] = []
        var title: String?
        var body: [Substring] = []
        for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.hasPrefix("## ") {
                if let title {
                    result.append((title: title, body: body.joined(separator: "\n")))
                }
                title = String(line.dropFirst(3))
                body = []
            } else {
                body.append(line)
            }
        }
        if let title {
            result.append((title: title, body: body.joined(separator: "\n")))
        }
        return result.filter { $0.title.first?.isNumber == true }
    }

    /// How many times `marker` appears in `text` (Foundation only: the package has no platform floor that allows the newer
    /// string search).
    static func occurrences(of marker: String, in text: String) -> Int {
        text.components(separatedBy: marker).count - 1
    }

    static let surfaces = [
        "The font table reader", "The parser of the TeX subset", "The layout rules",
        "The measurement contract and the output boxes", "Determinism and numeric behaviour",
    ]

    @Test("the document has a section for each surface, in order")
    func hasEverySurface() throws {
        let titles = try Self.sections(in: Self.documentText()).map(\.title)
        #expect(titles.count == Self.surfaces.count)
        for (title, surface) in zip(titles, Self.surfaces) {
            #expect(title.contains(surface), "section \(title) should name \(surface)")
        }
    }

    @Test("every section has the nine fields, each once, in the same order")
    func hasTheNineFields() throws {
        for section in try Self.sections(in: Self.documentText()) {
            var previous = -1
            for field in Self.fields {
                // A prefix, so that "Authority" also finds "Authority today".
                let marker = "- **\(field)"
                let count = Self.occurrences(of: marker, in: section.body)
                #expect(count == 1, "section \(section.title): field \(field) must appear exactly once, found \(count)")
                if let first = section.body.range(of: marker) {
                    let position = section.body.distance(from: section.body.startIndex, to: first.lowerBound)
                    #expect(position > previous, "section \(section.title): field \(field) is out of order")
                    previous = position
                }
            }
        }
    }

    @Test("the table of the 51 value records is the enumeration's order, offsets and closed form")
    func tableOfConstants() throws {
        let text = try Self.documentText()
        let rows = text.split(separator: "\n").compactMap { line -> [String]? in
            guard line.hasPrefix("| "), let first = line.dropFirst(2).first, first.isNumber else { return nil }
            return line.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        #expect(rows.count == MathTableFixture.valueRecordCount)
        let names = TrueTypeMathTable.Constants.ValueName.allCases
        for (index, row) in rows.enumerated() where row.count == 4 {
            #expect(row[0] == String(index), "row \(index): place")
            #expect(row[1] == names[index].rawValue, "row \(index): name")
            #expect(row[2] == String(MathTableFixture.constantValueOffset(index: index)), "row \(index): byte offset")
            #expect(row[3] == String(MathTableFixture.constantValue(index: index)), "row \(index): closed form")
        }
        #expect(rows.allSatisfy { $0.count == 4 })
    }

    @Test("planted fault: a section with a field removed is found")
    func plantedMissingField() throws {
        let text = try Self.documentText().replacingOccurrences(of: "- **Parity:** not applicable.\n", with: "")
        var found = 0
        for section in Self.sections(in: text) where Self.occurrences(of: "- **Parity", in: section.body) != 1 {
            found += 1
        }
        #expect(found >= 1, "removing a field must leave at least one section that fails the check")
    }
}
