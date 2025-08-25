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
import geopandas as gp
import string
from matplotlib.gridspec import GridSpec
import socket

def run_ies(tmp_ws, m_d="master_ies", num_workers=10, noptmax=-1, drop_conflicts=True, num_reals=100,
                port=4263, hostname=None, subset_size=4, bad_phi_sigma=1000.0, overdue_giveup_fac=None,
                overdue_giveup_minutes=None, use_condor=False, freeze=False, gaia=False):
    """specify control file pars and run ies

    Args:

        lots

    """

    # ies stuff
    pst = pyemu.Pst(os.path.join(tmp_ws, "p2r.pst"))
    pst.pestpp_options["ies_drop_conflicts"] = drop_conflicts
    pst.pestpp_options["ies_subset_size"] = subset_size
    pst.pestpp_options["ies_bad_phi_sigma"] = bad_phi_sigma
    pst.pestpp_options["panther_agent_freeze_on_fail"]=False
    if overdue_giveup_fac is not None:
        pst.pestpp_options["overdue_giveup_fac"] = overdue_giveup_fac
    if overdue_giveup_minutes is not None:
        pst.pestpp_options["overdue_giveup_minutes"] = overdue_giveup_minutes
    pst.control_data.noptmax = noptmax
    pst.write(os.path.join(tmp_ws, "p2r.pst"), version=2)
    prep_worker(tmp_ws, tmp_ws + "_clean")

    master_p = None
    # run ies
    local = True
    #sock = socket.socket()
    #sock.bind(('', 0))
    #port = sock.getsockname()[1]
    #sock.close()
    #with open('port.txt','w') as f:
    #    f.write('{0}\n'.format(int(port)))

    wr = 'master_node'
    if os.path.exists(wr):
        shutil.rmtree(wr)
    os.mkdir(wr)

    m_d = os.path.join(wr,m_d)

    if gaia:
        pyemu.os_utils.start_workers(tmp_ws+'_clean', "pestpp-ies", "p2r.pst", num_workers=1,
                                 worker_root=wr,port=4004, local='192.168.100.245', master_dir=m_d)
    else:
        pyemu.os_utils.start_workers(tmp_ws+'_clean', "pestpp-ies", "p2r.pst", num_workers=48,
                                 worker_root=wr,port=port, local='10.99.50.12', master_dir=m_d)

def prep_worker(org_d, new_d):
    if os.path.exists(new_d):
        shutil.rmtree(new_d)
    shutil.copytree(org_d,new_d)
    exts = ["jcb","rei","hds","cbc","ucn","cbb","ftl","m3d","tso","ddn"]

    files = [f for f in os.listdir(new_d) if f.lower().split('.')[-1] in exts]
    for f in files:
        os.remove(os.path.join(new_d,f))
        # if f != 'prior.jcb': #need prior.jcb to run ies
        #     os.remove(os.path.join(new_d,f))
    mlt_dir = os.path.join(new_d,"mult")
    for f in os.listdir(mlt_dir)[1:]:
        os.remove(os.path.join(mlt_dir,f))
    tpst = os.path.join(new_d,"temp.pst")
    if os.path.exists(tpst):
        os.remove(tpst)


if __name__ == "__main__":
    run_ies('tmp_pst_flow', m_d='master_ies_flow', noptmax=2, use_condor=False,
                overdue_giveup_minutes=50, drop_conflicts=True, gaia=True)
    #run_ies('tmp_pst_trnsprt', m_d='master_ies_trnsprt', noptmax=2, use_condor=False,
    #            overdue_giveup_minutes=250, drop_conflicts=True, gaia=True)
