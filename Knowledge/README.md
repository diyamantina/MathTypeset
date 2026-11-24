# Knowledge: what was learned while building MathTypeset

Every claim carries one of four marks: MEASURED (read in a run, with the test or the command that holds it), DERIVED (follows from the code or a specification by an argument written next to it), DOCUMENTED (a document says it, named) and UNVERIFIED (not run). Markdown only.

## Index

- [math-spacing.md](math-spacing.md): the space between math atoms: `tex.web` is the authority of the table, KaTeX differs in one cell, the rules for groups, operator names and typed spaces, and the named limits.

- [math-table-reader.md](math-table-reader.md): how the MATH table reader is checked: the table built from a closed form, the independent read, the order of the constants, the bound on a coverage, the hostile-bytes cases.
