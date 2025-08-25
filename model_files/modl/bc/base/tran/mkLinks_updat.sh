
for cn in 'crkd' 'crvi' 'cyan' 'ctet' 'i129' 'no3_' 'sr90' 'tc99' 'tce_' 'trit' 'utot' 
do
# Executable
ln -sf /data/projects/cpcco/bin/mt3d-mst-cpcc09dpl.x ./nsbs/$cn/.
ln -sf /data/projects/cpcco/src/pest/gwutils/m2k2max_dp.x ./nsbs/$cn/mod2tec/.
ln -sf /data/projects/cpcco/src/pest/gwutils/zonm3d_dp.x ./nsbs/$cn/mod2tec/.
ln -sf /data/projects/cpcco/src/pest/gwutils/m3d2mas_dp.x ./nsbs/$cn/mod2tec/.
ln -sf /data/projects/cpcco/src/pest/gwutils/m2k2ddn.x ./nsbs/$cn/mod2tec/.
# Base
# MT3D Files
ln -sf ../../mt3d/P2RGWM.adv ./nsbs/$cn/P2RGWM.adv
ln -sf ../../mt3d/P2RGWM.btn ./nsbs/$cn/P2RGWM.btn
ln -sf ../../mt3d/P2RGWM.dsp ./nsbs/$cn/P2RGWM.dsp
ln -sf ../../mt3d/P2RGWM.gcg ./nsbs/$cn/P2RGWM.gcg
echo "cn = $cn"
ln -sf ../../mt3d/P2RGWM.nam ./nsbs/$cn/P2RGWM.nam
if [ "$cn" == "ctet" ] ; then
  ln -sf ../../mt3d/P2RGWM_noHSS.nam ./nsbs/$cn/P2RGWM.nam
fi
if [ "$cn" == "tce_" ] ; then
  ln -sf ../../mt3d/P2RGWM_noHSS.nam ./nsbs/$cn/P2RGWM.nam
fi
ln -sf ../../mt3d/runMt3d.sh ./nsbs/$cn/runMt3d.sh
# GEO Files
ln -sf ../../geo_/top_BC_1.ref ./nsbs/$cn/top1.ref
for ((c=1;c<=8;c++)) do
  ln -sf ../../geo_/thk$c.ref ./nsbs/$cn/thk$c.ref
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../geo_/ibnd_BC_$c.inf ./nsbs/$cn/ibnd$c.inf
done
# CTS Package
ln -sf ../../cts_/P2RBC_$cn\.cts ./nsbs/$cn/P2RGWM.cts

# REACTION
ln -sf ../../rect/P2R_$cn\.rct ./nsbs/$cn/P2RGWM.rct
# INITIAL CONC
for ((c=1;c<=8;c++)) do
  ln -sf "../../icnc/plume_2023_update/$cn/wt_conc_"$c".ref" ./nsbs/$cn/ic_l$c.ref
done

# FTL/TSO
ln -sf ../../../flow/P2RBC.ftl ./nsbs/$cn/P2RGWM.ftl
ln -sf ../../../flow/P2RBC.tso ./nsbs/$cn/P2RGWM.TSO

# PROP
for ((c=1;c<=8;c++)) do
  ln -sf ../../prop/rhob_Layer_$c.ref ./nsbs/$cn/bd$c.ref
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../prop/prsity_Layer_$c.ref ./nsbs/$cn/ep$c.ref
done
ln -sf ../../mt3d/P2RGWM.dsp ./nsbs/$cn/P2RGWM.dsp

# SSM
ln -sf ../../mt3d/P2RGWM.ssm ./nsbs/$cn/P2RGWM.ssm
ln -sf ../../hss_/CIENFAHSS_2023/$cn/mt3d_bc.hss ./nsbs/$cn/P2RGWM.hss
for f in `basename -a ./hss_/CIENFAHSS_2023/$cn/*_hss.dat`
do 
ln -sf ../../../hss_/CIENFAHSS_2023/$cn/$f ./nsbs/$cn/hss/$f
#echo "ln -sf ./$f ./nsbs/$cn/hss/."
done
done

