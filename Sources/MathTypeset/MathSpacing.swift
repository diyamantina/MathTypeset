/// The space between two neighbouring atoms of a formula, in mu (1 mu = 1/18 of the font size), as a function of their classes.
///
/// The facts are the ones of the table of the TeXbook (chapter 18, page 170), stated here as rules by the class that causes the
/// space (a binary operator: medium; a relation: thick; the operators, the inner atoms and the punctuation: thin) and not as the
/// matrix; the tests hold the matrix, typed apart, and require the two to agree on every pair in every style.
enum MathSpacing {
    static let thin = 3
    static let medium = 4
    static let thick = 5

    /// The space in mu between `left` and `right`, in a style that is large (display and text) or not (script and scriptscript),
    /// or nil for a pair that cannot occur (a binary operator that has not been turned into an ordinary atom).
    static func mu(between left: MathAtomClass, and right: MathAtomClass, largeStyle: Bool) -> Int? {
        // A binary operator has its two operands: the other atom is one that can be an operand.
        if left == .bin {
            guard [.ord, .op, .open, .inner].contains(right) else {
                return nil
            }
            return largeStyle ? medium : 0
        }
        if right == .bin {
            guard [.ord, .close, .inner].contains(left) else {
                return nil
            }
            return largeStyle ? medium : 0
        }
        // A relation: thick on both sides, except between two relations and next to a closing or punctuation atom after it,
        // and after an opening atom.
        if left == .rel {
            return [.rel, .close, .punct].contains(right) ? 0 : (largeStyle ? thick : 0)
        }
        if right == .rel {
            return left == .open ? 0 : (largeStyle ? thick : 0)
        }
        // The thin spaces. Next to an operator they stay in every style: an ordinary, an operator, a closing or an inner atom
        // before an operator, and an operator before an ordinary or an operator.
        if right == .op, [.ord, .op, .close, .inner].contains(left) {
            return thin
        }
        if left == .op, [.ord, .op].contains(right) {
            return thin
        }
        // Only in the large styles: after punctuation (before anything), before an inner atom (after anything but an opening
        // atom), and after an inner atom (before anything but a closing atom).
        if left == .punct {
            return largeStyle ? thin : 0
        }
        if right == .inner, left != .open {
            return largeStyle ? thin : 0
        }
        if left == .inner, right != .close {
            return largeStyle ? thin : 0
        }
        return 0
    }
}
