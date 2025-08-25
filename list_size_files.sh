#!/bin/bash
mkdir -p ./backups
DIR="model_files"
OUT="./backups/${DIR}_files_by_size_$(date +%F).csv"
echo 'size_hr,size_bytes,path' > "$OUT"
find "$DIR" -type f -printf '%s\t%p\0' \
| sort -z -t $'\t' -k1,1n \
| while IFS= read -r -d '' rec; do
    bytes=${rec%%$'\t'*}
    path=${rec#*$'\t'}
    hr=$(numfmt --to=iec --suffix=B "$bytes" 2>/dev/null || printf '%sB' "$bytes")
    path=${path//\"/\"\"}
    printf '%s,%s,"%s"\n' "$hr" "$bytes" "$path" >> "$OUT"
  done
echo "Wrote: $OUT"

