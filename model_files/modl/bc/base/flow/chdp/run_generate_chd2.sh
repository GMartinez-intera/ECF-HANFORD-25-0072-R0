#!/bin/bash
# Activate virtual environment if needed
source /data/projects/cpcco/python/gmdsi/bin/activate

# Add custom library paths (adjust if subfolders are different)
export PYTHONPATH="/data/projects/cpcco/python:$PYTHONPATH"

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# === CONFIGURATION ===
MOD2OBS_EXEC="./mod2obs_d.x"
MOD2OBS_INPUT="mod2obs_prd.in"
CHD_SPLIT_INPUT="P2RBC_chd.out"
CHD_GENERATE_INPUT="grid_BC_chd.txt"
CHD_OUTPUT="P2RBC.chd"
SYMLINK_TARGET="chdp/${CHD_OUTPUT}"  #link toward the chd pack in the chdp directory
LOG_FILE="run_chd_pipeline.log"

# === FUNCTIONS ===

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_file_exists() {
    if [[ ! -f "$1" ]]; then
        log "ERROR: Required file '$1' not found."
        exit 1
    fi
}

# === SCRIPT START ===

log "Starting CHD generation pipeline..."

# Reminder
log "Reminder: Ensure 'parameter.json' is updated before running."

# Show CHD extraction source
log "CHD extraction source: $(readlink -f P2Rv9.1.hds)"

# Run MOD2OBS
check_file_exists "$MOD2OBS_INPUT"
log "Running MOD2OBS..."
$MOD2OBS_EXEC < "$MOD2OBS_INPUT"

# Run Python scripts
check_file_exists "$CHD_SPLIT_INPUT"
log "Running split_chd.py..."
python split_chd.py "$CHD_SPLIT_INPUT" w

check_file_exists "$CHD_GENERATE_INPUT"
log "Running chdgenerate.py..."
python chdgenerate.py --c "$CHD_GENERATE_INPUT" --o "$CHD_OUTPUT"

# Create symlink
log "Creating symlink to flow directory..."
cd ..
ln -sf "$SYMLINK_TARGET" "$CHD_OUTPUT"
log "CHD generation pipeline completed successfully."
