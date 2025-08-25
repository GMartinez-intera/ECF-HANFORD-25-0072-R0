import flopy
import matplotlib.pyplot as plt

# Path to your MODFLOW model
model_path = "."
namefile = "P2RBC.nam"

# Load the MODFLOW model
mf = flopy.modflow.Modflow.load(namefile, model_ws=model_path, check=False, verbose=True, forgive=True)

# Get the CHD package
chd = mf.get_package("CHD")

# Specify the stress period and layer to visualize
selected_sp = 0  # 0-based index
selected_layer = 2  # layer number

# Extract and visualize CHD data for the selected stress period and layer
if chd is not None:
    try:
        sp_data = chd.stress_period_data.data[selected_sp]
        print(sp_data)

        # Filter entries by selected layer
        filtered_data = [entry for entry in sp_data if entry[0] == selected_layer]

        # Extract row and column indices
        rows = [entry[1] for entry in filtered_data]
        cols = [entry[2] for entry in filtered_data]

        # Plot the CHD locations on a grid
        plt.figure(figsize=(8, 6))
        plt.scatter(cols, rows, c='blue', marker='s', label=f'CHD Layer {selected_layer}')
        plt.gca().invert_yaxis()
        plt.title(f"CHD Locations for Stress Period {selected_sp + 1}, Layer {selected_layer}")
        plt.xlabel("Column")
        plt.ylabel("Row")
        plt.legend()
        plt.grid(True)
        print(f"modflow_CHD_layer_{selected_layer}_time{selected_sp + 1}.png")
        filename = f"modflow_CHD_layer_{selected_layer}_time{selected_sp + 1}.png"
        plt.savefig(filename, dpi=300)

    except KeyError:
        print(f"Stress Period {selected_sp + 1} not found in CHD data.")
else:
    print("CHD package not found in the model.")
