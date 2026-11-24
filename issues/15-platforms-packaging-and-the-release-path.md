---
number: 15
title: "Platforms, packaging and the release path"
state: open
labels: ["before-1.0", "enhancement"]
assignees: []
created: 2026-11-24T10:26:42+01:00
updated: 2026-11-24T12:18:48+01:00
host: https://codeberg.org/MarkdownPDFHQ/MathTypeset/issues/15
synced: 2026-11-24T12:18:48+01:00 aaa9f6722d14
neutralized: 1
---

## What

Builds and tests are green on macOS and Linux (the workflows in the repository), the version history and the CHANGELOG are consistent, the licence files agree (AGPL and the commercial terms), the README install line names the 1.0 version, the release is an annotated tag with notes, and SemVer is stated: after 1.0 a breaking change is a major version.

## Why

A release is repeatable by hand from documented commands.

## Oracle first

The reference is a clean checkout on each platform: build, test and the release steps, run from the documentation alone.

## Acceptance

Both platforms pass from a clean checkout, the documented release steps work on a dry run, and the README and CHANGELOG match the tag.
