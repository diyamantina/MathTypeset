import Foundation

public struct MathLayout {
    /// How symbol commands are turned into drawable text.
    public enum SymbolStyle: Sendable {
        /// Use the Unicode glyph (`\sum` -> ∑, `\sqrt` -> √). The default; correct
        /// for any font that covers math symbols (a real math font, DejaVu,
        /// Liberation, etc.).
        case unicode
        /// Use an ASCII transliteration (`\sum` -> "sum", `\sqrt` -> "sqrt") for
        /// consumers whose font cannot draw the Unicode math glyphs, such as a
        /// PDF base-14 profile.
        case asciiFallback
        /// Use the Unicode glyph per symbol when the consumer's font covers it,
        /// and the ASCII transliteration otherwise. The decision is delegated to
        /// the ``symbolCoverage`` closure, which answers, for a symbol's Unicode
        /// `display` string, whether the active font can draw it (no closure
        /// means "covers nothing", i.e. all fallback). This keeps the engine
        /// font-program-free: the consumer owns the `cmap` coverage lookup,
        /// exactly as it owns ``measureText``. A font with full math coverage
        /// then behaves like ``unicode``; a base-14 font like ``asciiFallback``;
        /// a partial font gets real glyphs where it can and a readable fallback
        /// where it cannot.
        case unicodeWhereCovered
    }

    public var font: MathFontStyle
    public var color: MathColor
    public var measureText: (MathRun) throws -> Double
    public var metrics: MathLayoutMetrics
    public var symbolStyle: SymbolStyle
    /// Answers, for a symbol's Unicode `display` string, whether the active font
    /// can draw it. Consulted only when ``symbolStyle`` is
    /// ``SymbolStyle/unicodeWhereCovered``. Like ``measureText``, the consumer
    /// supplies it; the engine never inspects the font program itself.
    public var symbolCoverage: ((String) -> Bool)?

    /// What the layout reports instead of guessing.
    public enum LayoutError: Error, Equatable, Sendable {
        /// A symbol node whose Unicode string has no atom class in the table (a symbol the parser does not read): the space around
        /// it cannot be decided, so it is named and not guessed.
        case unclassifiedSymbol(String)
    }

    /// True while the content of a script is laid out: the spaces that only the display and text styles have are not added.
    /// (The full cascade of the four styles is slice 2.)
    var isScriptStyle = false

    /// A copy of this layout for the content of a script.
    private func scripted() -> MathLayout {
        var copy = self
        copy.isScriptStyle = true
        return copy
    }

    public init(
        font: MathFontStyle,
        color: MathColor,
        measureText: @escaping (MathRun) throws -> Double,
        metrics: MathLayoutMetrics = .default,
        symbolStyle: SymbolStyle = .unicode,
        symbolCoverage: ((String) -> Bool)? = nil,
    ) {
        self.font = font
        self.color = color
        self.measureText = measureText
        self.metrics = metrics
        self.symbolStyle = symbolStyle
        self.symbolCoverage = symbolCoverage
    }

    public func layout(
        _ node: MathNode,
        size: Double,
        displayStyle: Bool,
    ) throws -> MathBox {
        switch node {
        case let .sequence(children):
            try layoutSequence(children, size: size, displayStyle: displayStyle)
        case let .text(text):
            try layoutText(text, size: size)
        case let .symbol(display, linearized, _):
            try layoutText(symbolText(display: display, linearized: linearized), size: size)
        case let .space(em):
            MathBox(width: em * size, height: 0, depth: 0, elements: [])
        case let .fraction(numerator, denominator):
            try layoutFraction(
                numerator: numerator,
                denominator: denominator,
                size: size,
                displayStyle: displayStyle,
            )
        case let .radical(radicand):
            try layoutRadical(radicand, size: size, displayStyle: displayStyle)
        case let .scripts(base, subscriptNode, superscriptNode):
            try layoutScripts(
                base: base,
                subscriptNode: subscriptNode,
                superscriptNode: superscriptNode,
                size: size,
                displayStyle: displayStyle,
            )
        case let .accent(symbol, _, isOverline, base):
            try layoutAccent(
                symbol: symbol,
                isOverline: isOverline,
                base: base,
                size: size,
                displayStyle: displayStyle,
            )
        case let .matrix(rows, open, close, leftAlign):
            try layoutMatrix(
                rows: rows,
                open: open,
                close: close,
                leftAlign: leftAlign,
                size: size,
            )
        case let .scaledDelimiter(symbol, scale):
            try layoutText(symbol, size: size * scale)
        }
    }

    private func layoutMatrix(
        rows: [[MathNode]],
        open: String,
        close: String,
        leftAlign: Bool,
        size: Double,
    ) throws -> MathBox {
        let cellBoxes = try rows.map { try $0.map { try layout($0, size: size, displayStyle: false) } }
        guard let columnCount = cellBoxes.map(\.count).max(), columnCount > 0 else {
            return MathBox(width: 0, height: 0, depth: 0, elements: [])
        }

        var columnWidths = [Double](repeating: 0, count: columnCount)
        for row in cellBoxes {
            for (column, box) in row.enumerated() {
                columnWidths[column] = max(columnWidths[column], box.width)
            }
        }
        let columnGap = size * 0.6
        let rowGap = size * 0.3
        let rowHeights = cellBoxes.map { $0.map(\.height).max() ?? metrics.textHeight(size: size) }
        let rowDepths = cellBoxes.map { $0.map(\.depth).max() ?? metrics.textDepth(size: size) }
        let stackHeight = zip(rowHeights, rowDepths).reduce(0) { $0 + $1.0 + $1.1 }
            + rowGap * Double(max(0, cellBoxes.count - 1))
        let axisY = metrics.axisHeight(size: size)
        let topY = axisY + stackHeight / 2
        let gridWidth = columnWidths.reduce(0, +) + columnGap * Double(max(0, columnCount - 1))
        let delimiterSize = min(max(stackHeight, size), size * 3)
        let delimiterY = axisY - delimiterSize * 0.3

        var elements: [MathLayoutElement] = []
        var xOrigin = 0.0
        if !open.isEmpty {
            let openBox = try layoutText(open, size: delimiterSize)
            elements += openBox.elements.map { $0.offsetBy(x: 0, y: delimiterY) }
            xOrigin = openBox.width + columnGap * 0.5
        }

        var cursorY = topY
        for (rowIndex, row) in cellBoxes.enumerated() {
            let rowBaseline = cursorY - rowHeights[rowIndex]
            var columnX = xOrigin
            for column in 0 ..< columnCount {
                if column < row.count {
                    let box = row[column]
                    let cellX = columnX + (leftAlign ? 0 : (columnWidths[column] - box.width) / 2)
                    elements += box.elements.map { $0.offsetBy(x: cellX, y: rowBaseline) }
                }
                columnX += columnWidths[column] + columnGap
            }
            cursorY = rowBaseline - rowDepths[rowIndex] - rowGap
        }

        var totalWidth = xOrigin + gridWidth
        if !close.isEmpty {
            let closeBox = try layoutText(close, size: delimiterSize)
            elements += closeBox.elements.map { $0.offsetBy(x: totalWidth + columnGap * 0.5, y: delimiterY) }
            totalWidth += columnGap * 0.5 + closeBox.width
        }

        return MathBox(
            width: totalWidth,
            height: topY,
            depth: max(0, stackHeight / 2 - axisY),
            elements: elements,
        )
    }

    private func layoutAccent(
        symbol: String,
        isOverline: Bool,
        base: MathNode,
        size: Double,
        displayStyle: Bool,
    ) throws -> MathBox {
        let baseBox = try layout(base, size: size, displayStyle: displayStyle)
        let gap = size * 0.12
        let ruleThickness = metrics.radicalRuleThickness(size: size)
        var elements = baseBox.elements

        if isOverline {
            let ruleY = baseBox.height + gap
            elements.append(.rule(
                x: 0,
                y: ruleY,
                width: baseBox.width,
                height: ruleThickness,
                color: color,
            ))
            return MathBox(
                width: baseBox.width,
                height: ruleY + ruleThickness,
                depth: baseBox.depth,
                elements: elements,
            )
        }

        let accentSize = size * 0.9
        let accent = try layoutText(symbol, size: accentSize)
        let accentX = max(0, (baseBox.width - accent.width) / 2)
        let accentY = baseBox.height + gap
        elements += accent.elements.map { $0.offsetBy(x: accentX, y: accentY) }
        return MathBox(
            width: max(baseBox.width, accentX + accent.width),
            height: accentY + accent.height,
            depth: baseBox.depth,
            elements: elements,
        )
    }

    private func layoutSequence(
        _ children: [MathNode],
        size: Double,
        displayStyle: Bool,
    ) throws -> MathBox {
        var cursor = 0.0
        var elements: [MathLayoutElement] = []
        var height = 0.0
        var depth = 0.0

        // The classes of the atoms, after the two rules that turn a binary operator without two operands into an ordinary atom;
        // nil for a child that is not an atom (a typed space, an explicit space): it has no space of its own by class.
        let classes = try Self.cancelledClasses(of: children)
        var previous: MathAtomClass?
        var previousDrawn: (text: String, isSymbol: Bool)?
        var typedSpace: MathBox?

        for (child, atom) in zip(children, classes) {
            let drawn = drawnText(of: child)
            if let atom {
                var glue = 0
                if let previous, let mu = MathSpacing.mu(between: previous, and: atom, largeStyle: !isScriptStyle) {
                    glue = mu
                    cursor += Double(mu) * size / 18
                }
                // A typed space is ignored in math, as in TeX, except where two words drawn from symbols would run together
                // (`\alpha \beta` drawn as "alpha" and "beta" in the ASCII fallback) and the classes give no space between them.
                if let typedSpace, glue == 0, let previousDrawn, let drawn, previousDrawn.isSymbol || drawn.isSymbol,
                   previousDrawn.text.last?.isASCIIWordCharacter == true, drawn.text.first?.isASCIIWordCharacter == true
                {
                    cursor += typedSpace.width
                }
                previous = atom
                typedSpace = nil
            } else if case let .text(text) = child, text.allSatisfy(\.isWhitespace) {
                // A typed space is ignored in math: the space between atoms comes from their classes.
                typedSpace = try layout(child, size: size, displayStyle: displayStyle)
                continue
            } else {
                typedSpace = nil
            }
            previousDrawn = drawn
            let box = try layout(child, size: size, displayStyle: displayStyle)
            elements += box.elements.map { $0.offsetBy(x: cursor, y: 0) }
            cursor += box.width
            height = max(height, box.height)
            depth = max(depth, box.depth)
        }

        return MathBox(width: cursor, height: height, depth: depth, elements: elements)
    }

    /// The text a child draws when it is a character or a symbol, and whether it is a symbol; nil for any other node.
    private func drawnText(of node: MathNode) -> (text: String, isSymbol: Bool)? {
        switch node {
        case let .text(text):
            (text, false)
        case let .symbol(display, linearized, _):
            (symbolText(display: display, linearized: linearized), true)
        default:
            nil
        }
    }

    /// The class of each child, or nil for a child that is not an atom, after the cancellation of the binary operators.
    private static func cancelledClasses(of children: [MathNode]) throws -> [MathAtomClass?] {
        var classes: [MathAtomClass?] = try children.map(atomClass(of:))
        var lastIndex: Int?
        for index in classes.indices {
            guard let current = classes[index] else {
                continue
            }
            if let last = lastIndex, let before = classes[last] {
                if current == .bin, [.bin, .op, .rel, .open, .punct].contains(before) {
                    classes[index] = .ord
                } else if before == .bin, [.rel, .close, .punct].contains(current) {
                    classes[last] = .ord
                }
            } else if current == .bin {
                classes[index] = .ord
            }
            lastIndex = index
        }
        if let last = lastIndex, classes[last] == .bin {
            classes[last] = .ord
        }
        return classes
    }

    /// The class of one node: a character or a symbol by its table, a fraction inner, a scripted atom the class of its base, a
    /// space no atom, anything else ordinary.
    private static func atomClass(of node: MathNode) throws -> MathAtomClass? {
        switch node {
        case let .text(text):
            if text.allSatisfy(\.isWhitespace) {
                return nil
            }
            return text.count == 1 ? text.first.map(MathAtomClass.ofCharacter) : .ord
        case let .symbol(display, _, isBigOperator):
            guard let atom = MathAtomClass.ofSymbol(display: display, isBigOperator: isBigOperator) else {
                throw LayoutError.unclassifiedSymbol(display)
            }
            return atom
        case .fraction:
            // `\frac` is a group in LaTeX (`{...\over...}`), hence one ordinary atom; only a bare `\over` would be inner.
            return .ord
        case let .scripts(base, _, _):
            return try atomClass(of: base) ?? .ord
        case let .scaledDelimiter(symbol, _):
            return MathAtomClass.ofDelimiter(symbol)
        case .space:
            return nil
        default:
            return .ord
        }
    }

    /// Picks the drawable string for a symbol command according to
    /// ``symbolStyle``: the Unicode `display` glyph, the ASCII `linearized`
    /// transliteration, or a per-symbol choice driven by a font-coverage
    /// closure.
    private func symbolText(display: String, linearized: String) -> String {
        switch symbolStyle {
        case .unicode:
            display
        case .asciiFallback:
            linearized
        case .unicodeWhereCovered:
            (symbolCoverage?(display) ?? false) ? display : linearized
        }
    }

    private func layoutText(_ text: String, size: Double) throws -> MathBox {
        guard !text.isEmpty else {
            return MathBox(width: 0, height: 0, depth: 0, elements: [])
        }

        let run = MathRun(text: text, font: font, size: size, color: color)
        return try MathBox(
            width: measureText(run),
            height: metrics.textHeight(size: size),
            depth: metrics.textDepth(size: size),
            elements: [.text(run: run, x: 0, y: 0)],
        )
    }

    private func layoutFraction(
        numerator: MathNode,
        denominator: MathNode,
        size: Double,
        displayStyle: Bool,
    ) throws -> MathBox {
        let childSize = metrics.fractionChildSize(size: size)
        let numeratorBox = try layout(numerator, size: childSize, displayStyle: false)
        let denominatorBox = try layout(denominator, size: childSize, displayStyle: false)
        let padding = metrics.fractionPadding(size: size)
        let numeratorGap = metrics.fractionNumeratorGap(size: size, displayStyle: displayStyle)
        let denominatorGap = metrics.fractionDenominatorGap(size: size, displayStyle: displayStyle)
        let ruleThickness = metrics.fractionRuleThickness(size: size)
        let axisY = metrics.axisHeight(size: size)
        let ruleY = axisY - ruleThickness / 2
        let width = max(numeratorBox.width, denominatorBox.width) + padding * 2
        let numeratorBaseline = axisY + ruleThickness / 2 + numeratorGap + numeratorBox.depth
        let denominatorBaseline = axisY - ruleThickness / 2 - denominatorGap - denominatorBox.height
        let numeratorX = (width - numeratorBox.width) / 2
        let denominatorX = (width - denominatorBox.width) / 2

        var elements: [MathLayoutElement] = [
            .rule(x: 0, y: ruleY, width: width, height: ruleThickness, color: color),
        ]
        elements += numeratorBox.elements.map { $0.offsetBy(x: numeratorX, y: numeratorBaseline) }
        elements += denominatorBox.elements.map { $0.offsetBy(x: denominatorX, y: denominatorBaseline) }
        let ruleHeight = max(axisY + ruleThickness / 2, 0)
        let ruleDepth = max(-(axisY - ruleThickness / 2), 0)

        return MathBox(
            width: width,
            height: max(ruleHeight, numeratorBaseline + numeratorBox.height),
            depth: max(ruleDepth, abs(denominatorBaseline) + denominatorBox.depth),
            elements: elements,
        )
    }

    private func layoutRadical(
        _ radicand: MathNode,
        size: Double,
        displayStyle: Bool,
    ) throws -> MathBox {
        let radicandBox = try layout(radicand, size: metrics.radicalRadicandSize(size: size), displayStyle: displayStyle)
        let gap = metrics.radicalHorizontalGap(size: size)
        let verticalGap = metrics.radicalVerticalGap(size: size, displayStyle: displayStyle)
        let ruleThickness = metrics.radicalRuleThickness(size: size)
        let extraAscender = metrics.radicalExtraAscender(size: size)

        // The vinculum (overbar) sits above the radicand; the radical sign is two
        // strokes drawn as vectors so it scales with the radicand height instead
        // of being a fixed glyph. The up-stroke meets the left end of the vinculum.
        let overbarY = radicandBox.height + verticalGap
        let signWidth = max(size * 0.55, (overbarY + radicandBox.depth) * 0.42)
        let radicandX = signWidth + gap
        let valleyX = signWidth * 0.4
        let bottomY = -radicandBox.depth
        let leftY = overbarY * 0.45

        var elements: [MathLayoutElement] = [
            .line(x1: 0, y1: leftY, x2: valleyX, y2: bottomY, thickness: ruleThickness, color: color),
            .line(x1: valleyX, y1: bottomY, x2: signWidth, y2: overbarY, thickness: ruleThickness, color: color),
            .rule(x: signWidth, y: overbarY, width: radicandBox.width, height: ruleThickness, color: color),
        ]
        elements += radicandBox.elements.map { $0.offsetBy(x: radicandX, y: 0) }

        return MathBox(
            width: signWidth + gap + radicandBox.width,
            height: overbarY + ruleThickness + extraAscender,
            depth: radicandBox.depth,
            elements: elements,
        )
    }

    private func layoutScripts(
        base: MathNode,
        subscriptNode: MathNode?,
        superscriptNode: MathNode?,
        size: Double,
        displayStyle: Bool,
    ) throws -> MathBox {
        if displayStyle, base.isBigOperator {
            return try layoutLimits(
                base: base,
                lower: subscriptNode,
                upper: superscriptNode,
                size: size,
            )
        }

        let baseBox = try layout(base, size: size, displayStyle: displayStyle)
        let scriptSize = metrics.scriptSize(size: size)
        let subscriptBox = try subscriptNode.map { try scripted().layout($0, size: scriptSize, displayStyle: false) }
        let superscriptBox = try superscriptNode.map { try scripted().layout($0, size: scriptSize, displayStyle: false) }
        let scriptGap = metrics.spaceAfterScript(size: size)
        let scriptX = baseBox.width + scriptGap
        let superscriptY = metrics.superscriptShiftUp(size: size, baseBox: baseBox)
        let subscriptY = -metrics.subscriptShiftDown(size: size, baseBox: baseBox, scriptSize: scriptSize)

        var elements = baseBox.elements
        var scriptWidth = 0.0
        var height = baseBox.height
        var depth = baseBox.depth

        if let superscriptBox {
            elements += superscriptBox.elements.map { $0.offsetBy(x: scriptX, y: superscriptY) }
            scriptWidth = max(scriptWidth, superscriptBox.width)
            height = max(height, superscriptY + superscriptBox.height)
        }

        if let subscriptBox {
            elements += subscriptBox.elements.map { $0.offsetBy(x: scriptX, y: subscriptY) }
            scriptWidth = max(scriptWidth, subscriptBox.width)
            depth = max(depth, abs(subscriptY) + subscriptBox.depth)
        }

        return MathBox(
            width: baseBox.width + scriptGap + scriptWidth,
            height: height,
            depth: depth,
            elements: elements,
        )
    }

    private func layoutLimits(
        base: MathNode,
        lower: MathNode?,
        upper: MathNode?,
        size: Double,
    ) throws -> MathBox {
        let baseBox = try layout(base, size: metrics.displayOperatorSize(size: size), displayStyle: false)
        let scriptSize = metrics.scriptSize(size: size)
        let lowerBox = try lower.map { try scripted().layout($0, size: scriptSize, displayStyle: false) }
        let upperBox = try upper.map { try scripted().layout($0, size: scriptSize, displayStyle: false) }
        let upperGap = metrics.upperLimitGap(size: size)
        let lowerGap = metrics.lowerLimitGap(size: size)
        let width = max(baseBox.width, lowerBox?.width ?? 0, upperBox?.width ?? 0)
        let baseX = (width - baseBox.width) / 2

        var elements = baseBox.elements.map { $0.offsetBy(x: baseX, y: 0) }
        var height = baseBox.height
        var depth = baseBox.depth

        if let upperBox {
            let upperY = baseBox.height + upperGap + upperBox.depth
            elements += upperBox.elements.map { $0.offsetBy(x: (width - upperBox.width) / 2, y: upperY) }
            height = upperY + upperBox.height
        }

        if let lowerBox {
            let lowerY = -baseBox.depth - lowerGap - lowerBox.height
            elements += lowerBox.elements.map { $0.offsetBy(x: (width - lowerBox.width) / 2, y: lowerY) }
            depth = abs(lowerY) + lowerBox.depth
        }

        return MathBox(width: width, height: height, depth: depth, elements: elements)
    }
}

private extension Character {
    /// An ASCII letter or digit: what runs together with a neighbour of the same kind when the two are drawn side by side.
    var isASCIIWordCharacter: Bool {
        isASCII && (isLetter || isNumber)
    }
}

private extension MathNode {
    var isBigOperator: Bool {
        if case let .symbol(_, _, isBigOperator) = self {
            return isBigOperator
        }
        return false
    }
}
