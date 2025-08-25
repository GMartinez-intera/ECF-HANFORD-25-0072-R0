import os
import re
import platform
import codecs
import sys
import time
import subprocess
from datetime import datetime
from datetime import timedelta
import numpy as np
import pandas as pd
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib.patches import Polygon
from matplotlib.ticker import FormatStrFormatter
import matplotlib.pyplot as plt
import flopy
import flopy.discretization as fgrid
from flopy.utils.zonbud import ZoneBudget
import flopy.plot as fplot
from flopy.utils.gridintersect import GridIntersect
import descartes
import shapely
from shapely.geometry import Polygon, Point, LineString, MultiLineString, MultiPoint, MultiPolygon
from shapely.strtree import STRtree
import shapefile
import pyemu
import shutil
import math
from collections import OrderedDict
import fiona
import geopandas as gp
import string
from matplotlib.gridspec import GridSpec

cwd = os.getcwd()
import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import sys
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib import colors
from matplotlib.colors import ListedColormap, LinearSegmentedColormap
from matplotlib import gridspec

def savePestArray(parray, fileName):
    import numpy
    from numpy import loadtxt
    acount = 0
    maxI=len(parray)
    maxJ=len(parray[0])
    f=open(fileName,"w")
    for bbb in range(maxI):
        for ccc in range(maxJ):
            if (parray[[bbb], ccc]>=0):
                f.write(("  %08.06e" %parray[[bbb], ccc]))
            if (parray[[bbb], ccc]<0):
                f.write((" %08.06e" %parray[[bbb], ccc]))
            if ((ccc+1)%7 == 0):
                f.write("\n")
            acount += 1    
        f.write("\n")
    f.close()

def savePestArrayInt(parray, fieldType, fieldName, fileName):
    acount = 0
    f=open(fileName,"w")
    maxI=len(parray)
    maxJ=len(parray[0])
    for bbb in range(maxI):
        for ccc in range(maxJ):
            if (parray[[bbb], ccc]>=0):
                f.write(("  %01i" %parray[[bbb], ccc]))
            if (parray[[bbb], ccc]<0):
                f.write((" %01i" %parray[[bbb], ccc]))
            if ((ccc+1)%25 == 0):
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

optm_dir = sys.argv[1]
well_out_filename = sys.argv[2]
plot_title = sys.argv[3]
conv_factor = sys.argv[4]
conv_factor = float(conv_factor)+0.0
start_year = sys.argv[5]
start_year = float(start_year)+0.0


modelxul = 563800.00
modelyul = 129000.00
gridangle = 0.0
modelepsg = 32149
namefile = 'P2Ev9.1_20m_5th-243_ExtWellFlowAdjust.nam'
workspace = os.path.join(optm_dir,"flow","Flow")
model_ws = workspace
#dis_output_dir = os.path.join(workspace,"step_1")

ml = flopy.modflow.Modflow.load(namefile, model_ws=model_ws,load_only=['DIS','LPF','BAS6'], verbose=False)
ml.modelgrid.set_coord_info(xoff=modelxul, yoff=modelyul, angrot=gridangle)
namefile = 'P2Ev9.1_flopy.nam'
workspace = os.path.join(optm_dir,"tran","Transport_Tc99_BP5")
mt = flopy.mt3d.mt.Mt3dms.load(namefile, model_ws=workspace, verbose=False)

##  CREATES MONTH FILES FOR USE WITH PLOTTING IN R
import pandas as pd
mnw2 = pd.read_table(os.path.join(str(optm_dir),"flow","Flow",well_out_filename),sep='\\s+')
up1_list = ['299-E33-268','299-E33-360','299-E33-361']
mnw2 = mnw2[mnw2['WELLID'].isin(up1_list)]
print(mnw2['WELLID'])
mnw2 = mnw2.drop(columns=['Seepage','elev.'])
ucn_file = flopy.utils.binaryfile.UcnFile(os.path.join(str(optm_dir),"tran","Transport_Tc99_BP5","P2Ev9.1_20m_5th-243_Tc99.ucn"), precision='double')
ucn_times = ucn_file.get_times()
ucn_times = np.array(ucn_times)
times=mnw2['Totim'].unique()
times = np.array(times)
times = times[np.isin(times,ucn_times)]

mnw2=mnw2[mnw2['Totim'].isin(times)]

mnw2['Concentration']=0.0
mnw2['index']=mnw2.index
mnw2['sim']=start_year
mnw2['prev_time'] = 0.0
mnw2['strt_time'] = 0.0
mnw2['full_time'] = mnw2['Totim'] + mnw2['strt_time']
mnw2['year']=((mnw2['full_time']/365.25)-0.05)+start_year
mnw2['cy_year']=mnw2['year'].apply(np.floor)
mnw2['fy_year']=(mnw2['year']+0.25).apply(np.floor)
prev_time = 0.0
for tt in times:
    ctt = ucn_file.get_data(totim=tt)
    cnc = np.array(ctt)
    cnc[cnc<0.001] = 0.0
    rows= mnw2.loc[mnw2['Totim'] == tt,['index','Lay','Row','Col','Concentration']]
    for p in rows['index']: 
        tindex=int(rows['index'][p])
        tRow=int(rows['Row'][p])-1
        tLay=int(rows['Lay'][p])-1
        tCol=int(rows['Col'][p])-1
        mnw2.at[tindex,'Concentration']=float(cnc[tLay,tRow,tCol])
        if (tt > times[0]):
            mnw2.at[tindex,'prev_time']=prev_time
    prev_time = tt
mnw2['delt']=mnw2['Totim']-mnw2['prev_time'] 
#print(mnw2)
allmnw2=mnw2
allmnw2.reset_index()
allmnw2 = allmnw2.replace(-999.0, np.NaN)
allmnw2['Mass_kg']=0.0
allmnw2['Mass_kg']= -1*allmnw2['Q-node']*allmnw2['Concentration']*allmnw2['delt']/conv_factor
allmnw2.loc[allmnw2['Q-node']>=-1.0,'Mass_kg']=0.0
mass_num2 = allmnw2.groupby(['WELLID','full_time'])['Mass_kg'].sum()
mass_num2 = mass_num2.reset_index()
mass_num2.to_csv(os.path.join(optm_dir,"mass_bymonth_bywell.txt"))
flow_tim2 = allmnw2.groupby(['WELLID','full_time'])['Q-node'].sum()
flow_tim2 = flow_tim2.reset_index()
flow_tim2.to_csv(os.path.join(optm_dir,"flow_bymonth_bywell.txt"))
head_tim2 = allmnw2.groupby(['WELLID','full_time'])['hcell'].mean()
head_tim2 = head_tim2.reset_index()
head_tim2.to_csv(os.path.join(optm_dir,"head_bymonth_bywell.txt"))
mass_num = allmnw2.groupby(['WELLID','year'])['Mass_kg'].sum()
mass_fy2 = allmnw2.groupby(['WELLID','fy_year'])['Mass_kg'].sum()
mass_fy2 = mass_fy2.reset_index()
flow_tim = allmnw2.groupby(['WELLID','Totim','fy_year'])['Q-node'].sum()
flow_num = flow_tim.groupby(['WELLID','fy_year']).mean()
flow_num = flow_num.reset_index()
head_cel = allmnw2.groupby(['WELLID','fy_year'])['hcell'].mean()
head_cel = head_cel.reset_index()
head_wel = allmnw2.groupby(['WELLID','fy_year'])['hwell'].mean()
head_wel = head_wel.reset_index()
mass_num2 = allmnw2.groupby(['WELLID','cy_year'])['Mass_kg'].sum()
mass_num2 = mass_num2.reset_index()
mass_num2.to_csv(os.path.join(optm_dir,"mass_byyear_bywell.txt"))
mass_all = allmnw2.groupby(['year'])['Mass_kg'].sum()
mass_yrs = allmnw2.groupby(['cy_year'])['Mass_kg'].sum()
mass_fyr = allmnw2.groupby(['fy_year'])['Mass_kg'].sum()
mass_lay = allmnw2.groupby(['Lay','cy_year'])['Mass_kg'].sum()
flow_lay = allmnw2.groupby(['Lay','cy_year'])['Q-node'].sum()

#EXPORTS TABLES FOR FLOW OVER TIME AND MASS OVER TIME BY YEAR

m=open(os.path.join(str(optm_dir), "mass_extract_bywell.txt"),"w")
f=open(os.path.join(str(optm_dir), "flow_bywell.txt"),"w")
wells = mass_fy2['WELLID'].unique()
times = mass_fy2['fy_year'].unique().tolist()
times.sort()

m.write(("WELLID "))
f.write(("WELLID "))
for tindex in range(len(times)):
    m.write((" {:9.3f}".format(times[tindex])))
    f.write((" {:9.3f}".format(times[tindex])))
m.write(("\n"))
f.write(("\n"))
for index in range(len(wells)):
    m.write(("{:<28}  ".format(wells[index])))
    f.write(("{:<28}  ".format(wells[index])))
    for tindex in range(len(times)):
        alist = mass_fy2.query('WELLID == "' + str(wells[index]) + '"')  
        qlist = flow_num.query('WELLID == "' + str(wells[index]) + '"')  
        alist = alist.query('fy_year == ' + str(times[tindex]))  
        qlist = qlist.query('fy_year == ' + str(times[tindex]))  
        #print(alist['Mass_kg'])
        if len(alist) != 0:
            m.write((" {:9.3f}".format(float(alist['Mass_kg']))))
            f.write((" {:9.3f}".format(float(qlist['Q-node'])/5.451)))
        else:
            m.write(("     0.000"))
            f.write(("     0.000"))
    m.write(("\n"))
    f.write(("\n"))
m.close()
f.close()

#####  MAKES THE 4 PLOT FIGURE with FLOW and MASS OVERTIME
from matplotlib import gridspec

import pandas as pd
mas_obs = pd.read_table(os.path.join(str(optm_dir),"tran","Transport_Tc99_BP5","well_by_well_observed.csv"),sep=',')
mas_obs['cy_year']=mas_obs['Month_End'].str[6:10].astype(float)
mas_obs['fy_year']=(mas_obs['cy_year'].astype(float)+0.25).apply(np.floor)
mas_obs['month']= mas_obs['Month_End'].str[:2].astype(float)

up1_list = ['299-E33-268','299-E33-360','299-E33-361']
mas_obs = mas_obs[mas_obs['WELL_NAME'].isin(up1_list)]
print(mas_obs['WELL_NAME'])

mas_obs_fyr = mas_obs.groupby(['fy_year'])['MASS_CI'].sum()
mas_obs_fyr = mas_obs_fyr.reset_index()

#yr_list = [2012.0,2023.0,2024.0]
#mas_obs_fyr = mas_obs_fyr[mas_obs_fyr['fy_year'].isin(yr_list)]

print(mas_obs_fyr)
fig = plt.figure(figsize=(10, 12))
spec = gridspec.GridSpec(ncols=2, nrows=3, figure=fig, height_ratios=[3,3,1])
mass_lay = allmnw2.groupby(['Lay','fy_year'])['Mass_kg'].sum()
flow_lay = allmnw2[allmnw2['Q-node']<0].groupby(['Lay','year'])['Q-node'].sum()
flow = allmnw2[allmnw2['Q-node']<0].groupby(['year'])['Q-node'].sum()
ilay = 2
flow_lay = -flow_lay/5.451
flow = -flow/5.451
ax = fig.add_subplot(spec[0])
print(mass_fyr)
for k in range(3,6):
    flow_lay[k].plot(fontsize=12,grid=True, label="Layer"+str(k))
ax.set_xlabel('Year',fontdict={'fontsize':10})
current_values = ax.get_xticks()
ax.set_xticklabels(['{:2.0f}'.format(x)[2:] for x in current_values])
ax.set_ylabel('Extraction Rate, gpm',fontdict={'fontsize':10})
ax.set_title('Model Layer Summary',pad=20, fontdict={'fontsize':10})
ax2 = fig.add_subplot(spec[1])
flow.plot(fontsize=12,grid=True,secondary_y=True,color='black')

current_values = ax2.get_xticks()
ax2.set_xticklabels(['{:2.0f}'.format(x)[2:] for x in current_values])
ax2.set_xlabel('Year',fontdict={'fontsize':10})
ax2.set_ylabel('Extraction Rate, gpm',fontdict={'fontsize':10})
ax2.set_title('Entire Model',pad=20, fontdict={'fontsize':10})
ax3 = fig.add_subplot(spec[2])
for k in range(3,6):
    mass_lay[k].plot(fontsize=12,grid=True, ax=ax3, label="Layer"+str(k))
current_values = ax3.get_xticks()
ax3.set_xticklabels(['{:2.0f}'.format(x)[2:] for x in current_values])
ax3.set_xlabel('Year',fontdict={'fontsize':10})
ax3.set_ylabel('Total Mass Extracted, Ci',fontdict={'fontsize':10})
ax2 = fig.add_subplot(spec[3])
ax4 = mass_fyr.plot(fontsize=12,grid=True,secondary_y=True,color='black')
ax2.set_xlabel('Year',fontdict={'fontsize':10})
current_values = ax2.get_xticks()
ax2.set_xticklabels(['{:2.0f}'.format(x)[2:] for x in current_values])
ax4.scatter(mas_obs_fyr['fy_year'], mas_obs_fyr['MASS_CI'],s=14,facecolor='none',edgecolor='black',lw=0.5,marker="o") 
ax2 = fig.add_subplot(spec[2,:])
plt.axis('off')
handles, labels = ax3.get_legend_handles_labels()
ax2.legend(handles,labels,fontsize=11,ncol=len(handles))
fig.suptitle(plot_title, fontsize = 16)
plt.savefig( os.path.join(optm_dir,"tmpMassFlow.png"),dpi=300)
