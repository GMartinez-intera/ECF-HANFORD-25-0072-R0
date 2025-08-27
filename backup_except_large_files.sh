#!/bin/bash
set -euo pipefail

DIR="model_files"
OUT="./backups/${DIR}_exceptlarge_$(date +%F).tar.gz"
mkdir -p ./backups

# patterns to exclude (suffixes), including multi-dot ones
patterns=( ".ftl" ".cbb" ".ucn" ".UCN" ".hds" ".m3d" ".log" ".tar.gz" ".zip"  ".lst" ".CTO")

# Build the find expression: keep symlinks and directories;
# include only regular files that DON'T match excluded patterns
find_expr=( \( -type l -o -type d -o \( -type f )
for pat in "${patterns[@]}"; do
	  find_expr+=( ! -name "*${pat}" )
  done
  find_expr+=( \) \) -print0 )

  # List paths from within $DIR, then let tar read them without recursing
  ( cd "$DIR" && find . "${find_expr[@]}" ) \
	    | tar -C "$DIR" --null --no-recursion -cvzf "$OUT" --files-from=-

  # Verify
  tar -tzf "$OUT" | head

