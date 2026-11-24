/// The table of the space between two atoms as Knuth's own source states it: the 64 digits of `math_spacing` of `tex.web`, read from
/// the file of the CTAN archive (the section on typesetting math formulas, after `mlist_to_hlist`). The string is a fact of the
/// program, kept here as data; none of the surrounding text is copied.
///
/// The digits (from the comment before the string in the file): 0 no space; 1 a conditional thin space (only in the display and
/// text styles); 2 a thin space; 3 a conditional medium space; 4 a conditional thick space; `*` an impossible case. The rows are the
/// left atom and the columns the right atom, in the order ord, op, bin, rel, open, close, punct, inner.
enum MathSpacingTeXWebData {
    static let mathSpacing = "0234000122*4000133**3**344*0400400*000000234000111*1111112341011"

    /// The entry of the table for two classes, as the same `Entry` the answer key uses, or nil for a star.
    static func entry(left: MathSpacingReference.AtomClass, right: MathSpacingReference.AtomClass) -> MathSpacingReference.Entry? {
        let characters = Array(mathSpacing)
        let digit = characters[left.rawValue * 8 + right.rawValue]
        switch digit {
        case "0": return MathSpacingReference.Entry(mu: 0, onlyInLargeStyles: false)
        case "1": return MathSpacingReference.Entry(mu: 3, onlyInLargeStyles: true)
        case "2": return MathSpacingReference.Entry(mu: 3, onlyInLargeStyles: false)
        case "3": return MathSpacingReference.Entry(mu: 4, onlyInLargeStyles: true)
        case "4": return MathSpacingReference.Entry(mu: 5, onlyInLargeStyles: true)
        default: return nil
        }
    }
}
