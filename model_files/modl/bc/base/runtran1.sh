#!/usr/bin/bash
# Activate virtual environment if needed
source /data/projects/cpcco/python/gmdsi/bin/activate

# Add custom library paths (adjust if subfolders are different)
export PYTHONPATH="/data/projects/cpcco/python:$PYTHONPATH"

echo ""
echo "Reminder:"
echo "  Start a screen session before running this script:"
echo "    screen -S modflow_run"
echo "  If you disconnect, reattach with:"
echo "    screen -r modflow_run"
echo ""

current_dir=$(pwd)
LOGFILE="${current_dir}/loginf.txt"


#### GENER CHD
cd ./flow/chdp || exit 1

echo ""
echo "Running run_generate_chd.sh (MOD2OB)"
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Running run_generate_chd.sh - MOD2OB" >> "$LOGFILE"
echo "in this directory"
echo "$PWD"
echo ""

./run_generate_chd2.sh

echo "[`date '+%Y-%m-%d %H:%M:%S'`] Executing run_generate_chd.sh" >> "$LOGFILE"

### GENER initial heads

cd .. || exit 1

#echo ""
#echo "[`date '+%Y-%m-%d %H:%M:%S'`] Create initial heads" >> "$LOGFILE"
#echo ""

#python srt_heads3.py

#echo ""
#echo "[`date '+%Y-%m-%d %H:%M:%S'`] Initial heads processed v3" >> "$LOGFILE"
#echo "See log run_srt_heads.log"
#echo ""

echo "Use start heads from ECF-200BC1-24-0049-R0"


# Run the flow model from within the flow folder
echo "Running flow model..."
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Running flow model..." >> "$LOGFILE"



./mf2k-mst-cpcc09dpl.x P2RBC.nam > flow_output.log 2>&1
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Executing MODFLOW model" >> "$LOGFILE"

# Check for successful termination message
if grep -q "Normal termination of MODFLOW-2000" flow_output.log; then
 echo "Flow model completed successfully."
else
 echo "Flow model did not terminate normally. Check flow_output.log for details."
 exit 1
fi

# Move to the tran folder
cd ../tran || exit 1

# Update CTS package
cd ./cts_ || exit 1

echo "Reminder:"
echo "  Update m3d2cts.in file if needed"
echo ""

#prepare cts template file
./m3d2cts_dp.x < m3d2cts.in
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Preparing CTS template file" >> "$LOGFILE"

# replace efficiency values for each coc
declare -A values=(
  [crvi]="-0.203"
  [cyan]="-0.987"
  [ctet]="-0.999"
  [i129]="0.000"
  [no3_]="0.000"
  [sr90]="0.000"
  [tce_]="-0.857"
  [tc99]="-0.921"
  [trit]="0.000"
  [utot]="-0.992"
)

for key in "${!values[@]}"; do
  sed "s/replacval/    ${values[$key]}    /g" template.cts > "../tran/cts_/P2RBC_${key}.cts"
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Updating CTS file for ${key}" >> "$LOGFILE"
done

## Move to the tran folder
#cd ..
#
#echo "CTS packages are updated with the efficiency values" $cn
#
## run transport package
#for cn in 'crvi' 'cyan' 'ctet' 'i129' 'no3_' 'sr90' 'tc99' 'tce_' 'trit' 'utot'
#do
#  cd ./nsbs/$cn || { echo "Directory ./nsbs/$cn not found."; exit 1; }
#
#  # Run the transport model
#  echo "Running transport model for:" $cn
#echo "[`date '+%Y-%m-%d %H:%M:%S'`] "Running transport model for:" $cn" >> "$LOGFILE"
#  ./mt3d-mst-cpcc09dpl.x P2RGWM.nam mst dry1 dry2 > tran_output.log 2>&1
#echo "[`date '+%Y-%m-%d %H:%M:%S'`] Executing transport model for $cn" >> "$LOGFILE"
#
#  # Check for successful completion message
#  if tail -n 20 tran_output.log | grep -q "Program completed.   Total CPU time:"; then
#    echo "Transport model for $cn completed successfully."
#  else
#    echo "Transport model for $cn did not complete normally. Check tran_output.log for details."
#    exit 1
#  fi
#
#  cd ../..
#done
#
#echo "All models completed successfully."
#echo "[`date '+%Y-%m-%d %H:%M:%S'`] All models completed successfully." >> "$LOGFILE"
