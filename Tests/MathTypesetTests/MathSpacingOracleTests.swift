@testable import MathTypeset
import Testing

/// The spacing between the atoms of a formula against the answer key of `MathSpacingReference` (the table of the TeXbook, the two
/// rules that cancel a binary operator, the unit 1 mu = 1/18 of the font size). The check goes through the parser and the layout as
/// a client uses them: every sequence of up to four atoms over the eight classes is written as a formula, laid out in the text style
/// and in the display style, and its width must be the sum of the widths of its atoms laid out alone plus the space the book gives.
///
/// Written before the production code (the first run of these tests is red: the layout adds no space between atoms), so that the
/// code is built to the oracle and not the oracle to the code.
@Suite("Math spacing: the layout against the answer key of the TeXbook table")
struct MathSpacingOracleTests {
    typealias Class = MathSpacingReference.AtomClass

    private func makeLayout(script: Bool = false) -> MathLayout {
        var layout = MathLayout(
            font: .regular,
            color: .black,
            measureText: { run in Double(run.text.count) * run.size * 0.6 },
            metrics: .default,
        )
        layout.isScriptStyle = script
        return layout
    }

    private func width(of source: String, displayStyle: Bool, size: Double, script: Bool = false) throws -> Double {
        let formula = try MathParser().parse(source)
        return try makeLayout(script: script).layout(formula.root, size: size, displayStyle: displayStyle).width
    }

    /// The tolerance is derived: a width is a sum of at most 4 atom widths and at most 3 spaces, each a product of two doubles
    /// of the size 10 with a relative error of 2^-53, so the sum is exact to well under 1e-12; 1e-9 leaves a margin of 1000.
    private let tolerance = 1e-9

    @Test("every sequence of up to 4 atoms has the width of its atoms plus the space of the table, in the text style", arguments: [false])
    func textStyle(displayStyle: Bool) throws {
        try check(displayStyle: displayStyle)
    }

    @Test("every sequence of up to 4 atoms has the width of its atoms plus the space of the table, in the display style", arguments: [true])
    func displayStyle(displayStyle: Bool) throws {
        try check(displayStyle: displayStyle)
    }

    @Test("every sequence of up to 4 atoms in a script has the width of its atoms plus the spaces that remain in the script styles")
    func scriptStyle() throws {
        try check(displayStyle: false, script: true)
    }

    @Test("the content of a superscript is laid out in the script style: no medium space around its plus sign")
    func superscriptContentIsScriptStyle() throws {
        let size = 10.0
        let metrics = MathLayoutMetrics.default
        let scriptSize = metrics.scriptSize(size: size)
        let base = try width(of: "x", displayStyle: false, size: size)
        let content = try width(of: "1+1", displayStyle: false, size: scriptSize, script: true)
        let whole = try width(of: "x^{1+1}", displayStyle: false, size: size)
        #expect(abs(whole - (base + metrics.spaceAfterScript(size: size) + content)) < tolerance)
        // And the same content in the text style would be wider by two mediums, which is what a script must not have.
        let large = try width(of: "1+1", displayStyle: false, size: scriptSize)
        #expect(abs(large - content - 2 * 4 * scriptSize / 18) < tolerance)
    }

    private func check(displayStyle: Bool, script: Bool = false) throws {
        let size = 10.0
        // A large style for the conditional entries: display and text are both large; only the script styles are not.
        var atomWidths: [Class: Double] = [:]
        for atom in Class.allCases {
            atomWidths[atom] = try width(of: atom.source, displayStyle: displayStyle, size: size, script: script)
        }
        var failures = 0
        var first: String?
        for classes in MathSpacingReference.sequences(upTo: 4) {
            let source = classes.map(\.source).joined()
            let expectedGlue = Double(MathSpacingReference.totalMu(classes, largeStyle: !script)) * size / 18
            let expected = classes.reduce(0.0) { $0 + (atomWidths[$1] ?? 0) } + expectedGlue
            let actual = try width(of: source, displayStyle: displayStyle, size: size, script: script)
            if abs(actual - expected) > tolerance {
                failures += 1
                if first == nil {
                    first = "\(classes) as \(source): expected \(expected), laid out \(actual)"
                }
            }
        }
        #expect(failures == 0, "\(failures) of \(MathSpacingReference.sequences(upTo: 4).count) sequences differ; the first: \(first ?? "none")")
    }

    @Test("a symbol that has no class is reported by name and not guessed")
    func unclassifiedSymbolIsReported() {
        let node = MathNode.sequence([.text("1"), .symbol(display: "\u{2602}", linearized: "umbrella", isBigOperator: false)])
        #expect(throws: MathLayout.LayoutError.unclassifiedSymbol("\u{2602}")) {
            try makeLayout().layout(node, size: 10, displayStyle: false)
        }
    }

    @Test("an operator name written by the author is an operator: thin space on both sides, as the TeXbook gives \\operatorname", arguments: ["argmax", "arg max", "Var", "x"])
    func operatorNameIsAnOperator(name: String) throws {
        let size = 10.0
        let bare = try width(of: "\\operatorname{\(name)}", displayStyle: false, size: size)
        let one = try width(of: "1", displayStyle: false, size: size)
        let framed = try width(of: "1\\operatorname{\(name)}1", displayStyle: false, size: size)
        #expect(abs(framed - (bare + 2 * one + 2 * 3 * size / 18)) < tolerance)
    }

    /// Every symbol command the parser reads, written out by hand from its table (the parser keeps it private).
    private static let symbolCommands: [String] = [
        "alpha", "beta", "gamma", "delta", "epsilon", "theta", "lambda", "mu", "pi", "sigma", "phi", "omega", "Gamma", "Delta",
        "Theta", "Lambda", "Pi", "Sigma", "Phi", "Omega", "leq", "le", "geq", "ge", "neq", "times", "cdot", "pm", "infty",
        "rightarrow", "to", "zeta", "eta", "iota", "kappa", "nu", "xi", "rho", "tau", "upsilon", "chi", "psi", "varepsilon",
        "varphi", "vartheta", "Xi", "Psi", "Upsilon", "approx", "equiv", "sim", "propto", "ll", "gg", "subset", "supset",
        "subseteq", "supseteq", "in", "notin", "ni", "mid", "parallel", "leftarrow", "gets", "leftrightarrow", "Rightarrow",
        "Leftarrow", "Leftrightarrow", "mapsto", "div", "ast", "star", "circ", "bullet", "oplus", "ominus", "otimes", "cup", "cap",
        "wedge", "vee", "emptyset", "forall", "exists", "nabla", "partial", "angle", "ldots", "cdots", "dots", "prime", "hbar",
        "ell", "aleph", "sin", "cos", "tan", "cot", "sec", "csc", "log", "ln", "exp", "deg", "gcd", "sum", "prod", "int", "oint",
        "coprod", "bigcup", "bigcap", "lim", "max", "min", "sup", "inf",
    ]

    @Test("every symbol command of the parser has a class: none is reported")
    func everySymbolCommandHasAClass() throws {
        var unclassified: [String] = []
        for command in Self.symbolCommands {
            do {
                _ = try width(of: "1\\\(command) 1", displayStyle: false, size: 10)
            } catch let error as MathLayout.LayoutError {
                unclassified.append("\(command): \(error)")
            }
        }
        #expect(unclassified.isEmpty, "\(unclassified.count) commands have no class: \(unclassified.joined(separator: "; "))")
    }

    @Test("the matrix has the shape of the book: 8 rows of 8, the stars where a binary operator or a relation cannot stand")
    func matrixShape() {
        #expect(MathSpacingReference.matrix.count == 8)
        #expect(MathSpacingReference.matrix.allSatisfy { $0.count == 8 })
        // A pair that can occur has an entry; the stars (nil) are exactly these (row, column) pairs, as the book prints them.
        let stars: Set<[Int]> = [
            [1, 2], [2, 2], [2, 3], [2, 5], [2, 6], [3, 2], [4, 2], [6, 2],
        ]
        var found: Set<[Int]> = []
        for (row, entries) in MathSpacingReference.matrix.enumerated() {
            for (column, entry) in entries.enumerated() where entry == nil {
                found.insert([row, column])
            }
        }
        #expect(found == stars)
    }

    @Test("the matrix typed from the book agrees, cell by cell and in both style groups, with the data of KaTeX read from its own file")
    func matrixAgreesWithKaTeX() {
        var differences: [String] = []
        for left in Class.allCases {
            for right in Class.allCases {
                for large in [true, false] {
                    // A pair that cannot occur (a star) is not in KaTeX's data either: it reads as no space.
                    let ours = MathSpacingReference.mu(between: left, and: right, largeStyle: large) ?? 0
                    let theirs = MathSpacingKaTeXData.mu(between: left, and: right, largeStyle: large)
                    if ours != theirs {
                        differences.append("\(left) then \(right), \(large ? "large" : "script") styles: ours \(ours) mu, KaTeX \(theirs) mu")
                    }
                }
            }
        }
        #expect(differences.isEmpty, "\(differences.count) cells differ: \(differences.joined(separator: "; "))")
    }

    @Test("the cancellation turns a binary operator without two operands into an ordinary atom")
    func cancellation() {
        #expect(MathSpacingReference.cancelled([.bin, .ord]) == [.ord, .ord])
        #expect(MathSpacingReference.cancelled([.ord, .bin]) == [.ord, .ord])
        #expect(MathSpacingReference.cancelled([.ord, .bin, .ord]) == [.ord, .bin, .ord])
        #expect(MathSpacingReference.cancelled([.ord, .bin, .rel]) == [.ord, .ord, .rel])
        #expect(MathSpacingReference.cancelled([.rel, .bin, .ord]) == [.rel, .ord, .ord])
        #expect(MathSpacingReference.cancelled([.ord, .bin, .bin, .ord]) == [.ord, .bin, .ord, .ord])
    }
}
