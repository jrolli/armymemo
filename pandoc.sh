#!/usr/bin/env bash
# Compile a Markdown memo to PDF via pandoc.typ, regardless of the caller's
# working directory.
#
#   pandoc.sh <source.md> <output.pdf>

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $(basename "$0") <source.md> <output.pdf>" >&2
  exit 1
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pandoc "$1" \
  --template="$root/pandoc.typ" \
  --pdf-engine=typst \
  -o "$2"
