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

def savePestArray(parray, fileName,nrow,ncol):
    import numpy
    from numpy import loadtxt
    acount = 0
    f=open(fileName,"w")
    for bbb in range(nrow):
        for ccc in range(ncol):
            if (parray[bbb, ccc]>=0):
                f.write(("  %08.06e" %parray[bbb, ccc]))
            if (parray[bbb, ccc]<0):
                f.write((" %08.06e" %parray[bbb, ccc]))
            if ((ccc+1)%7 == 0):
                f.write("\n")
            acount += 1    
        f.write("\n")
    f.close()



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
Second.createCELL_LIST(First,6) # Added following 200W approach

# === INTERPOLATION AND OUTPUT ===

rec = hds_file.get_data(totim=bcmodelstartime)  # BC Model Start Time

for k in range((ml.modelgrid.nlay)):
    vals = rec[k, :, :]
    indices = np.where(vals >= -200.0)
    nn = NearestNDInterpolator(list(zip(First.X[indices],First.Y[indices])), vals[indices])
    Z = nn(First.X, First.Y)
    Z3 = nn(Second.X, Second.Y)
    indices = np.where(Z >= -200.0)
    idw = LinearNDInterpolator(list(zip(First.X[indices],First.Y[indices])), Z[indices])
    Z2 = idw(Second.X, Second.Y)
    shdfile = f"P2RBC_shd_2024_ly{k+1}.ref"
    print(f"write {shdfile}")
    savePestArray(Z2,shdfile,Second.NROW,Second.NCOL)
    #savePestArray(Z3,shdfile,Second.NROW,Second.NCOL)


# convert from wrapped to free
#files = [f for f in os.listdir(wefl_path) if 'strt' in f and f.endswith('.ref')]
#nrow, ncol = 244, 232
#for f in files:
#    arr = pd.read_fwf(os.path.join(wefl_path, f), header=None).values
#    arr = arr[~np.isnan(arr)]
#    arr = arr.reshape((nrow, ncol))

