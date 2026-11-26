---
number: 15
title: "Platforms, packaging and the release path"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:26:42+01:00
updated: 2026-11-24T13:25:15+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/15
synced: 2026-11-24T13:25:15+01:00 cb49726d97f1
neutralized: 2
---

## What

Builds and tests are green on macOS and Linux (the workflows in the repository), the version history and the CHANGELOG are consistent, the licence files agree (AGPL and the commercial terms), the README install line names the 1.0 version, the release is an annotated tag with notes, and SemVer is stated: after 1.0 a breaking change is a major version.

## Why

A release is repeatable by hand from documented commands.

## Oracle first

The reference is a clean checkout on each platform: build, test and the release steps, run from the documentation alone.

## Acceptance

Both platforms pass from a clean checkout, the documented release steps work on a dry run, and the README and CHANGELOG match the tag.

## Comments

### Mihaela, 2026-11-24T13:25:15+01:00

Correction after reading the code on 2026-11-24. The tags 0.5.0, 0.6.0 and 0.7.0 are lightweight, only 0.1.0 to 0.4.0 are annotated; 1.0 is annotated. No release steps are documented (the contributing guide covers build, test and style), and the sentence that after 1.0 a breaking change is a major version is not written anywhere. The package depends on the DocC plugin hosted on GitHub: replace it or move the documentation build off the package dependency list, because the owner's repositories avoid GitHub. The manifest declares no platforms; the macOS workflow pins no Swift version and no workflow builds in release mode; the namespacing script cites a rules document that does not exist; the README badges and the issue host URLs differ in the case of the organisation name.
