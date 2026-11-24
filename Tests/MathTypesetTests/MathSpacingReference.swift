import Foundation

/// The answer key of the spacing between math atoms, written as DATA and as a slow rule, apart from the code under test.
///
/// Sources, marked as in the oracle document: the matrix is the table of the TeXbook (chapter 18, page 170) typed here, and every
/// cell is compared with the 64 digits of `math_spacing` in Knuth's `tex.web` (MathSpacingTeXWebData), DOCUMENTED by the source of
/// the program; the book's printed page itself was not compared. The two rules that turn a
/// binary operator into an ordinary atom (rules 5 and 6 of Appendix G) are DOCUMENTED by the vendored reference `buildHTML.ts` of
/// KaTeX, which states them as two sets: a binary operator becomes ordinary after nothing, or after a binary operator, an
/// operator, a relation, an opening or a punctuation atom; and before nothing, or before a relation, a closing or a punctuation
/// atom. The unit is 1 mu = 1/18 em of the font size of the style: DOCUMENTED by the operator dictionary of MathML Core (appendix
/// B.1: the categories C, B and A have spaces of 0.1666..., 0.2222... and 0.2777... em, which are 3, 4 and 5 over 18), and
/// DERIVED, not stated, as a convention of the unit.
enum MathSpacingReference {
    /// The eight classes of atom, in the order of the rows and columns of the table.
    enum AtomClass: Int, CaseIterable, CustomStringConvertible {
        case ord, op, bin, rel, open, close, punct, inner

        var description: String {
            ["ord", "op", "bin", "rel", "open", "close", "punct", "inner"][rawValue]
        }

        /// One source atom of this class, as a string the parser reads as exactly one atom. The ordinary atom is a digit and not a
        /// letter, so that the control word of the operator (`\sum`) is not read together with the next atom (`\suma` is one word).
        var source: String {
            ["1", #"\sum"#, "+", "=", "(", ")", ",", #"\ldots"#][rawValue]
        }
    }

    /// An entry of the table: the space in mu (0, 3, 4 or 5), and whether it applies in display and text styles only.
    struct Entry: Equatable {
        var mu: Int
        var onlyInLargeStyles: Bool
    }

    /// Row = the left atom, column = the right atom, both in the order ord, op, bin, rel, open, close, punct, inner.
    /// nil is the star of the book: the pair cannot occur once a binary operator without two operands is an ordinary atom.
    ///
    /// Written as the book prints it: a digit is the space in mu, a letter c before it marks the entry that is in parentheses (only
    /// in the display and text styles), a star is a pair that cannot occur.
    /// Punct followed by rel is a conditional thin space in `tex.web` (the digit 1); KaTeX's data says thick there, a deviation of
    /// KaTeX from TeX that the test of the KaTeX data names (see MathSpacingKaTeXData).
    static let matrix: [[Entry?]] = rows.map { row in
        row.split(separator: " ").map { token -> Entry? in
            if token == "*" {
                return nil
            }
            if token.hasPrefix("c") {
                return Entry(mu: Int(token.dropFirst()) ?? -1, onlyInLargeStyles: true)
            }
            return Entry(mu: Int(token) ?? -1, onlyInLargeStyles: false)
        }
    }

    private static let rows: [String] = [
        /* ord   */ "0 3 c4 c5 0 0 0 c3",
        /* op    */ "3 3 * c5 0 0 0 c3",
        /* bin   */ "c4 c4 * * c4 * * c4",
        /* rel   */ "c5 c5 * 0 c5 0 0 c5",
        /* open  */ "0 0 * 0 0 0 0 0",
        /* close */ "0 3 c4 c5 0 0 0 c3",
        /* punct */ "c3 c3 * c3 c3 c3 c3 c3",
        /* inner */ "c3 3 c4 c5 c3 0 c3 c3",
    ]

    /// The space in mu between two adjacent atoms of these classes, in a style that is large (display or text) or not (script),
    /// or nil for a pair that cannot occur.
    static func mu(between left: AtomClass, and right: AtomClass, largeStyle: Bool) -> Int? {
        guard let entry = matrix[left.rawValue][right.rawValue] else {
            return nil
        }
        return entry.onlyInLargeStyles && !largeStyle ? 0 : entry.mu
    }

    /// The classes after the two rules that turn a binary operator into an ordinary atom (a slow loop that follows the rules as
    /// the book states them, one atom at a time).
    static func cancelled(_ classes: [AtomClass]) -> [AtomClass] {
        var result = classes
        for index in result.indices {
            if result[index] == .bin {
                let leftCancels = index == 0 || [.bin, .op, .rel, .open, .punct].contains(result[index - 1])
                if leftCancels {
                    result[index] = .ord
                }
            }
            if index > 0, result[index - 1] == .bin, [.rel, .close, .punct].contains(result[index]) {
                result[index - 1] = .ord
            }
        }
        if let last = result.last, last == .bin {
            result[result.count - 1] = .ord
        }
        return result
    }

    /// The total space in mu between the atoms of a sequence of classes: the sum over adjacent pairs after the cancellation.
    static func totalMu(_ classes: [AtomClass], largeStyle: Bool) -> Int {
        let after = cancelled(classes)
        var total = 0
        for index in 1 ..< max(after.count, 1) {
            total += mu(between: after[index - 1], and: after[index], largeStyle: largeStyle) ?? 0
        }
        return total
    }

    /// Every sequence of the eight classes of every length from 1 to `maxLength`, in order.
    static func sequences(upTo maxLength: Int) -> [[AtomClass]] {
        var all: [[AtomClass]] = []
        var level: [[AtomClass]] = [[]]
        for _ in 1 ... maxLength {
            level = level.flatMap { prefix in AtomClass.allCases.map { prefix + [$0] } }
            all += level
        }
        return all
    }
}
