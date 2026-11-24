/// The spaces between the classes of atoms as the KaTeX project states them in its file `src/spacingData.js` (version 0.16.11, read
/// from the file itself on 2026-11-24 through a fetch of `https://cdn.jsdelivr.net/npm/katex@0.16.11/src/spacingData.js`: MEASURED
/// by reading). It is kept here as DATA (a pair of classes and a number of mu: facts, not the text of the file), in KaTeX's own
/// idea: a list for the display and text styles, and a list of the pairs that keep their space in the script styles. A pair that is
/// not listed has no space. This form is deliberately different from the matrix of `MathSpacingReference`, which was typed from
/// memory of the book: `MathSpacingOracleTests.matrixAgreesWithKaTeX` compares the two.
enum MathSpacingKaTeXData {
    typealias AtomClass = MathSpacingReference.AtomClass

    struct Pair {
        var left: AtomClass
        var right: AtomClass
        var mu: Int
    }

    /// Display and text styles, in the order of KaTeX's table: the rows are the left classes.
    static let largeStyles: [Pair] = [
        // mord
        Pair(left: .ord, right: .op, mu: 3), Pair(left: .ord, right: .bin, mu: 4),
        Pair(left: .ord, right: .rel, mu: 5), Pair(left: .ord, right: .inner, mu: 3),
        // mop
        Pair(left: .op, right: .ord, mu: 3), Pair(left: .op, right: .op, mu: 3),
        Pair(left: .op, right: .rel, mu: 5), Pair(left: .op, right: .inner, mu: 3),
        // mbin
        Pair(left: .bin, right: .ord, mu: 4), Pair(left: .bin, right: .op, mu: 4),
        Pair(left: .bin, right: .open, mu: 4), Pair(left: .bin, right: .inner, mu: 4),
        // mrel
        Pair(left: .rel, right: .ord, mu: 5), Pair(left: .rel, right: .op, mu: 5),
        Pair(left: .rel, right: .open, mu: 5), Pair(left: .rel, right: .inner, mu: 5),
        // mopen: none
        // mclose
        Pair(left: .close, right: .op, mu: 3), Pair(left: .close, right: .bin, mu: 4),
        Pair(left: .close, right: .rel, mu: 5), Pair(left: .close, right: .inner, mu: 3),
        // mpunct
        Pair(left: .punct, right: .ord, mu: 3), Pair(left: .punct, right: .op, mu: 3),
        Pair(left: .punct, right: .rel, mu: 5), Pair(left: .punct, right: .open, mu: 3),
        Pair(left: .punct, right: .close, mu: 3), Pair(left: .punct, right: .punct, mu: 3),
        Pair(left: .punct, right: .inner, mu: 3),
        // minner
        Pair(left: .inner, right: .ord, mu: 3), Pair(left: .inner, right: .op, mu: 3),
        Pair(left: .inner, right: .bin, mu: 4), Pair(left: .inner, right: .rel, mu: 5),
        Pair(left: .inner, right: .open, mu: 3), Pair(left: .inner, right: .punct, mu: 3),
        Pair(left: .inner, right: .inner, mu: 3),
    ]

    /// Script and scriptscript styles: the pairs that keep their space.
    static let smallStyles: [Pair] = [
        Pair(left: .ord, right: .op, mu: 3),
        Pair(left: .op, right: .ord, mu: 3), Pair(left: .op, right: .op, mu: 3),
        Pair(left: .close, right: .op, mu: 3),
        Pair(left: .inner, right: .op, mu: 3),
    ]

    static func mu(between left: AtomClass, and right: AtomClass, largeStyle: Bool) -> Int {
        let pairs = largeStyle ? largeStyles : smallStyles
        for pair in pairs where pair.left == left && pair.right == right {
            return pair.mu
        }
        return 0
    }
}
