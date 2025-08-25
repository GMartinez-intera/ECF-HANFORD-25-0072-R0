import sys
import os
import numpy as np
from scipy.interpolate import NearestNDInterpolator
from scipy.interpolate import LinearNDInterpolator
import flopy
import logging
# import custom python modules
sys.path.append('/data/projects/gmartinez/ECF-HANFORD-25-0072-R0/model_files') 
from spc2spc import *


# === CONFIGURATION ===
# Model coordinates
modelxll = 557800.00
modelyll = 116200.00
gridangle = 0.0
namefile = 'P2R.nam'
model_ws = '../../../stwd/sims/sh93/pred/'
firstSPCpath ="../../../stwd/comm/flow/geo_/P2Rv9.1_SW.spc" # parent model
secondSPCpath ="spc/P2Rv9.1_BC.spc"                         # current model
bcmodelstartime = 2191.5                                    # starting time 01/01/2024


# === LOGGING SETUP ===
log_filename = "run_srt_heads.log"
logging.basicConfig(
    filename=log_filename,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

logging.info("Script started.")
logging.info(f"Parent model workspace: {model_ws}")
logging.info(f"NAM file: {namefile}")
logging.info(f"First SPC path: {firstSPCpath}")
logging.info(f"Second SPC path: {secondSPCpath}")
logging.info(f"BC model start time: {bcmodelstartime}")


# === MODEL LOADING ===

ml = flopy.modflow.Modflow.load(namefile, model_ws=model_ws, verbose=False, load_only=['DIS'])
ml.modelgrid.set_coord_info(xoff=modelxll, yoff=modelyll, angrot=gridangle)
hds_file = flopy.utils.binaryfile.HeadFile(os.path.join(model_ws, "P2Rv9.1.hds"), precision='double')

# === GRID SETUP ===

First = RectGrid()
First.readSPC(firstSPCpath)

Second = RectGrid()
Second.readSPC(secondSPCpath)

# === INTERPOLATION AND OUTPUT ===

rec = hds_file.get_data(totim=bcmodelstartime)  # BC Model Start Time

for k in range((ml.modelgrid.nlay)):
    vals = rec[k, :, :]
    indices = np.where(vals >= -200.0)
    nn = NearestNDInterpolator(list(zip(First.X[indices], First.Y[indices])), vals[indices])
    Z = nn(Second.X, Second.Y)
 #savePestArray(Z, "strt_layer_" + str(k + 1) + ".ref", Second.NROW, Second.NCOL)
    shdfile = f"P2RBC_shd_2024_ly{k+1}.ref"
    print(f"write {shdfile}")
    np.savetxt(shdfile, Z, fmt="%15.6E", delimiter='')


# convert from wrapped to free
#files = [f for f in os.listdir(wefl_path) if 'strt' in f and f.endswith('.ref')]
#nrow, ncol = 244, 232
#for f in files:
#    arr = pd.read_fwf(os.path.join(wefl_path, f), header=None).values
#    arr = arr[~np.isnan(arr)]
#    arr = arr.reshape((nrow, ncol))

