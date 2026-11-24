# The space between math atoms: the authority, the classes and the limits

## What the layout does

Every node of a formula gets one of eight classes (ordinary, operator, binary, relation, opening, closing, punctuation, inner), and the layout puts a space between neighbours that depends on the two classes: thin 3 mu, medium 4 mu, thick 5 mu, one mu being 1/18 of the font size. Some entries exist only in the display and text styles (the book prints them in parentheses). A binary operator that has no operand on one side becomes an ordinary atom first. The code is `MathAtomClass.swift` (the class of a node), `MathSpacing.swift` (the space of a pair, stated as rules by the class that causes it) and `layoutSequence` in `MathLayout.swift`.

## The authority for the table, and why it is not KaTeX

DOCUMENTED (the source of Knuth's program, read from the CTAN archive): the table is the 64-digit string `math_spacing` of `tex.web`: `0234000122*4000133**3**344*0400400*000000234000111*1111112341011`. Its digits mean 0 no space, 1 a conditional thin space (display and text styles only), 2 a thin space, 3 a conditional medium space, 4 a conditional thick space, `*` a pair that cannot occur. The string is kept as data in `Tests/MathTypesetTests/MathSpacingTeXWebData.swift` and `matrixEqualsTeXWeb` compares all 64 cells of the answer key with it. The printed page of the TeXbook was not compared (UNVERIFIED that it is the same table).

MEASURED (the data file of KaTeX 0.16.11, `spacingData.js`, read from the package host): KaTeX differs from TeX in exactly one pair: punctuation followed by a relation is a thick space in KaTeX and a conditional thin space in `tex.web`. The test `katexDiffersInOneCell` pins that as the only difference. How it was found: the answer key was first typed from memory and compared with KaTeX; the one differing cell was settled by the primary source, not by the witness, because the author's memory and a reviewer's agreed with each other and a data file of a reimplementation is a witness. Two correlated memories do not settle a cell.

## What the code does about the cases a table does not state

- DOCUMENTED (TeX): a group is one ordinary atom whatever it holds. The parser keeps a braced group or a `\text` group that holds one non-ordinary character or symbol as a one-element sequence, so `1{,}5` has no space at the comma and `{-}` is not binary.
- DOCUMENTED (LaTeX): `\frac` is a braced group, hence one ordinary atom. A fraction is ordinary here, not inner.
- A typed space is ignored, as in TeX; explicit spacing commands (`\,`, `\:`, `\;`, `\!`, `\quad`, the control space) stay. One exception: in the ASCII fallback two symbols drawn as words (`\alpha \beta` drawn "alpha" and "beta") keep their typed space when the classes give no space between them, or they would run together.
- A symbol of plain ASCII text is an operator: the function names (`\sin`) and every `\operatorname{...}`. MEASURED: before this rule, `\operatorname{argmax}` threw an error for a symbol with no class and the document renderer drew the formula as its source; the error is still raised, by name, for a non-ASCII symbol that has no class (`LayoutError.unclassifiedSymbol`).
- A character typed as Unicode (`≤`, `∈`, `→`, `×`, `±`) has the class of the command of the same character. The angle brackets of `\left` and `\right` open and close; `\{` and `\}` open and close.
- The content of a script and the limits of a big operator are laid out in the script style (the conditional entries absent). The four-level style cascade is not here: a fraction's parts keep the style they are in.

## Limits, named

- UNVERIFIED: the class of each symbol is typed by the author in `MathAtomClass.swift`; a test sees that every command of the parser's table has a class, not that each class is right. The sets of binary operators, relations and punctuation were compared with those of the vendored matplotlib source by an independent reviewer (no conflict found), not by the author.
- `\left ... \right` is laid out as one ordinary atom (TeX makes it an inner atom), and its delimiters other than the angle brackets are classed by character (`\left|` is ordinary; TeX gives open and close). Sized delimiters (`\big`) are classed by character and not by the `l`, `r` or `m` of their command.
- Stretch and shrink of the spaces (natural widths only), line breaking, and the cramped styles are not here.
- MEASURED in MarkdownPDF's corpus: the glue reaches display math only; inline math in running text is drawn on another path (UNVERIFIED which) and did not move.

## How the rest was checked

- The answer key was written and run red first against the layout of that day: 4,087 of 4,680 sequences of up to four atoms differed (the layout added no space at all). It is green now. Five planted faults (a thin entry made thick, the style flag ignored, a cancellation rule removed, thin and medium swapped, an unknown symbol taken as ordinary) each turn it red.
- The tests for groups, Unicode operators, the angle brackets, set braces, limits, the fallback words and the operator names were written after the cases were found (by a reviewer, and by reading the changed PDFs of a corpus with the library's own reader), so they were not red before their fixes.
