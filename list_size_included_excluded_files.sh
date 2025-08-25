#!/bin/bash
set -euo pipefail

DIR="model_files"
DATE="$(date +%F)"
OUTDIR="./backups"
mkdir -p "$OUTDIR"

# extensions to exclude for regular files (symlinks are always included)
exts=(ftl cbb ucn hds UCN m3d log)

inc_csv="$OUTDIR/${DIR}_included_${DATE}.csv"
exc_csv="$OUTDIR/${DIR}_excluded_${DATE}.csv"

echo 'type,size_hr,size_bytes,path' > "$inc_csv"
echo 'size_hr,size_bytes,path'      > "$exc_csv"

# ---- Build find expressions from the array ----
# Included: symlinks OR regular files that do NOT match excluded extensions
inc_find=( \( -type l -o \( -type f )
for ext in "${exts[@]}"; do
  inc_find+=( ! -name "*.${ext}" )
done
inc_find+=( \) \) -print0 )

# Excluded: regular files that DO match excluded extensions
exc_find=( -type f \( )
for i in "${!exts[@]}"; do
  exc_find+=( -name "*.${exts[$i]}" )
  [[ $i -lt $((${#exts[@]}-1)) ]] && exc_find+=( -o )
done
exc_find+=( \) -print0 )

# ---- Included files (sizes); symlinks report target size if resolvable ----
(
  cd "$DIR"
  find . "${inc_find[@]}" | sort -z \
  | while IFS= read -r -d '' p; do
      if [ -L "$p" ]; then
        # symlink: target size (0 if broken)
        if stat -L -c %s -- "$p" >/dev/null 2>&1; then
          bytes=$(stat -L -c %s -- "$p")
        else
          bytes=0
        fi
        typ=l
      else
        bytes=$(stat -c %s -- "$p")
        typ=f
      fi
      hr=$(numfmt --to=iec --suffix=B "$bytes" 2>/dev/null || printf '%sB' "$bytes")
      esc=${p//\"/\"\"}
      printf '%s,%s,%s,"%s"\n' "$typ" "$hr" "$bytes" "$esc"
    done
) >> "$inc_csv"

# ---- Excluded files (sizes) ----
(
  cd "$DIR"
  find . "${exc_find[@]}" | sort -z \
  | while IFS= read -r -d '' p; do
      bytes=$(stat -c %s -- "$p")
      hr=$(numfmt --to=iec --suffix=B "$bytes" 2>/dev/null || printf '%sB' "$bytes")
      esc=${p//\"/\"\"}
      printf '%s,%s,"%s"\n' "$hr" "$bytes" "$esc"
    done
) >> "$exc_csv"

# ---- Sort CSVs: largest to smallest by size_bytes ----
# included: size_bytes is column 3
{ head -n1 "$inc_csv"; tail -n +2 "$inc_csv" | LC_ALL=C sort -t, -k3,3nr; } > "${inc_csv}.tmp"
mv -f "${inc_csv}.tmp" "$inc_csv"

# excluded: size_bytes is column 2
{ head -n1 "$exc_csv"; tail -n +2 "$exc_csv" | LC_ALL=C sort -t, -k2,2nr; } > "${exc_csv}.tmp"
mv -f "${exc_csv}.tmp" "$exc_csv"

echo "Wrote (sorted): $inc_csv"
echo "Wrote (sorted): $exc_csv"


