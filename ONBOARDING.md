# Onboarding (2026-11-26)

## Purpose

A Swift library that lays out a subset of TeX math. Start with `README.md`, `Knowledge/` and `docs/todo/continuation-1-0.md`.

## State

- Main before this file: `451b45d`. Last release: `0.8.0` (atom classes and TeX spacing). Nothing newer is released.
- 18 open issues, mirrored in `issues/`. Issue 1 tracks 1.0.

## Done on 2026-11-26

- A knowledge note on the Metal survey.
- The last issue cleanup added "blocked by issue 2" notes to eight issues.

## In flight and local only

Nothing is uncommitted. The local branch `handover-1-0` holds one commit whose change is already on main.

## Next steps

- `docs/todo/continuation-1-0.md` was written on 2026-11-24, before release 0.8.0. Read it with the changelog: some of its description of the code is out of date.
- Issue 2 (the answer key for every correctness surface) blocks the engine work.

## Waiting on the owner

The 1.0 decision recorded in the continuation note (a TeX-grade layout engine before 1.0) can be reversed only until the engine work starts.

## Build, test, publish

```sh
git config core.hooksPath .githooks
swift build
swift test
```

Releases need the owner's yes.
