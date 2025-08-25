

names=('sl_a' 'sl_b' 'sl_c' 'sl_d' 'sl_e')    
nums=('127' '246' '351' '62' '320')    
for i in "${!names[@]}" 
do
cn=${names[$i]}
rl=${nums[$i]}

# Executable
mkdir ./sims/$cn
mkdir ./sims/$cn/flow
mkdir ./sims/$cn/flow/rch
mkdir ./sims/$cn/flow/mod2tec
ln -sf /data/projects/cpcco/bin/mf2k-mst-cpcc09dpl.x ./sims/$cn/flow/.
nl=8

# base simulation files that don't change realization to realization
# GEO
ln -sf ../../../comm/flow/geo_/model_top.ref ./sims/$cn/flow/model_top.ref
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/geo_/botm_layer_$c.ref ./sims/$cn/flow/botm_layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/geo_/ibound_layer_$c.ref ./sims/$cn/flow/ibound_layer_$c.ref
done

ln -sf ../../../comm/flow/geo_/delc.ref ./sims/$cn/flow/delc.ref
ln -sf ../../../comm/flow/geo_/delr.ref ./sims/$cn/flow/delr.ref
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/base/strt_layer_$c.ref ./sims/$cn/flow/strt_layer_$c.ref
done
# MODFLOW Input Files

ln -sf ../../../comm/flow/base/P2Rv9.1.bas ./sims/$cn/flow/.
ln -sf ../../../comm/flow/bcnd/P2Rv9.1.chd ./sims/$cn/flow/.
ln -sf ../../../comm/flow/bcnd/P2Rv9.1.riv ./sims/$cn/flow/.
ln -sf ../../../comm/flow/geo_/P2Rv9.1.dis ./sims/$cn/flow/.
ln -sf ../../../comm/flow/base/P2Rv9.1.lmt ./sims/$cn/flow/.
ln -sf ../../../comm/flow/prop/P2Rv9.1.lpf ./sims/$cn/flow/.
ln -sf ../../../comm/flow/prop/P2Rv9.1.hfb ./sims/$cn/flow/.
ln -sf ../../../comm/flow/bcnd/P2Rv9.1.mnw2 ./sims/$cn/flow/.
ln -sf ../../../comm/flow/bcnd/P2Rv9.1.mnwi ./sims/$cn/flow/.
ln -sf ../../../comm/flow/base/P2Rv9.1.mst ./sims/$cn/flow/.
ln -sf ../../../comm/flow/base/P2Rv9.1.nam ./sims/$cn/flow/P2R.nam
ln -sf ../../../comm/flow/base/P2Rv9.1_ato.oc ./sims/$cn/flow/.
ln -sf ../../../comm/flow/base/P2Rv9.1.ort ./sims/$cn/flow/.
ln -sf ../../../comm/flow/bcnd/P2Rv9.1.rch ./sims/$cn/flow/.
ln -sf ../../../run_hist.sh ./sims/$cn/flow/.
# Property Files for each realization
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2RSW/ss_Layer_$c.ref ./sims/$cn/flow/ss_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2RSW/sy_Layer_$c.ref ./sims/$cn/flow/sy_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2RSW/hk_Layer_$c.ref ./sims/$cn/flow/hk_Layer_$c.ref
done
# Recharge Files
for f in `basename -a ./comm/ensb/real_$rl\_iter_2/P2RSW/rech*.ref`
do 
ln -sf ../../../../comm/ensb/real_$rl\_iter_2/P2RSW/$f ./sims/$cn/flow/rch/$f
#echo "ln -sf ./$f ./nsbs/$cn/hss/."
done
for f in `basename -a ./comm/ensb/real_$rl\_iter_2/P2RSW/rch*.ref`
do 
ln -sf ../../../../comm/ensb/real_$rl\_iter_2/P2RSW/$f ./sims/$cn/flow/rch/$f
#echo "ln -sf ./$f ./nsbs/$cn/hss/."
done

# MOD2TEC FILES

ln -sf ../../../../../../settings.fig ./sims/$cn/flow/mod2tec/.
ln -sf /data/projects/cpcco/app/tor-055/util/many2tim_d.x ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/flow/geo_/P2Rv9.1_SW.spc ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/many2tim_d.in ./sims/$cn/flow/mod2tec/.
ln -sf ../P2Rv9.1.hds ./sims/$cn/flow/mod2tec/P2R.hds


mkdir ./sims/$cn/pred
mkdir ./sims/$cn/pred/rch
mkdir ./sims/$cn/pred/mod2tec
ln -sf /data/projects/cpcco/bin/mf2k-mst-cpcc09dpl.x ./sims/$cn/pred/.
nl=8

# base simulation files that don't change realization to realization
# GEO
ln -sf ../../../comm/flow/geo_/model_top.ref ./sims/$cn/pred/model_top.ref
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/geo_/botm_layer_$c.ref ./sims/$cn/pred/botm_layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/geo_/ibound_layer_$c.ref ./sims/$cn/pred/ibound_layer_$c.ref
done

ln -sf ../../../comm/flow/geo_/delc.ref ./sims/$cn/pred/delc.ref
ln -sf ../../../comm/flow/geo_/delr.ref ./sims/$cn/pred/delr.ref
for ((c=1;c<=$nl;c++)) do
  ln -sf ../flow/mod2tec/st18_layer_$c.ref ./sims/$cn/pred/strt_layer_$c.ref
done
# MODFLOW Input Files

ln -sf ../../../comm/flow/base/P2Rv9.1.bas ./sims/$cn/pred/.
ln -sf ../../../comm/pred/bcnd/P2Rv9.1.chd ./sims/$cn/pred/.
ln -sf ../../../comm/pred/bcnd/P2Rv9.1.riv ./sims/$cn/pred/.
ln -sf ../../../comm/pred/base/P2Rv9.1.dis ./sims/$cn/pred/.
ln -sf ../../../comm/flow/base/P2Rv9.1.lmt ./sims/$cn/pred/.
ln -sf ../../../comm/flow/prop/P2Rv9.1.lpf ./sims/$cn/pred/.
ln -sf ../../../comm/flow/prop/P2Rv9.1.hfb ./sims/$cn/pred/.
ln -sf ../../../comm/pred/bcnd/P2Rv9.1_20250130.mnw2 ./sims/$cn/pred/P2Rv9.1.mnw2
ln -sf ../../../comm/flow/bcnd/P2Rv9.1.mnwi ./sims/$cn/pred/.
ln -sf ../../../comm/flow/base/P2Rv9.1.mst ./sims/$cn/pred/.
ln -sf ../../../comm/flow/base/P2Rv9.1.nam ./sims/$cn/pred/P2R.nam
ln -sf ../../../comm/flow/base/P2Rv9.1_ato.oc ./sims/$cn/pred/.
ln -sf ../../../comm/flow/base/P2Rv9.1.ort ./sims/$cn/pred/.
ln -sf ../../../comm/pred/bcnd/P2Rv9.1.rch ./sims/$cn/pred/.
ln -sf ../../../run_hist.sh ./sims/$cn/pred/.

#Stuff to change

# Property Files for each realization
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2RSW/ss_Layer_$c.ref ./sims/$cn/pred/ss_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2RSW/sy_Layer_$c.ref ./sims/$cn/pred/sy_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2RSW/hk_Layer_$c.ref ./sims/$cn/pred/hk_Layer_$c.ref
done
# Recharge Files
for f in `basename -a ./comm/ensb/real_$rl\_iter_2/P2RSW/rch*.ref`
do 
ln -sf ../../../../comm/ensb/real_$rl\_iter_2/P2RSW/$f ./sims/$cn/pred/rch/$f
#echo "ln -sf ./$f ./nsbs/$cn/hss/."
done

done

