/// The class of an atom of a formula, in the sense of the TeXbook (chapter 17): it decides the space between the atom and its
/// neighbours (see ``MathSpacing``). Assigned from the node: a character or a symbol by a table, a fraction as inner, anything
/// else as ordinary.
enum MathAtomClass: Equatable {
    case ord, op, bin, rel, open, close, punct, inner

    /// The class of one typed character, by the math codes of plain TeX: digits and letters are ordinary; the plus and the minus
    /// are binary operators, the equal sign, the two angle brackets and the colon are relations; the opening and closing brackets
    /// open and close; the comma and the semicolon are punctuation; the exclamation and the question mark close.
    static func ofCharacter(_ character: Character) -> MathAtomClass {
        switch character {
        case "+", "-", "\u{2212}", "*":
            .bin
        case "=", "<", ">", ":":
            .rel
        case "(", "[":
            .open
        case ")", "]", "!", "?":
            .close
        case ",", ";":
            .punct
        default:
            .ord
        }
    }

    /// Symbols that are binary operators, by the Unicode string of the symbol (the commands the parser reads).
    private static let binarySymbols: Set<String> = [
        "\u{00D7}", "\u{22C5}", "\u{00B1}", "\u{00F7}", "\u{2217}", "\u{22C6}", "\u{2218}", "\u{2219}", "\u{2295}", "\u{2296}",
        "\u{2297}", "\u{222A}", "\u{2229}", "\u{2227}", "\u{2228}",
    ]

    /// Symbols that are relations: comparisons, membership, inclusion, arrows, the bar and the double bar.
    private static let relationSymbols: Set<String> = [
        "\u{2264}", "\u{2265}", "\u{2260}", "\u{2248}", "\u{2261}", "\u{223C}", "\u{221D}", "\u{226A}", "\u{226B}", "\u{2282}",
        "\u{2283}", "\u{2286}", "\u{2287}", "\u{2208}", "\u{2209}", "\u{220B}", "\u{2223}", "\u{2225}", "\u{2192}", "\u{2190}",
        "\u{2194}", "\u{21D2}", "\u{21D0}", "\u{21D4}", "\u{21A6}",
    ]

    /// Symbols that are ordinary: the Greek letters, the infinity, the empty set, the quantifiers, the nabla, the partial sign, the
    /// angle, the prime, the reduced Planck constant, the script l and aleph.
    private static let ordinarySymbols: Set<String> = [
        "\u{03B1}", "\u{03B2}", "\u{03B3}", "\u{03B4}", "\u{03B5}", "\u{03B8}", "\u{03BB}", "\u{03BC}", "\u{03C0}", "\u{03C3}",
        "\u{03C6}", "\u{03C9}", "\u{0393}", "\u{0394}", "\u{0398}", "\u{039B}", "\u{03A0}", "\u{03A3}", "\u{03A6}", "\u{03A9}",
        "\u{03B6}", "\u{03B7}", "\u{03B9}", "\u{03BA}", "\u{03BD}", "\u{03BE}", "\u{03C1}", "\u{03C4}", "\u{03C5}", "\u{03C7}",
        "\u{03C8}", "\u{03D5}", "\u{03D1}", "\u{039E}", "\u{03A8}", "\u{03A5}", "\u{221E}", "\u{2205}", "\u{2200}", "\u{2203}",
        "\u{2207}", "\u{2202}", "\u{2220}", "\u{2032}", "\u{210F}", "\u{2113}", "\u{2135}",
    ]

    /// Symbols that are inner: the ellipses (`\ldots`, `\cdots` and `\dots` are `\mathinner` in plain TeX).
    private static let innerSymbols: Set<String> = ["\u{2026}", "\u{22EF}"]

    /// The class of a symbol node, or nil for a symbol that has no entry: such a symbol is reported by the layout, never guessed.
    ///
    /// A symbol whose text is plain ASCII is an operator name: the functions the parser reads as symbols (`\sin`, `\log` and the
    /// others) and every `\operatorname{...}` (whose name is any text the author wrote, so it cannot be listed). TeX gives both the
    /// class of an operator. Every other symbol of the parser's table is a non-ASCII character and is listed above.
    static func ofSymbol(display: String, isBigOperator: Bool) -> MathAtomClass? {
        if isBigOperator || (!display.isEmpty && display.allSatisfy(\.isASCII)) {
            return .op
        }
        if binarySymbols.contains(display) {
            return .bin
        }
        if relationSymbols.contains(display) {
            return .rel
        }
        if innerSymbols.contains(display) {
            return .inner
        }
        if ordinarySymbols.contains(display) {
            return .ord
        }
        return nil
    }

    /// The class of a delimiter that grows (`\big` and the like): by its character.
    static func ofDelimiter(_ symbol: String) -> MathAtomClass {
        switch symbol {
        case "(", "[", "{", "<", "\u{27E8}":
            .open
        case ")", "]", "}", ">", "\u{27E9}":
            .close
        default:
            .ord
        }
    }
}
