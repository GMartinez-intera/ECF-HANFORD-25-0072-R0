import flopy

# Path to your MODFLOW model
model_path = "."
namefile = "P2RBC.nam"

# Load the MODFLOW model
mf = flopy.modflow.Modflow.load(namefile, model_ws=model_path, check=False, verbose=True, forgive=True)

# Get the CHD package
chd = mf.get_package("CHD")

# Specify the stress period and layer to extract
selected_sp = 0  # stress period index (0-based)
selected_layer = 1  # layer number

# Extract CHD data for the specified stress period and layer
if chd is not None:
    try:
        sp_data = chd.stress_period_data.data[selected_sp]
        filtered_data = [entry for entry in sp_data if entry[0] == selected_layer]

        print(f"CHD data for Stress Period {selected_sp + 1}, Layer {selected_layer}:")
        for entry in filtered_data:
            print(entry)
    except KeyError:
        print(f"Stress Period {selected_sp + 1} not found in CHD data.")
else:
    print("CHD package not found in the model.")

