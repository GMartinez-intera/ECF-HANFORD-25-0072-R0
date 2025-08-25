#!/bin/bash

OLD="/state/partition1/chprc/src/pest/gwutils/"
NEW="/data/projects/cpcco/src/pest/gwutils/"

find /data/projects/gmartinez/ECF-HANFORD-25-0072-R0/model_files/modl/bc/base/tran/nsbs/tc99 -type l | while read link; do
  TARGET=$(readlink "$link")
  if [[ "$TARGET" == "$OLD"* ]]; then
    echo "🔄 Modification du lien : $link"
    rm "$link"
    NEW_TARGET="${TARGET/$OLD/$NEW}"
    ln -s "$NEW_TARGET" "$link"
  fi
done

