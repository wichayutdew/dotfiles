#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

for file in plan.md publish.md verify.md confirm.md; do
  content=$(<"$root/$file")
  if grep -qiE 'HTML format|raw UTF-8 HTML|resulting full HTML|source HTML|append HTML' <<<"$content"; then
    echo "$file still requires HTML Confluence publication" >&2
    exit 1
  fi
  if ! grep -qi 'Markdown' <<<"$content"; then
    echo "$file does not require Markdown Confluence publication" >&2
    exit 1
  fi
done

for file in plan.md publish.md verify.md confirm.md; do
  if ! grep -qi 'SHA-256' "$root/$file"; then
    echo "$file does not retain a SHA-256 publication guard" >&2
    exit 1
  fi
done
