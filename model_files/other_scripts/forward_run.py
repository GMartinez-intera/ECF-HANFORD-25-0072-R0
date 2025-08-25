import os
import multiprocessing as mp
import numpy as np
import pandas as pd
import pyemu
import shutil
import flopy
import re
import platform
import math

# function added thru PstFrom.add_py_function()
def get_sim_equiv_hds():
    """translated from Trevor's perl script to get equivalent head along screen


    """
    print('calculating simulated heads')

    #load screen info
    wells = pd.read_csv('P2R_screen_info_new.csv')
    # wells = pd.read_csv('P2R_screen_info.csv')
    wells['WELL_ID'] = wells['WELL_ID'].str.lower()

    #load model
    m = flopy.modflow.Modflow.load(f = 'P2Rv9.1.nam', forgive=True, check=False)

    #load mod2obs output
    hds = pd.read_fwf('P2R_trnd_hds.out', names = ['name', 'date','time','val'])
    hds['layer'] = hds['name'].str.split('_').str[-1]
    hds['name'] = hds['name'].str.split('_').str[0].str.lower()
    hds['val'] = pd.to_numeric(hds['val'] , errors='coerce').fillna(0, downcast='infer')

    #assign some arrays
    tops = m.dis.top.array
    bots = m.dis.botm.array
    ks = m.lpf.hk.array

    #get output times (in days since 1-1-1943)
    dates = pd.to_datetime(hds['date'])
    dates = dates.unique()
    dates = sorted(dates)
    times = [pd.Timedelta(date - pd.to_datetime('1943-01-01')).days for date in dates]

    hobs = pd.DataFrame(columns=wells.iloc[:,1].str.lower().tolist(), index=times)
    m=0
    #loop through wells and calculate simulated equivalent head (transmissivity weighted)
    for i in range(len(wells)):
        row = wells.iloc[i, 6]
        col = wells.iloc[i, 7]
        sub = hds.loc[hds.name==wells.iloc[i,1],:]
        dates = sub['date'].unique()
        for dt in dates:
            time = pd.Timedelta(pd.to_datetime(dt) - pd.to_datetime('1943-01-01')).days
            dsub = sub.loc[sub.date==dt,:]
            totT = 0.
            tempavg = 0.
            for lay in range(7):
                if lay == 0:
                    top = tops[row,col]
                else:
                    top = bots[lay-1,row,col]
                subsub = dsub.loc[dsub.layer == str(lay + 1), :]
                k = ks[lay,row,col]
                head = subsub.val.values
                if wells.iloc[i, 4] > bots[lay, row, col] and wells.iloc[i, 4] < top:  # screen top in cell
                   thick = wells.iloc[i, 4] - bots[lay, row, col]
                elif wells.iloc[i, 5] > bots[lay, row, col] and wells.iloc[i, 5] < top:  # bot screen in cell
                    thick = top - wells.iloc[i, 5]
                elif bots[lay, row, col] > wells.iloc[i, 4] or top < wells.iloc[i, 5]:  # above or below screen
                    thick = 0.
                else: # all below
                    thick = top - bots[lay, row, col]

                temptran = thick * k
                tempavg += temptran * head
                totT += temptran

            if totT > 0.:
                tempavg = tempavg / totT
            else:
                tempavg = 0.

            hobs.loc[time, wells.iloc[i,1]] = tempavg
            m+=1

    hobs=hobs.replace('\[','',regex=True).astype(float)
    hobs.index.name = 'Time'
    hobs = hobs.fillna(-1)
    hobs.to_csv('sim_equiv_heads.csv')
    print('done calculating simulated heads')



# function added thru PstFrom.add_py_function()
def calc_grad():
    """calculate 3 pt azimuth and magnitude for obs wells

    Args:

        none

    """
    print('calculating simulated gradients')
    def get_slope_int(x1, y1, x2, y2):
        m = (y2-y1)/(x2-x1)
        b = y1 - m * x1
        return m,b

    def grad_calc(n1X = 0, n1Y= 0, n1H = 0, n2X = 0, n2Y = 0, n2H = 0, n3X = 0, n3Y = 0, n3H = 0):
        dy1y2 = n1Y[0] - n2Y[0]
        dy3y2 = n3Y[0] - n2Y[0]
        dx1x2 = n1X[0] - n2X[0]
        dx3x2 = n3X[0] - n2X[0]
        dz1z2 = n1H[0] - n2H[0]
        dz3z2 = n3H[0] - n2H[0]
        U1 = ((dy1y2 * dz3z2) - (dy3y2 * dz1z2))
        U2 = -((dx1x2 * dz3z2) - (dx3x2 * dz1z2))
        U3 = ((dx1x2 * dy3y2) - (dx3x2 * dy1y2))
        if U3 < 0:
            easting = U2
        else:
            easting = -U2
        if U3 > 0:
            northing = U1
        else:
            northing = -U1
        if easting >= 0:
            strike = math.acos(northing / (((easting ** 2)+(northing ** 2)) ** 0.5))
        else:
            strike = (2 * math.pi)-math.acos(northing / (((easting ** 2)+(northing ** 2)) ** 0.5))
        strike = math.degrees(strike)
        simAzm = strike + 90.0
        if simAzm > 360.0:
            simAzm = simAzm - 360.0
        dip = math.asin((((U1 ** 2)+(U2 ** 2)) ** 0.5) / (((U1 ** 2)+(U2 ** 2)+(U3 ** 2)) ** 0.5))
        simMag = math.atan(dip)
        return simMag, simAzm

    #first get all simulated outputs corresponding to well triplets in triangles.txt
    wells = pd.read_csv('P2R_screen_info_new.csv')
    # wells = pd.read_csv('P2R_screen_info.csv')
    wells['WELL_ID'] = wells['WELL_ID'].str.lower()
    tri = pd.read_csv('triangles.txt')

    #process grad heads output
    #load model
    m = flopy.modflow.Modflow.load(f='P2Rv9.1.nam', forgive=True, check=False)

    #load mod2obs output
    hds = pd.read_fwf('P2R_trnd_grad.out', names = ['name', 'date','time','val'])
    hds['layer'] = hds['name'].str.split('_').str[-1]
    hds['name'] = hds['name'].str.split('_').str[0].str.lower()
    hds['val'] = pd.to_numeric(hds['val'] , errors='coerce').fillna(0, downcast='infer')

    #assign some arrays
    tops = m.dis.top.array
    bots = m.dis.botm.array
    ks = m.lpf.hk.array

    #get output times (in days since 1-1-1943)
    dates = pd.to_datetime(hds['date'])
    dates = dates.unique()
    dates = sorted(dates)
    times = [pd.Timedelta(date - pd.to_datetime('1943-01-01')).days for date in dates]

    hobs = pd.DataFrame(columns=wells.iloc[:,1].str.lower().tolist(), index=times)

    m=0
    print("loop through wells and calculate simulated equivalent head (transmissivity weighted)")
    #loop through wells and calculate simulated equivalent head (transmissivity weighted)
    for i in range(len(wells)):
        row = wells.iloc[i, 6]
        col = wells.iloc[i, 7]
        sub = hds.loc[hds.name==wells.iloc[i,1],:]
        dates = sub['date'].unique()
        for dt in dates:
            time = pd.Timedelta(pd.to_datetime(dt) - pd.to_datetime('1943-01-01')).days
            dsub = sub.loc[sub.date==dt,:]
            totT = 0.
            tempavg = 0.
            for lay in range(7):
                if lay == 0:
                    top = tops[row,col]
                else:
                    top = bots[lay-1,row,col]
                subsub = dsub.loc[dsub.layer == str(lay + 1), :]
                k = ks[lay,row,col]
                head = subsub.val.values
                if wells.iloc[i, 4] > bots[lay, row, col] and wells.iloc[i, 4] < top:  # screen top in cell
                   thick = wells.iloc[i, 4] - bots[lay, row, col]
                elif wells.iloc[i, 5] > bots[lay, row, col] and wells.iloc[i, 5] < top:  # bot screen in cell
                    thick = top - wells.iloc[i, 5]
                elif bots[lay, row, col] > wells.iloc[i, 4] or top < wells.iloc[i, 5]:  # above or below screen
                    thick = 0.
                else: # all below
                    thick = top - bots[lay, row, col]

                temptran = thick * k
                tempavg += temptran * head
                totT += temptran

            if totT > 0.:
                tempavg = tempavg / totT
            else:
                tempavg = 0.

            hobs.loc[time, wells.iloc[i,1]] = tempavg
            m+=1

    hobs=hobs.replace('\[','',regex=True).astype(float)
    hobs.index.name = "Time"
    hobs = hobs.reset_index()

    print("building gradient df")
    grad = pd.DataFrame(columns=['Grad_Index','Avg_Time','Magnitude','Azimuth','Avg_X','Avg_Y'])
    m=0
    for i in range(len(tri)):
        index = tri.iloc[i,0]
        wel1, wel2, wel3 = tri.iloc[i,1],tri.iloc[i,2],tri.iloc[i,3]
        id1, id2, id3 = wells.loc[wells.WELL_NAME==wel1,'WELL_ID'].str.lower(),wells.loc[wells.WELL_NAME==wel2,'WELL_ID'].str.lower(),wells.loc[wells.WELL_NAME==wel3,'WELL_ID'].str.lower()
        x1,x2,x3 = wells.loc[wells.WELL_NAME==wel1,'X'].values,wells.loc[wells.WELL_NAME==wel2,'X'].values,wells.loc[wells.WELL_NAME==wel3,'X'].values
        y1,y2,y3 = wells.loc[wells.WELL_NAME==wel1,'Y'].values,wells.loc[wells.WELL_NAME==wel2,'Y'].values,wells.loc[wells.WELL_NAME==wel3,'Y'].values
        avg_x = (x1[0]+x2[0]+x3[0])/3
        avg_y = (y1[0]+y2[0]+y3[0])/3
        for dt in range(len(hobs)):
            tm = hobs.loc[dt,'Time']
            hd1 = hobs.loc[dt,id1]
            hd2 = hobs.loc[dt,id2]
            hd3 = hobs.loc[dt,id3]
            mag, azm = grad_calc(n1X = x1, n1Y= y1, n1H = hd1, n2X = x2, n2Y = y2, n2H = hd2, n3X = x3, n3Y = y3, n3H = hd3)
            grad.loc[m,'Grad_Index'] = index
            grad.loc[m,'Avg_Time'] = tm
            grad.loc[m,'Magnitude'] = mag
            grad.loc[m,'Azimuth'] = azm
            grad.loc[m,'Avg_X'] = avg_x
            grad.loc[m,'Avg_Y'] = avg_y
            m+=1

    # then interpolate simulated outputs to the observation times
    print("now interpolating to observation times")
    act_grad = pd.read_csv('P2R_act_grad.out',names=['Grad_Index','Avg_Time','Magnitude','Azimuth','Avg_X','Avg_Y'])
    sim_interp = act_grad.copy()
    for i in range(len(tri)):
        index = tri.iloc[i,0]
        sub_sim = grad.loc[grad.Grad_Index == index,:].reset_index()
        sub_act = act_grad.loc[act_grad.Grad_Index == index,:].reset_index()
        for j in range(len(sub_act)):
            try:
                targ_tm = sub_act.loc[j,'Avg_Time']
            except:
                continue
            df_sort = sub_sim.iloc[(sub_sim['Avg_Time'] - targ_tm).abs().argsort()[:2]].reset_index()
            if df_sort.loc[0,'Avg_Time'] > targ_tm:
                m,b = get_slope_int(df_sort.loc[1,'Avg_Time'],df_sort.loc[1,'Azimuth'],df_sort.loc[0,'Avg_Time'],df_sort.loc[0,'Azimuth'])
                azm = m*targ_tm + b
                m,b = get_slope_int(df_sort.loc[1,'Avg_Time'],df_sort.loc[1,'Magnitude'],df_sort.loc[0,'Avg_Time'],df_sort.loc[0,'Magnitude'])
                mag = m*targ_tm + b
            else:
                m,b = get_slope_int(df_sort.loc[0,'Avg_Time'],df_sort.loc[0,'Azimuth'],df_sort.loc[1,'Avg_Time'],df_sort.loc[1,'Azimuth'])
                azm = m*targ_tm + b
                m,b = get_slope_int(df_sort.loc[0,'Avg_Time'],df_sort.loc[0,'Magnitude'],df_sort.loc[1,'Avg_Time'],df_sort.loc[1,'Magnitude'])
                mag = m*targ_tm + b
            sim_interp.loc[(sim_interp.Grad_Index == index) & (sim_interp.Avg_Time == targ_tm), 'Magnitude'] = mag
            sim_interp.loc[(sim_interp.Grad_Index == index) & (sim_interp.Avg_Time == targ_tm), 'Azimuth'] = azm

    print('done interpolating')
    sim_interp.to_csv('sim_grads.csv', index=False)
    print('done calculating simulated gradients')
    


# function added thru PstFrom.add_py_function()
def swap_precision(org_filename,org_precision,new_filename,new_precision,echo=False):
    """function to swap the precision of modflow .hds and mt3d(ms) .ucn files
    Args:
        org_filename (str): the original file
        new_filename (str): the new file to write
        org_precision (str): the precision of the original file. Must be
            "single" or "double"
        new_precision (str): the precision of the new file.  Must be
            "single" or "double"
    Note:
        This function relies on the org_filename extension to determine the file type
            (".hds" = head-save, ".ucn" = concentration)
        This function does not yet support modflow-6 gwt ucn files...easy to do tho
    Example:
        org_filename = "MT3D0001.UCN"
        new_filename = "single.ucn"
        swap_precision(org_filename,new_filename,"double","single")
    """

    assert os.path.exists(org_filename)
    assert org_filename != new_filename
    if os.path.exists(new_filename):
        os.remove(new_filename)
    org_precision = org_precision.strip().lower()
    new_precision = new_precision.strip().lower()
    if new_precision == org_precision:
        print("matching precision, just a copy...")
        shutil.copy2(org_filename,new_filename)
        return
    assert org_precision in ["single","double"],"unknown org_precision: '{0}'".format(org_precision)
    assert new_precision in ["single","double"],"unknown new_precision: '{0}'".format(new_precision)

    if org_filename.lower().endswith(".hds"):
        fxn = flopy.utils.HeadFile
    elif org_filename.lower().endswith(".ucn"):
        fxn = flopy.utils.UcnFile
    else:
        raise Exception("unrecognized org_filename '{0}' extension, must be '.hds' or '.ucn'".format(org_filename))
    if org_precision == "double":
        new_fmt = "<f4"
    else:
        new_fmt = "<f8"

    org_bfile = fxn(org_filename,precision=org_precision)
    org_header_dt = org_bfile.header_dtype
    new_header_items = [("totim",new_fmt) if d[0] == "totim" else d for d in org_header_dt.descr]
    new_header_items = [("pertim", new_fmt) if d[0] == "pertim" else d for d in new_header_items]
    header_dt = np.dtype(new_header_items)
    new_bfile = open(new_filename,'wb')
    for rec in org_bfile.recordarray:
        full_arr = org_bfile.get_data(totim=rec[3])
        if echo:
            print(rec,full_arr.dtype)
        full_arr = full_arr.astype(new_fmt)
        arr = full_arr[rec[-1]-1,:,:]
        header = np.array(tuple(rec), dtype=header_dt)
        header.tofile(new_bfile)
        arr.tofile(new_bfile)

    new_bfile.close()



# function added thru PstFrom.add_py_function()
def fix_list_input():

    arr_files = [f for f in os.listdir('.') if 'CHD' in f and f.endswith(".dat")]
    for arr_file in arr_files:
        lst = np.loadtxt(arr_file)
        new_file = []
        for line in lst:
            new_file.append('{0:10d}{1:10d}{2:10d}{3:>10}{4:>10}\n'.format(int(line[0]), int(line[1]),int(line[2]),np.round(line[3],3),np.round(line[3],3)))

        with open(arr_file,'w') as f:
            lines = ''.join(new_file)
            f.write(lines)

    arr_files = [f for f in os.listdir('.') if 'RIV' in f and f.endswith(".dat")]
    for arr_file in arr_files:
        lst = np.loadtxt(arr_file)
        new_file = []
        for line in lst:
            new_file.append('{0:10d}{1:10d}{2:10d}{3:>10}{4:>10}{5:>10}\n'.format(int(line[0]), int(line[1]),int(line[2]),np.round(line[3],3),np.round(line[4],3),np.round(line[5],3)))

        with open(arr_file,'w') as f:
            lines = ''.join(new_file)
            f.write(lines)

    arr_files = [f for f in os.listdir('.') if 'HFB' in f and f.endswith(".dat")]
    for arr_file in arr_files:
        lst = np.loadtxt(arr_file)
        new_file = []
        for line in lst:
            new_file.append('{0:10d}{1:10d}{2:10d}{3:10d}{4:10d}{5:>10}\n'.format(int(line[0]), int(line[1]),int(line[2]),int(line[3]),int(line[4]),np.round(line[5],3)))

        with open(arr_file,'w') as f:
            lines = ''.join(new_file)
            f.write(lines)



# function added thru PstFrom.add_py_function()
def build_hfb():
    with open('HFB.dat', 'r') as f:
        hfb = f.readlines()
        hfb[-1] = '{0}\n'.format(hfb[-1])

    with open('P2Rv9.1.hfb', 'r') as f:
        hfb_lines = f.readlines()

    hfb_lines[2:64] = hfb

    with open('P2Rv9.1.hfb', 'w') as f:
        hfb_lines = ''.join(hfb_lines)
        f.write(hfb_lines)



# function added thru PstFrom.add_py_function()
def build_chd_pkg():
    """fxn written by edward to set up CHD package

    Args:

    """
    os.system('python chdgenerate.py --c TestCaseData_grid.csv --o P2Rv9.1.chd')




# function added thru PstFrom.add_py_function()
def build_riv_pkg():
    """fxn written by edward to set up RIV package

    Args:

    """
    os.system('python rivergenerate.py --c river_cell_new.dat --s river_flow.csv --o P2Rv9.1.riv')




# function added thru PstFrom.add_py_function()
def map_khsu_2_klay():
    ml = flopy.modflow.Modflow.load(f='P2Rv9.1.nam', forgive=True, check=False, load_only=['DIS'])
    ncol = ml.modelgrid.ncol
    nrow = ml.modelgrid.nrow
    nlay = ml.modelgrid.nlay
    nhsu = 7

    for ilay in range(1, (nlay + 1)):
        lay_T = np.zeros((nrow, ncol))
        thk_f = os.path.join('k_est', 'geo_', 'thk{0}.ref'.format(ilay))
        lay_thk = np.loadtxt(thk_f)
        for ihsu in range(1, (nhsu + 1)):
            hsu_thk_f = os.path.join('k_est', 'hsu_thk', 'hsu_thk_lay{0}_hsu{1}.ref'.format(ilay, ihsu))
            hsu_thk = np.loadtxt(hsu_thk_f)
            hsu_k_f = os.path.join('hk_HSU_{0}.ref'.format(ihsu))
            hsu_k = np.loadtxt(hsu_k_f)
            hsu_tran = (hsu_thk * hsu_k)
            hsu_prct_f = os.path.join('k_est', 'tran_pct', 'tpct_lay{0}_hsu{1}.ref'.format(ilay, ihsu))
            hsu_prct = np.loadtxt(hsu_prct_f)

            lay_T = lay_T + (hsu_tran * hsu_prct)
        kh = np.divide(lay_T, lay_thk, out=np.zeros_like(lay_T), where=lay_thk != 0)
        out_k = os.path.join('hk_Layer_{0}.ref'.format(ilay))
        np.savetxt(out_k, kh, fmt="%15.6E")



# function added thru PstFrom.add_py_function()
def run_flow():
    exe_path = '/state/partition1/chprc/bin'
    if "window" in platform.platform().lower():
        pyemu.os_utils.run("mf2k-mst-cpcc09dpv P2Rv9.1.nam")
        swap_precision('P2Rv9.1.hds', 'double', 'P2Rv9.1_sngl.hds', 'single')
        pyemu.os_utils.run("mod2obs.exe < mod2obs_trnd_sngl.in")
        pyemu.os_utils.run("mod2obs.exe < mod2obs_trnd_sngl_grad.in")
    else:
        if os.path.isfile('mf2k-mst-cpcc09dpl.x'):
            os.remove('mf2k-mst-cpcc09dpl.x')
        #if os.path.isfile('mod2obs_d.x'):
        #    os.remove('mod2obs_d.x')
        os.symlink(os.path.join(exe_path,'mf2k-mst-cpcc09dpl.x'),os.path.join('.','mf2k-mst-cpcc09dpl.x'))
        #os.symlink(os.path.join(exe_path, 'mod2obs_d.x'), os.path.join('.', 'mod2obs_d.x'))
        os.system('chmod +x mf2k-mst-cpcc09dpl.x')
        os.system('chmod +x mod2obs_d.x')
        os.system("./mf2k-mst-cpcc09dpl.x P2Rv9.1.nam")
        os.system("./mod2obs_d.x < mod2obs_trnd.in")
        os.system("./mod2obs_d.x < mod2obs_trnd_grad.in")


def main():

    try:
       os.remove(r'tmp_pst_flow/P2Rv9.1.cbb')
    except Exception as e:
       print(r'error removing tmp file:tmp_pst_flow/P2Rv9.1.cbb')
    try:
       os.remove(r'tmp_pst_flow/P2Rv9.1.ddn')
    except Exception as e:
       print(r'error removing tmp file:tmp_pst_flow/P2Rv9.1.ddn')
    try:
       os.remove(r'tmp_pst_flow/P2Rv9.1.ftl')
    except Exception as e:
       print(r'error removing tmp file:tmp_pst_flow/P2Rv9.1.ftl')
    try:
       os.remove(r'tmp_pst_flow/P2Rv9.1.hds')
    except Exception as e:
       print(r'error removing tmp file:tmp_pst_flow/P2Rv9.1.hds')
    try:
       os.remove(r'tmp_pst_flow/P2Rv9.1.tso')
    except Exception as e:
       print(r'error removing tmp file:tmp_pst_flow/P2Rv9.1.tso')
    try:
       os.remove(r'tmp_pst_flow/P2Rv9.1_init.hds')
    except Exception as e:
       print(r'error removing tmp file:tmp_pst_flow/P2Rv9.1_init.hds')
    try:
       os.remove(r'sim_equiv_heads.csv')
    except Exception as e:
       print(r'error removing tmp file:sim_equiv_heads.csv')
    try:
       os.remove(r'sim_grads.csv')
    except Exception as e:
       print(r'error removing tmp file:sim_grads.csv')
    try:
       os.remove(r'arr_par_summary.csv')
    except Exception as e:
       print(r'error removing tmp file:arr_par_summary.csv')
    pyemu.helpers.apply_list_and_array_pars(arr_par_file='mult2model_info.csv',chunk_len=50)
    fix_list_input()
    build_hfb()
    build_chd_pkg()
    build_riv_pkg()
    map_khsu_2_klay()
    run_flow()
    get_sim_equiv_hds()
    calc_grad()
    pyemu.helpers.calc_array_par_summary_stats()

if __name__ == '__main__':
    mp.freeze_support()
    main()

