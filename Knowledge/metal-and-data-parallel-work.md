# Metal and the performance work here (2026-11-26)

- MEASURED (search of `Sources` on `main` at a78b230 for imports of `Metal`, `MetalKit`, `Accelerate`, `simd` and `CoreImage`): none.
- The work (reading font tables and laying out a formula) is serial, full of branches, small and has to be exact. That is not the shape of work a GPU speeds up. UNVERIFIED: its cost; there is one layout path and no benchmark yet.
- No Metal path is planned unless a profile names data-parallel work that holds a real share of a run. Even then SIMD or Accelerate comes first, behind a paired release number, with an exact differential test.
- What decides: the benchmark target and the profile of issue 11.
