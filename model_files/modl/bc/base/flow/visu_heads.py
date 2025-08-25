import flopy
import matplotlib.pyplot as plt
import numpy as np
import os

# Path to your model
model_path = "."
namefile = "P2RBC.nam"

# Load the model
mf = flopy.modflow.Modflow.load(namefile, model_ws=model_path, check=False, verbose=True, forgive=True)

# Load head data
headobj = flopy.utils.HeadFile(os.path.join(model_path, f"{mf.name}.hds"))
times = headobj.get_times()

# Select layers to plot
layers_to_plot = [6]  # Add more layers if needed, e.g., [0, 1, 2]

# Loop through time steps and layers
for totim in times:
    head = headobj.get_data(totim=totim)
    for layer in layers_to_plot:
        head_filtered = np.where(head < -100, np.nan, head)
        valid_data = head_filtered[layer][~np.isnan(head_filtered[layer])]
        levels = np.linspace(np.nanmin(valid_data), np.nanmax(valid_data), 10) if valid_data.size > 0 else []

        fig, ax = plt.subplots(figsize=(8, 6))
        mapview = flopy.plot.PlotMapView(model=mf, layer=layer)
        mapview.plot_grid()

        if len(levels) > 0:
            contour = mapview.contour_array(head_filtered[layer], levels=levels)
            plt.clabel(contour, inline=1, fontsize=10)

        plot_array = mapview.plot_array(head_filtered[layer])
        plt.colorbar(plot_array, ax=ax, label="Head (m)")
        plt.title(f"MODFLOW Grid and Head - Layer {layer} - Time {totim}")
        plt.tight_layout()

        filename = f"modflow_heads_layer{layer}_time{totim:.2f}.png"
        plt.savefig(filename, dpi=300)
        plt.close()
