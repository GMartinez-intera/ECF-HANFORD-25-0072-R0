#!/bin/bash

DIR="model_files"

OUT="./backups/${DIR}_sh_py_$(date +%F).tar.gz"

( cd "$DIR" && find . -type f \( -name '*.sh' -o -name '*.py' \) -print0 ) \
| tar --null -czf "$OUT" -C "$DIR" --files-from -

