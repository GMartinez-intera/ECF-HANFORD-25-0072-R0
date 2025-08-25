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

def readPestArray(fileName,nrow,ncol):
    import numpy
    
    parray = numpy.zeros((nrow,ncol))
    
    tmparray = []
    acount=0
    with open(fileName, 'r') as f:
        data = f.readlines()
        for line in data:
            words = line.split()
            for word in words:
                tmparray.append(float(word))
                acount+=1
    acount = 0
    for bbb in range(int(nrow)):
        for ccc in range(int(ncol)):
            parray[bbb, ccc] = float(tmparray[acount])
            acount += 1    
    return parray 
    
    
    

import numpy
from spc2spc import *
from subprocess import Popen
import subprocess
import shutil
import os

swfl_path = os.path.join('.','P2RSW')
hsfl_path = os.path.join('..','hist','P2RSW')
eafl_path = os.path.join('.','P2RW2')
ncol = 188
nrow = 133
nlay = 8
nhsu = 7

'''
#  Run the Parent Model
os.chdir(swfl_path)
command = 'mf2k-mst-cpcc09dpv.exe P2Rv9.1_5th.nam'
p = Popen(command)
os.chdir('..')
p.wait()
# Generate Starting Heads
import flopy as fp
import scipy as sp
import numpy as np
modelxul = 557800.00
modelyul = 116200.00
gridangle = 0.0
modelepsg = 32149
namefile = 'P2Rv9.1.nam'
model_ws = hsfl_path

ml = fp.modflow.Modflow.load(namefile, model_ws=model_ws, load_only=['dis','bas6'], verbose=False)
ml.modelgrid.set_coord_info(xoff=modelxul, yoff=modelyul, angrot=gridangle)
hds_file = fp.utils.binaryfile.HeadFile(os.path.join(model_ws,"P2Rv9.1.hds"), precision='double')
rec = hds_file.get_data(totim=26663.00) # 200-West Model Start Time

from scipy.interpolate import NearestNDInterpolator
from scipy.interpolate import LinearNDInterpolator
import matplotlib.pyplot as plt
First = RectGrid()
First.readSPC("P2Rv9.1_SW.spc")
Second = RectGrid()
Second.readSPC("P2Rv9.1_W2.spc")
Second.createCELL_LIST(First,6)
for k in range((ml.modelgrid.nlay)):
    vals = rec[k,:,:]
    indices = np.where(vals >= -200.0)
    nn = NearestNDInterpolator(list(zip(First.X[indices],First.Y[indices])), vals[indices])
    Z = nn(First.X, First.Y)
    Z3 = nn(Second.X, Second.Y)
    indices = np.where(Z >= -200.0)
    idw = LinearNDInterpolator(list(zip(First.X[indices],First.Y[indices])), Z[indices])
    Z2 = idw(Second.X, Second.Y)
    #savePestArray(Z2,os.path.join(eafl_path,"shd_l"+ str(k+1) + ".ref"),Second.NROW,Second.NCOL)
    savePestArray(Z3,os.path.join(eafl_path,"strt_layer_"+ str(k+1) + "_20m.ref"),Second.NROW,Second.NCOL)


'''
# Process Boundary Heads for submodels
command = 'mod2obs_d.exe '
os.chdir(os.path.join(eafl_path,'chdp'))
finput = open('mod2obs_hst.in','r')
p = Popen(command,stdin=finput)
finput.close()
os.chdir('../..')
p.wait()

command = 'mod2obs_d.exe '
os.chdir(os.path.join(eafl_path,'chdp'))
finput = open('mod2obs_prd.in','r')
p = Popen(command,stdin=finput)
finput.close()
os.chdir('../..')
p.wait()

command = 'python split_chd.py P2RW2_chd1.out w'
os.chdir(os.path.join(eafl_path,'chdp'))
p = Popen(command)
os.chdir('../..')
p.wait()

command = 'python split_chd.py P2RW2_chd2.out a'
os.chdir(os.path.join(eafl_path,'chdp'))
p = Popen(command)
os.chdir('../..')
p.wait()

print("Create Submodel Boundaries")
command = 'python chdgenerate.py --c grid_W2_chd.txt --o ../P2R2W_20m.chd'
os.chdir(os.path.join(eafl_path,'chdp'))
p = Popen(command)
os.chdir('../..')
p.wait()

'''
# Process Recharge for submodels
# first parse recharge file

#then loop through those files and use spc2spc to save new refs
i=0
yr = 2018
for i in range(0, 101):
    Second.calcNewRealArray(First, os.path.join('P2RSW','rch', 'rch_91_{0}.ref'.format(i)),
                               os.path.join('P2RW2','rch','rech_{0}.ref'.format(yr)), 1, "DOUBLE")
    yr+=1

i=0
yr = 1943
for i in range(0, 79):
    Second.calcNewRealArray(First, os.path.join('..','hist','P2RSW', 'rech_{0}.ref'.format(i)),
                               os.path.join('P2RW2','rch','rech_{0}.ref'.format(yr)), 1, "DOUBLE")
    yr+=1

# Execute submodel
print("Execute Submodels")
command = 'mf2k-mst-cpcc09dpv.exe P2R2W_20m.nam'
os.chdir(eafl_path)
p = Popen(command)
os.chdir('..')
p.wait()

print("Flow Execution Complete")
'''
