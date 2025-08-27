#!/bin/bash

# Activate virtual environment if needed
source /data/projects/cpcco/python/gmdsi/bin/activate

# Add custom library paths (adjust if subfolders are different)
export PYTHONPATH="/data/projects/cpcco/python:$PYTHONPATH"

echo ""
echo "Create initial heads v3"
echo ""

python srt_heads3.py
echo ""
echo "Initial heads processed"
echo "See log run_srt_heads.log"
echo ""
