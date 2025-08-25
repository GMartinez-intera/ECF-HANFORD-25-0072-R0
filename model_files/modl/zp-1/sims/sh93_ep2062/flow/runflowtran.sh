#!/usr/bin/bash

echo "Reminder:"
echo "  Start a screen session before running this script:"
echo "    screen -S modflow_run"
echo "  If you disconnect, reattach with:"
echo "    screen -r modflow_run"
echo ""

# Run the flow model from within the flow folder
echo "Running flow model..."

./mf2k-mst-cpcc09dpl.x P2Wv9.1.nam > flow_output.log 2>&1

# Check for successful termination message
if grep -q "Normal termination of MODFLOW-2000" flow_output.log; then
 echo "Flow model completed successfully."
else
 echo "Flow model did not terminate normally. Check flow_output.log for details."
 exit 1
fi

# Move to the tran folder
cd ../tran || exit 1

# Run the transport model
echo "Running transport model..."
./mt3d-mst-cpcc09dpl.x P2RGWM.nam mst dry1 dry2 > tran_output.log 2>&1

# Check for successful completion message at the end of tran_output.log
if tail -n 20 tran_output.log | grep -q "Program completed.   Total CPU time:"; then
  echo "Transport model completed successfully."
else
  echo "Transport model did not complete normally. Check tran_output.log for details."
  exit 1
fi

echo "All models completed successfully."
