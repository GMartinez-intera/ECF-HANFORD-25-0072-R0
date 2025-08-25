
import sys
sys.path.append('../../../../../')
import os
import numpy as np
from spc2spc import *
from scipy.interpolate import NearestNDInterpolator
from scipy.interpolate import LinearNDInterpolator
import flopy

modelxul = 557800.00
modelyul = 142800.00
gridangle = 0.0
namefile = 'P2R.nam'
model_ws = '.'
ml = flopy.modflow.Modflow.load(namefile, model_ws=model_ws, verbose=False, load_only=['DIS'])
ml.modelgrid.set_coord_info(xoff=modelxul, yoff=modelyul, angrot=gridangle)
hds_file = flopy.utils.binaryfile.HeadFile(os.path.join(model_ws, "P2Rv9.1.hds"), precision='double')
    
First = RectGrid()
First.readSPC("../../../comm/flow/geo_/P2Rv9.1_SW.spc")
print("read first spc")
Second = RectGrid()
Second.readSPC("../../../../bc/base/flow/spc/P2Rv9.1_BC.spc")
print("read second spc")
rec = hds_file.get_data(totim=2191.5)  # BC Model Start Time, pred starst in 2018. Assumes 365.25 per years 2018, 2019, 2020, 2021, 2022, 2023; 365.25*6 =2191.5
print(rec)
for k in range((ml.modelgrid.nlay)):
    vals = rec[k, :, :]
    indices = np.where(vals >= -200.0)
    nn = NearestNDInterpolator(list(zip(First.X[indices], First.Y[indices])), vals[indices])
    Z = nn(Second.X, Second.Y)
#    savePestArray(Z, "strt_layer_" + str(k + 1) + ".ref", Second.NROW, Second.NCOL)
    np.savetxt(os.path.join('str_hds_bc_2024',"strt_layer_" + str(k+1) + ".ref"), Z, fmt="%15.6E", delimiter='')

# convert from wrapped to free
#files = [f for f in os.listdir(wefl_path) if 'strt' in f and f.endswith('.ref')]
#nrow, ncol = 244, 232
#for f in files:
#    arr = pd.read_fwf(os.path.join(wefl_path, f), header=None).values
#    arr = arr[~np.isnan(arr)]
#    arr = arr.reshape((nrow, ncol))

