# Writes PR2.smp based on dis above
import os
import sys
import json
import pandas as pd
# assumes gmdsi/bin/python and flopy folder in the same level
python_exe_path = os.path.abspath(sys.executable)
three_up = os.path.dirname(os.path.dirname(os.path.dirname(python_exe_path)))
flopy_path = os.path.join(three_up)
print(f'Adding to sys.path: {flopy_path}')
sys.path.insert(0, flopy_path)
import flopy
print('Successfully imported flopy!')

model = flopy.modflow.Modflow.load('P2Wv9.1.nam', model_ws='../', check=False,  load_only=["dis"])


# Get stress period lengths (perlen)
perlen = model.dis.perlen.array  # array of stress period durations
start_date = pd.to_datetime("2012-01-01")
end_historical = pd.to_datetime("2018-12-31")
dates = [start_date + pd.to_timedelta(perlen[:i].sum(), unit='D') for i in range(len(perlen))]
df = pd.DataFrame({'stress_period': range(1, len(perlen) + 1), 'date': dates})
df1 = df[df["date"]<=end_historical] 
df = df[df["date"]>end_historical]
print("Reading dis..") 
print(df.head())
print(df.tail())
# Read cells from lst fil
with open('P2R.lst', 'r') as f:
        ids = [line.strip() for line in f if line.strip()]

# create smp lines
output_lines = []
for id_val in ids:
    for idx in df.index:
        dt = df.loc[idx, "date"]
        line = f"{id_val}\t{dt.strftime('%-m/%-d/%Y')}\t00:00:00\t-999.0000"
        output_lines.append(line)

# --- Write to output file ---
with open('P2R_dis.smp', 'w') as f:
    print("Writing P2R_dis.smp file")
    f.write('\n'.join(output_lines))

# Read JSON
with open('param.json', 'r') as f:
        data = json.load(f)

# Update the entry
data['numStressPeriods'] = len(df1) + len(df)

# Write back to file
with open('param.json', 'w') as f:
    print("updataing param.json with revised dis")
    json.dump(data, f, indent="\t")
