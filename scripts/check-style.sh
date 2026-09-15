#!/usr/bin/env bash
# Repo-wide style gate: no em dashes, no tool-attribution phrases, no signature
# emojis in any tracked text file. Mirrors the .githooks checks, run over the
# whole tree in CI so a bypassed local hook is still caught at merge time.
#
# Portable: BSD-compatible grep, bash 3.2 (macOS) and bash 4+ (CI).

set -u

FAIL=0

# Em dash U+2014, built via printf so this script contains no em-dash byte.
EMDASH=$(printf '\xe2\x80\x94')

# Enforcement files legitimately contain the forbidden phrases in order to
# detect them, so exclude them from the phrase scan.
is_enforcement_file() {
  case "$1" in
    .githooks/*|scripts/check-style.sh) return 0 ;;
    *) return 1 ;;
  esac
}

# Tool-attribution phrases. Tool-agnostic: any AI assistant or its vendor, not
# just one. Vendor tokens are assembled from fragments so this script does not
# contain the full literals (which would self-flag in other scanners, including
# the shared-rules leak gate).
# Bare tool names are NOT flagged (that would false-positive on legitimate text
# like "fix cursor blink"); only attribution-context mentions are.
V1="Cla""ude"
V2="Anthr""opic"
V3="Open""AI"
V4="Chat""GPT"
V5="Cop""ilot"
V6="Gem""ini"
AI_TOOLS="$V1|$V2|Codex|$V3|$V4|GPT-[0-9]|Cursor|$V5|$V6|Google AI"
ATTRIB_REGEX="(Co-Authored-By|Co-authored-with|Generated (with|by)|Created (with|by)|Powered by|with help from|written by|authored by)[: ].*($AI_TOOLS)"
# Generic self-reference tells, independent of any vendor name.
GENERIC_PHRASES=(
  "as an AI"
)

# Signature emojis used as a flourish (UTF-8 bytes kept in a variable so the
# script source stays clean of the glyphs themselves).
EMOJI_TELLS=$(printf '\xf0\x9f\xa4\x96\n\xe2\x9c\xa8\n\xf0\x9f\xaa\x84\n\xf0\x9f\xa7\xa0\n\xf0\x9f\xa6\xbe\n\xf0\x9f\xa4\x9d')

while IFS= read -r f; do
  [ -f "$f" ] || continue
  if ! LC_ALL=C grep -Iq . "$f" 2>/dev/null; then
    continue
  fi
  if LC_ALL=C grep -qF -- "$EMDASH" "$f" 2>/dev/null; then
    echo "style: em dash (U+2014) in $f" >&2
    FAIL=1
  fi
  if ! is_enforcement_file "$f"; then
    if LC_ALL=C grep -qiE -- "$ATTRIB_REGEX" "$f" 2>/dev/null; then
      echo "style: forbidden attribution phrase in $f" >&2
      FAIL=1
    fi
    for p in "${GENERIC_PHRASES[@]}"; do
      if LC_ALL=C grep -qF -- "$p" "$f" 2>/dev/null; then
        echo "style: forbidden attribution phrase in $f" >&2
        FAIL=1
      fi
    done
    while IFS= read -r emoji; do
      [ -z "$emoji" ] && continue
      if LC_ALL=C grep -qF -- "$emoji" "$f" 2>/dev/null; then
        echo "style: signature emoji in $f" >&2
        FAIL=1
        break
      fi
    done <<<"$EMOJI_TELLS"
  fi
done < <(git ls-files)

if [ "$FAIL" -ne 0 ]; then
  echo "style: gate failed. Rules: git-discipline 5.1 (attribution) and 5.2 (em dashes)" >&2
fi
exit "$FAIL"
