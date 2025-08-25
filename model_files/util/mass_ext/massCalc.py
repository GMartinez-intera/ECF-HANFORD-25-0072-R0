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

import matplotlib as mpl
import sys
import numpy as np

from matplotlib import cm
from matplotlib import colors
from matplotlib.colors import ListedColormap, LinearSegmentedColormap
from matplotlib import gridspec
import argparse
import json
import pandas as pd
import matplotlib.ticker as ticker


#function for calculating mass in aquifer
def calcMassPerLayerTime(hdsFile,ucnFile,ml,mt,bounds):
    import numpy as np
    porosity = mt.btn.prsity.array
    tmpFrac = 1.0 # This is a fraction that is used in dual porosity simulations, 1.0 for single porosity 
    dh = np.zeros((ml.modelgrid.nrow,ml.modelgrid.ncol)) # dh is an array of zeroes of size rows by column
   
    darea = []# array of cell areas
    for i in range(len(ml.dis.delc)):# for 0 through number of columns
        darea.append(np.multiply(ml.dis.delr.array,ml.dis.delc[i])) #get cell areas
    utimes = ucnFile.get_times() # get times

    
    htimes = hdsFile.get_times()
    times = []
    for tt in utimes:
        if tt in htimes:
            times.append(tt)

    mob_dis_mass = np.zeros((len(times),ml.dis.nlay))#array of size (number of times, number of layers)
    mob_sorb_mass = np.zeros((len(times),ml.dis.nlay))#array of size (number of times, number of layers) 
    mob_dis_mass_cont = np.zeros((len(times),len(bounds),ml.dis.nlay))# array of size (number if times, number of bounds chunks, number of layers)
    mob_sorb_mass_cont = np.zeros((len(times),len(bounds),ml.dis.nlay))#array of size (number of times, number of bounds chunks, number of layers)
  

    for itime in range(len(times)):#for each time
        
        tmpConc = ucnFile.get_data(totim=float(times[itime]))#tmpConc = ucn data for current time in loop
        tmpHead = hdsFile.get_data(totim=float(times[itime]))#tmpHead = head data for current time in loop
        for ilay in range(ml.dis.nlay):#for each layer
            layConc = np.maximum(0.0,tmpConc[ilay]) #layConc = maxes all negatives to 0 for current layer in tmpConc
            dh = np.subtract(tmpHead[ilay], ml.dis.botm[ilay].array)#dh = an array of the head drop values(head and bottom)
            if ilay == 0:
                dz = np.subtract(ml.dis.top.array, ml.dis.botm[ilay].array)#if 0 layer, dz = array of height of layer 1
            else:
                dz = np.subtract(ml.dis.botm[ilay-1].array, ml.dis.botm[ilay].array)#if not 0 layer, dz = array of height of current layer
            dh = np.minimum(dh,dz)# dh = whats smaller, head drop, or height of layer
            dh = np.maximum(0.0,dh)#0 out all negatives
            cVol = np.multiply(dh,darea)# mulitply dh(cell height with water) by cell area to get volume(cVol)
            
            cVol = np.multiply(cVol,porosity[ilay])# multiply the volume by porosity to get total water
            cCon = np.multiply(layConc,cVol)# multiply the volume by the concentration to get total contaminant
            mob_dis_mass[itime,ilay] = np.sum(cCon)#add together the contaminant of all the cells in that layer and time and put into mob_dis_mass
            for ilevel in range(len(bounds)):#for each bound chunk
                mob_dis_mass_cont[itime,ilevel,ilay] = np.sum(cCon[np.where(layConc<bounds[ilevel])])# this is grouped by concnetration and displayes the added mass
            reta_l1 = np.divide(mt.rct.rhob[ilay].array,porosity[ilay])##
            reta_l1 = np.multiply(mt.rct.sp1[0][ilay].array,reta_l1)## this is finding the retardation
            reta_l1 = np.multiply(cCon,reta_l1) #multiply the total concentration by the retardation
            mob_sorb_mass[itime,ilay] = np.sum(reta_l1) #add together all the retardation mass
            for ilevel in range(len(bounds)):
                mob_sorb_mass_cont[itime,ilevel,ilay] = np.sum(reta_l1[np.where(layConc<bounds[ilevel])])
                a = np.sum(mob_sorb_mass, axis=1)
    b = np.sum(mob_dis_mass, axis=1)
    ad = a + b
    ad = ad/10000000000

    return mob_dis_mass_cont,mob_sorb_mass_cont,mob_dis_mass,mob_sorb_mass,times



#function called to generate plots
def makeBar(lkind, layers, data_x, data_y, ylab, title, fname):
    pdata_x = np.array(data_x)
    pdata_y = np.array(data_y)
    pdata_l = np.array(layers)
    fig1 = plt.figure(figsize=(10, 9))
    ax1 = fig1.add_subplot(111)
    lay_list = np.unique(pdata_l)
    if lkind == True:
        for k in lay_list:
            indices = np.where(pdata_l == k)
            plt.bar(pdata_x[indices],pdata_y[indices],label="Layer " + str(k))
    else:
        #data.plot(fontsize=12, grid=True, color='black')
        #plot_data.plot(x=plot_data.columns[0],y=plot_data.columns[1],fontsize=12, grid=True, color='black')
        plt.bar(np.floor(pdata_x[1:]),pdata_y[1:],width=0.25,label=np.floor(pdata_x[1:]) ,color='black')
        #plt.bar_label(np.floor(pdata_x[1:]))
    ax1.set_xlabel('Year', fontdict={'fontsize':15})
    current_values = ax1.get_xticks()
    #ax1.set_xticks(current_values)
    #ax1.set_xticklabels(['{:2.1f}'.format(x)[2:] for x in current_values])
    plt.xticks(fontsize=14)
    plt.yticks(fontsize=14)
    ax1.set_xticklabels([str(int(x)) for x in current_values])
    ax1.set_ylabel(ylab, fontdict={'fontsize':15})
    ax1.grid('on')

    formatter = ticker.ScalarFormatter(useMathText=True)
    formatter.set_scientific(False)
    ax1.yaxis.set_major_formatter(formatter)

    ax1.set_title(title, pad=20, fontdict={'fontsize':15})
    if lkind == True:
        handles, labels = ax1.get_legend_handles_labels()
        plt.legend(fontsize=11, ncol=len(handles), bbox_to_anchor=(0.5, -0.08), loc='upper center')

    plt.savefig(fname,dpi=300)
    plt.close()



#function called to generate plots
def makePlot(lkind, layers, data_x, data_y, ylab, title, fname):
    pdata_x = np.array(data_x)
    pdata_y = np.array(data_y)
    pdata_l = np.array(layers)
    fig1 = plt.figure(figsize=(10, 9))
    ax1 = fig1.add_subplot(111)
    lay_list = np.unique(pdata_l)
    if lkind == True:
        for k in lay_list:
            indices = np.where(pdata_l == k)
            plt.plot(pdata_x[indices],pdata_y[indices],label="Layer " + str(k))
    else:
        #data.plot(fontsize=12, grid=True, color='black')
        #plot_data.plot(x=plot_data.columns[0],y=plot_data.columns[1],fontsize=12, grid=True, color='black')
        plt.plot(pdata_x,pdata_y,color='black')
    ax1.set_xlabel('Year', fontdict={'fontsize':15})
    current_values = ax1.get_xticks()
    #ax1.set_xticks(current_values)
    #ax1.set_xticklabels(['{:2.1f}'.format(x)[2:] for x in current_values])
    plt.xticks(fontsize=14)
    plt.yticks(fontsize=14)
    ax1.set_xticklabels([str(int(x)) for x in current_values])
    ax1.set_ylabel(ylab, fontdict={'fontsize':15})
    ax1.grid('on')

    formatter = ticker.ScalarFormatter(useMathText=True)
    formatter.set_scientific(False)
    ax1.yaxis.set_major_formatter(formatter)

    ax1.set_title(title, pad=20, fontdict={'fontsize':15})
    if lkind == True:
        handles, labels = ax1.get_legend_handles_labels()
        plt.legend(fontsize=11, ncol=len(handles), bbox_to_anchor=(0.5, -0.08), loc='upper center')

    plt.savefig(fname,dpi=300)
    plt.close()







def main():

#param data
    with open('param.json', "r") as paramFile:
        params = json.load(paramFile)
    mod_ws = str(params["MODFLOW_DIR"])
    plot_ws = str(params["PLOT_DIR"])
    modnamefile = str(params["MODFLOW_NAME"])
    mt3d_ws = str(params["MT3D_DIR"])
    mt3dnamefile = str(params["MT3D_NAME"])
    outfile = str(params["OUT_FILE_NAME"])
    ucn_ws = str(params["UCN_DIR"])
    ucnfilename = str(params["UCN_FILE_NAME"])
    hdsfilename = str(params["HDS_FILE_NAME"])

    flowPlots = params["flowPlots"]
    totalMassExtractedPlots = params["totalMassExtractedPlots"]
    perLayerPlots = params["perLayerPlots"]
    AllLayersPlots = params["AllLayersPlots"]
    cumulativeMassPlots = params["cumulativeMassPlots"]
    totalMassPlots = params["totalMassPlots"]
    eachWell = params["eachWell"]
    grouping = params["grouping"]
    conv_factor = params["conversion_factor"]
    start_date = str(params["start_date"])
    end_date = str(params["end_date"])
    mass_unit = str(params["mass_units"])

    wellGroup = params["wellGroup"]



    modelxul = 557800.00
    modelyul = 116200.00
    gridangle = 0.0
    modelepsg = 32149

    ml = flopy.modflow.Modflow.load(modnamefile, model_ws=mod_ws, verbose=False)
    ml.modelgrid.set_coord_info(xoff=modelxul, yoff=modelyul, angrot=gridangle)
    
    mt = flopy.mt3d.mt.Mt3dms.load(mt3dnamefile, model_ws=mt3d_ws, verbose=False)


        
    mnw2 = pd.read_table(mod_ws+"\\"+ outfile, sep='\\s+')
    mnw2 = mnw2.drop(columns=['Seepage','elev.'])
    utimes=mnw2['Totim'].unique()
    mnw2['Concentration']=0.0
    mnw2['index']=mnw2.index
    mnw2['sim']=1
    mnw2['prev_time'] = 0.0
    mnw2['strt_time'] = 0.0 
    mnw2['full_time'] = mnw2['Totim'] + mnw2['strt_time']
    mnw2['year']=((mnw2['full_time']/365.25)-0.01)+float(start_date[-4:])
    mnw2['cy_year']=mnw2['year'].apply(np.floor)
    mnw2['fy_year']=(mnw2['year']+0.25).apply(np.floor)
    prev_time = 0.0

    bounds = np.array([0, 3.4, 50.0, 100.0, 500.0, 1000.0, 2000.0, 3000.0])#####
    mob_mass=np.zeros((1,7))
    #sorb_mass=np.zeros((1,7))
    #sorb_mass=np.zeros((1,7))
    #mob_mass_cont=np.zeros((1,len(bounds),7))
    #sorb_mass_cont=np.zeros((1,len(bounds),7))
    times=np.zeros((1))#####
   



    #below is generating data
    ucn_file = flopy.utils.binaryfile.UcnFile(ucn_ws+"\\"+ucnfilename, precision='double')
    for tt in utimes:
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
            if (tt > utimes[0]):
                mnw2.at[tindex,'prev_time']=prev_time
        prev_time = tt
    mnw2['delt']=mnw2['Totim']-mnw2['prev_time'] 
    #if (yr!=22):
    #    allmnw2= pd.concat((allmnw2,mnw2),ignore_index = True)  
    #else:
    allmnw2=mnw2

    hds_file = flopy.utils.binaryfile.HeadFile(mod_ws+"\\" + hdsfilename, precision='double')#####
    tmp_mob_cont, tmp_sorb_cont, tmp_mob_mass, tmp_sorb_mass, tmp_times = calcMassPerLayerTime(hds_file,ucn_file,ml,mt,bounds)
    time_years = np.add(np.divide(tmp_times,365.25),float(start_date[-4:]))
    mob_mass = np.append(mob_mass,tmp_mob_mass)
    #sorb_mass = np.append(sorb_mass,tmp_sorb_mass)
    #mob_mass_cont = np.append(mob_mass_cont,tmp_mob_cont)
    #sorb_mass_cont = np.append(sorb_mass_cont,tmp_sorb_cont)
    times = np.append(times,time_years)


    mob_mass = mob_mass.reshape(len(times),7)
    #sorb_mass = sorb_mass.reshape(len(times),7)
    #mob_mass_cont = mob_mass_cont.reshape(len(times),len(bounds),7)
    #sorb_mass_cont = sorb_mass_cont.reshape(len(times),len(bounds),7)
    mob_mass = np.delete(mob_mass,obj=0,axis=0)
    #sorb_mass = np.delete(sorb_mass,obj=0,axis=0)
    #mob_mass_cont = np.delete(mob_mass_cont,obj=0,axis=0)
    #sorb_mass_cont = np.delete(sorb_mass_cont,obj=0,axis=0)
    times = np.delete(times,obj=0,axis=0)#####


    allmnw2.reset_index()
    allmnw2['Mass']=0.0
    allmnw2['Mass']= -1*allmnw2['Q-node']*allmnw2['Concentration']*allmnw2['delt']/conv_factor
    allmnw2.loc[allmnw2['Q-node']>=-1.0,'Mass']=0.0

    '''
    #mass_num = allmnw2.groupby(['WELLID','year'])['Mass'].sum()
    #mass_fy2 = allmnw2.groupby(['WELLID','fy_year'])['Mass'].sum()
    #mass_fy2 = mass_fy2.reset_index()
    #flow_tim = allmnw2.groupby(['WELLID','Totim','fy_year'])['Q-node'].sum()
    #flow_num = flow_tim.groupby(['WELLID','fy_year']).mean()
    #flow_num = flow_num.reset_index()
    #head_cel = allmnw2.groupby(['WELLID','fy_year'])['hcell'].mean()
    #head_cel = head_cel.reset_index()
    #head_wel = allmnw2.groupby(['WELLID','fy_year'])['hwell'].mean()
    #head_wel = head_wel.reset_index()
    #mass_num2 = allmnw2.groupby(['WELLID','cy_year'])['Mass'].sum()
    #mass_num2 = mass_num2.reset_index()
    #mass_all = allmnw2.groupby(['year'])['Mass'].sum()

    mass_yrs = allmnw2.groupby(['cy_year'])['Mass'].sum()
    mass_lay = allmnw2.groupby(['Lay','cy_year'])['Mass'].sum()
    flow_lay = allmnw2.groupby(['Lay','cy_year'])['Q-node'].sum()
    '''




    from matplotlib import gridspec
   

    #generate plots for each individual well

    if eachWell == True:
        wells_df = allmnw2.loc[allmnw2['Q-node'] <= 0, ['WELLID', 'Lay', 'year', 'Q-node', 'Mass']]
        
        for well_id in wells_df['WELLID'].unique():
            uwell_df= wells_df[wells_df['WELLID'] == well_id]
            uwell_df = uwell_df.drop('WELLID', axis=1)
            uwell_df = uwell_df.sort_values(['Lay', 'year'])
            layers = uwell_df['Lay'].unique().tolist()
            
            if flowPlots == True:
                fwell_df = uwell_df.drop('Mass', axis=1)
                fwell_df = fwell_df.set_index(['Lay', 'year'])['Q-node']
                fwell_df = -fwell_df/5.451
                fwell_df = fwell_df.reset_index()
                
                if perLayerPlots == True:
                    makePlot(True, fwell_df['Lay'], fwell_df['year'], fwell_df['Q-node'], 'Extraction Rate, gpm', str(well_id),plot_ws + "\\" + str(well_id) + "_flowPerLayer.png")


                if AllLayersPlots == True:
                    year_group = fwell_df.groupby('year').sum()
                    year_group = year_group.reset_index()
                    makePlot(False, layers, year_group['year'], year_group['Q-node'], 'Extraction Rate, gpm', str((str(well_id) + ' Entire Model Domain')), plot_ws + "\\" + str(well_id) + "_flowfulldomain.png")
          

            if totalMassExtractedPlots == True:
                mwell_df = uwell_df.drop('Q-node', axis=1)
                mwell_df = mwell_df.set_index(['Lay', 'year'])['Mass']
                year_group = mwell_df.groupby('year').sum()
                mwell_df = mwell_df.reset_index()
                year_group_cum = mwell_df.groupby(['year'])['Mass'].cumsum()
                year_group = year_group.reset_index()
                year_group_cum = year_group_cum.reset_index()
                if perLayerPlots == True:
                    makePlot(True, mwell_df['Lay'], mwell_df['year'], mwell_df['Mass'], 'Mass Extracted, ' + mass_unit, str(well_id), plot_ws + "\\" + str(well_id) + "_massPerLayer.png")
                if AllLayersPlots == True:
                    makePlot(False, layers, year_group['year'], year_group['Mass'], 'Mass Extracted, ' + mass_unit, str((str(well_id) + ' All Model Layers')), plot_ws + "\\" + str(well_id) + "_totalmass.png")
#                if cumulativeMassPlots == True:
#                    makePlot(False, layers, year_group_cum['year'], year_group_cum['Mass'], 'Cumulative Mass Extracted, ' + mass_unit, str((str(well_id) + ' All Model Layers')), plot_ws + "\\" + str(well_id) + "_cumulativetotalmass.png")
                





       #generate the flow and mass extracted plots for all groups

    if grouping == False:
        wellGroup = [{"groupname": "all", "wells": []}]


    for group in wellGroup:

        if grouping == True:
            allmnw2filtered = allmnw2[allmnw2['WELLID'].isin(group["wells"])]
        else:
            allmnw2filtered = allmnw2

        mass_lay = allmnw2filtered.groupby(['Lay','year'])['Mass'].sum()
        mass_yrs = allmnw2filtered.groupby(['year'])['Mass'].sum()
        # I am adding a zero to the start date of the simulation so the plot starts from zero
        mass_lay = mass_lay.reset_index()
        mass_lay['lay_sum'] = mass_lay.groupby('Lay')['Mass'].cumsum()
        mass_yrs = mass_yrs.reset_index()
        column_names = mass_yrs.columns
        add_data = []
        add_data.append(float(start_date[-4:]))
        add_data.append(0)
        start_date_zero = pd.DataFrame([add_data],columns=column_names)
        mass_yrs = pd.concat([start_date_zero,mass_yrs])
        mass_yrs = mass_yrs.reset_index()
        mass_lay = mass_lay.reset_index()
        column_names = mass_lay.columns
        add_data = []
        for i in range(1,8):
            add_data.append(0)
            add_data.append(i)
            add_data.append(float(start_date[-4:]))
            add_data.append(0)
            add_data.append(0)
        add_data = np.array(add_data).reshape(7,5)
        start_date_zero = pd.DataFrame(add_data,columns=column_names)
        mass_lay = pd.concat([start_date_zero,mass_lay])
        mass_lay = mass_lay.reset_index()

        flow_lay = allmnw2filtered[allmnw2filtered['Q-node']<=0].groupby(['Lay','year'])['Q-node'].sum()
        flow = allmnw2filtered[allmnw2filtered['Q-node']<=0].groupby(['year'])['Q-node'].sum()
        flow_lay = -flow_lay/5.451
        flow = -flow/5.451
        flow_lay = flow_lay.reset_index()
        flow = flow.reset_index()


        layers = flow_lay['Lay']
        if flowPlots == True:
            
            if perLayerPlots == True:

                makePlot(True, flow_lay['Lay'], flow_lay['year'],flow_lay['Q-node'], 'Extraction Rate, gpm', 'Model Layer Summary', plot_ws + "\\flowPerLayerIn" + str(group["groupname"]) + ".png")
        
            if AllLayersPlots == True:

                makePlot(False, layers, flow['year'],flow['Q-node'], 'Extraction Rate, gpm', 'Entire Model', plot_ws + "\\flowIn" + str(group["groupname"]) + ".png")
            
            

        if totalMassExtractedPlots == True:
            layers = mass_lay['Lay']
            if perLayerPlots == True:
                
                makePlot(True, layers, mass_lay['year'], mass_lay['Mass'], 'Mass Extracted, ' + mass_unit, 'Model Layer Summary', plot_ws + "\\intExtractedPerLayerIn" + str(group["groupname"]) + ".png")

                if cumulativeMassPlots == True:
                    makePlot(True, layers, mass_lay['year'], mass_lay['lay_sum'], 'Mass Extracted, ' + mass_unit, 'Model Layer Summary', plot_ws + "\\cumulativeExtractedPerLayerIn" + str(group["groupname"]) + ".png")

            if AllLayersPlots == True:

                makeBar(False, layers, mass_yrs['year'],mass_yrs['Mass'], 'Mass Extracted, ' + mass_unit, 'Entire Model', plot_ws + "\\intExtractedIn" + str(group["groupname"]) + ".png")

                if cumulativeMassPlots == True:
                    makePlot(False, layers, mass_yrs['year'], mass_yrs['Mass'].cumsum(), 'Cumulative Mass Extracted, ' + mass_unit, 'Entire Model', plot_ws + "\\cumulativeExtractedIn" + str(group["groupname"]) + ".png")





    #generate total mass extracted plots (for all wells combined)

    if totalMassExtractedPlots == True:
        total_mass_lay = allmnw2.groupby(['Lay','year'])['Mass'].sum()
        total_mass_yrs = allmnw2.groupby(['year'])['Mass'].sum()
        total_mass_lay = total_mass_lay.reset_index()
        total_mass_lay['lay_sum'] = total_mass_lay.groupby('Lay')['Mass'].cumsum()
        total_mass_yrs = total_mass_yrs.reset_index()
        column_names = total_mass_yrs.columns
        add_data = []
        add_data.append(float(start_date[-4:]))
        add_data.append(0)
        start_date_zero = pd.DataFrame([add_data],columns=column_names)
        total_mass_yrs = pd.concat([start_date_zero,total_mass_yrs])
        total_mass_yrs = total_mass_yrs.reset_index()
        total_mass_lay = total_mass_lay.reset_index()
        column_names = total_mass_lay.columns
        add_data = []
        for i in range(1,8):
            add_data.append(0)
            add_data.append(i)
            add_data.append(float(start_date[-4:]))
            add_data.append(0)
            add_data.append(0)
        add_data = np.array(add_data).reshape(7,5)
        start_date_zero = pd.DataFrame(add_data,columns=column_names)
        total_mass_lay = pd.concat([start_date_zero,total_mass_lay])
        total_mass_lay = total_mass_lay.reset_index()
    
        if perLayerPlots == True:
            layers = total_mass_lay['Lay']
            makePlot(True, layers, total_mass_lay['year'], total_mass_lay['Mass'], 'Mass Extracted, ' + mass_unit, 'Model Layer Summary', plot_ws + "\\intExtractedPerLayer.png")

            if cumulativeMassPlots == True:
                makePlot(True, layers, total_mass_lay['year'], total_mass_lay['lay_sum'], 'Mass Extracted, ' + mass_unit, 'Model Layer Summary', plot_ws + "\\cumulativeExtractedPerLayer.png")

        if AllLayersPlots == True:
            makeBar(False, layers, total_mass_yrs['year'], total_mass_yrs['Mass'], 'Mass Extracted, ' + mass_unit, 'Entire Model', plot_ws + "\\intExtractedInModel.png")

            if cumulativeMassPlots == True:
                makePlot(False, layers, total_mass_yrs['year'], total_mass_yrs['Mass'].cumsum(), 'Cumulative Mass Extracted, ' + mass_unit, 'Entire Model', plot_ws + "\\cumulativeExtractedInModel.png")







    #generate total mass in aquifer plots

    if totalMassPlots == True:
        if perLayerPlots == True:

            summdata = pd.DataFrame(columns=['Lay', 'year', 'mass'])
            for i in range(0,7):   
                df = pd.DataFrame({'Lay': ([i+1] * len(times)), 'year': times, 'mass': (np.divide(mob_mass[:,i],conv_factor))})
                # summdata = summdata.append(df, ignore_index=True)  # append was removed from pandas 2.0
                summdata = pd.concat([summdata, df], ignore_index=True)
            summdata = summdata.set_index(['Lay', 'year'])['mass']
            summdata = summdata.reset_index()

            makePlot(True, summdata['Lay'], summdata['year'], summdata['mass'], 'Total Mass, ' + mass_unit, 'Model Layer Summary', os.path.join(plot_ws,"massPerLayer.png"))


        if AllLayersPlots == True:
            
            massdata_series = pd.Series((np.divide(np.sum(mob_mass, axis=1),conv_factor)), index=times)
            massdata_series.name = 'mass'
            massdata_series.index.name = 'year'
            massdata_series = massdata_series.reset_index()
            makePlot(False, list(range(1,8)), massdata_series['year'], massdata_series['mass'], 'Total Mass, ' + mass_unit, 'Entire Model Domain', os.path.join(plot_ws,"massInModel.png"))
        

main()


