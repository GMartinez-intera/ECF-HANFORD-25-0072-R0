import flopy as fp

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
import sys

scrl = sys.argv[1]
site = sys.argv[2]
rlnm = sys.argv[3]
stwd = sys.argv[4]
time_start = sys.argv[5]
time_start = float(time_start) + 0.0

cwd = os.getcwd()
swfl_path = os.path.join(cwd, 'modl','stwd','sims',stwd,'pred')
hsfl_path = os.path.join(cwd, 'modl','stwd','sims',stwd,'flow')
effl_path = os.path.join(cwd, 'modl',site,'sims',scrl,'flow')
etfl_path = os.path.join(cwd, 'modl',site,'sims',scrl,'tran')
cts_path = os.path.join(cwd, 'modl',site,'sims',scrl, 'm3d2cts')

ncol = 188
nrow = 133
nlay = 8
nhsu = 7

run_sw_flow_pred = False
run_create_strt_h_2w = False
run_create_chd_2w = False
run_2w_flow = False
run_2w_cts = True
run_2w_tran = True

print(f'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
print(f'XXX run_sw_flow_pred: {run_sw_flow_pred}')
print(f'XXX run_create_strt_h_2w: {run_create_strt_h_2w}')
print(f'XXX run_create_chd_2w: {run_create_chd_2w}')
print(f'XXX run_2w_flow: {run_2w_flow}')
print(f'XXX run_2w_cts: {run_2w_cts}')
print(f'XXX run_2w_tran: {run_2w_tran}')
print(f'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')

if run_sw_flow_pred:
    #  Run the Parent Model
    os.chdir(hsfl_path)
    command = '/data/projects/cpcco/bin/mf2k-mst-cpcc09dpl.x'
    theargs=[command,'P2R.nam']
    p = Popen(theargs)
    p.wait()

    os.chdir('mod2tec')
    command = '/data/projects/cpcco/src/pest/gwutils/many2tim_d.x'
    finput = open('many2tim_d.in','r')
    theargs='P2R.nam'
    p = Popen(theargs,executable=command,stdin=finput)
    finput.close()
    p.wait()
    os.chdir(cwd)

    os.chdir(swfl_path)
    command = '/data/projects/cpcco/bin/mf2k-mst-cpcc09dpl.x'
    theargs=[command,'P2R.nam']
    p = Popen(theargs)
    os.chdir(cwd)
    p.wait()


# Generate Starting Heads
#import flopy as fp
import scipy as sp
import numpy as np
modelxul = 557800.00
modelyul = 116200.00
gridangle = 0.0
modelepsg = 32149
namefile = 'P2R.nam'
model_ws = hsfl_path

ml = fp.modflow.Modflow.load(namefile, model_ws=model_ws, load_only=['dis','bas6'], verbose=False)
ml.modelgrid.set_coord_info(xoff=modelxul, yoff=modelyul, angrot=gridangle)
hds_file = fp.utils.binaryfile.HeadFile(os.path.join(model_ws,"P2Rv9.1.hds"), precision='double')
rec = hds_file.get_data(totim=time_start) # 200-West Model Start Time


if run_create_strt_h_2w:
    print("XXX-create strt_layer 2W START XXX")
    from scipy.interpolate import NearestNDInterpolator
    from scipy.interpolate import LinearNDInterpolator
    import matplotlib.pyplot as plt
    First = RectGrid()
    First.readSPC(os.path.join('.','modl','stwd','P2R.spc'))
    Second = RectGrid()
    Second.readSPC(os.path.join('.','modl',site,'P2R.spc'))
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
        savePestArray(Z3,os.path.join(effl_path,"strt_layer_"+ str(k+1) + ".ref"),Second.NROW,Second.NCOL)
    print("XXX-create strt_layer 2W END XXX")


if run_create_chd_2w:
    print("XXX-Create CHD START-XXX")
    # Process Boundary Heads for submodels
    command_mod2obs = './mod2obs_d.x'
    os.chdir(os.path.join(effl_path,'chdp_dis'))
    print(os.path.join(effl_path,'chdp_dis'))
    finput = open('mod2obs_hst.in','r')

    p = Popen([command_mod2obs],stdin=finput)
    finput.close()
    p.wait()

    finput = open('mod2obs_prd_dis.in','r') # revised to match extended sp
    p = Popen([command_mod2obs], stdin=finput)
    finput.close()
    p.wait()

    theargs = ['python','split_chd.py', 'P2Rchd1.out','w']
    p = Popen(theargs)
    p.wait()

    theargs = ['python','split_chd.py', 'P2Rchd2.out','a']
    p = Popen(theargs)
    p.wait()
    
    print("XXX-Create Submodel Boundaries-XXX")
    theargs = ['python','chdgenerate.py','--c','grid_2W_chd.txt','--o','P2R.chd']
    p = Popen(theargs)
    p.wait()
    os.chdir(cwd)
    print("XXX-Create CHD END-XXX")

# Process Recharge for submodels
# first parse recharge file

#then loop through those files and use spc2spc to save new refs

#for i in range(0, 101):
#    Second.calcNewRealArray(First, os.path.join('.','modl','stwd','comm','ensb','real_'+rlnm+'_iter_2','P2RSW','rch_91_{0}.ref'.format(i)),
#                               os.path.join('.','modl',site,'comm','ensb','real_'+rlnm+'_iter_2','P2R2W','rch_91_{0}.ref'.format(i)), 1, "DOUBLE")

#i=0
#for i in range(0, 79):
#    Second.calcNewRealArray(First, os.path.join(swfl_path,'rch', 'rech_{0}.ref'.format(i)),
#                               os.path.join(effl_path,'comm','ensb','real_'+rl+'_iter_2','P2R2W','rech_{0}.ref'.format(i)), 1, "DOUBLE")

if run_2w_flow:
    print("XXX-Flow Execution START-XXX")
    os.chdir(effl_path)
    command = './mf2k-mst-cpcc09dpl.x'
    theargs = [command, 'P2Wv9.1.nam']
    p = Popen(theargs)
    os.chdir(cwd)
    p.wait()
    print("XXX-Flow Execution END-XXX")

if run_2w_cts:
    print("XXX-CTS-CREATION START-XXX")
    print("XXX-m3d2cts gives an error  but cts should be ok-XXX", file=sys.stderr, flush=True)
    os.chdir(cts_path)
    print(os.getcwd())
    command = './runCTS.sh'
    theargs = [command]
    p = Popen(theargs)
    os.chdir(cwd)
    p.wait()
    print("XXX-CTS-CREATION END-XXX")

if run_2w_tran:
    print("XXX-Tran Execution START-XXX")
    os.chdir(etfl_path)
    command = './mt3d-mst-cpcc09dpl.x'
    theargs = [command, 'P2RGWM.nam','mst','dry1','dry2']
    p = Popen(theargs)
    os.chdir(cwd)
    p.wait()
    print("XXX-Tran Execution END-XXX")
