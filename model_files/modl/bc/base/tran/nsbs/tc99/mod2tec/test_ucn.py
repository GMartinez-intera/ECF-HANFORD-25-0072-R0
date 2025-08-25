import flopy

# Load the UCN file with specified precision
ucn_file = "../P2RGWM.ucn"

ucn = flopy.utils.UcnFile(ucn_file, precision='double')  # or 'double'

# Get all available times in the file
times = ucn.get_times()
print("Simulation times:", times)

# Get all available (kstp, kper) pairs
kstpkper_list = ucn.get_kstpkper()
print("Time step and stress period pairs:", kstpkper_list)

# Number of stress periods (unique kper values)
stress_periods = set(kper for _, kper in kstpkper_list)
print("Number of stress periods:", len(stress_periods))

# Number of time steps (unique kstp values per stress period)
from collections import defaultdict
time_steps = defaultdict(set)
for kstp, kper in kstpkper_list:
    time_steps[kper].add(kstp)

print("Time steps per stress period:")
for kper in sorted(time_steps):
    print(f"  Stress period {kper}: {len(time_steps[kper])} time steps")
