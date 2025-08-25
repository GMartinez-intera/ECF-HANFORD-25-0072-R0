       	#'0' '1' '10' '102' '103' '104' '106' '107' '108' '11' '110' '112' '113' '114' '117' '118' '12' '120' '122' '123' '124' '125' '126' '127' '128' '13' '133' '14' '140' '142' '143' '144' '146' '147' '149' '15' '150' '151' '152' '153' '154' '156' '157' '158' '159' '16' '160' '162' '163' '164' '165' '166' '168' '17' '171' '172' '173' '175' '176' '177' '178' '179' '18' '180' '182' '183' '184' '185' '186' '187' '189' '190' '192' '193' '195' '196' '197' '198' '199' '2' '20' '200' '201' '202' '203' '204' '205' '206' '207' '208' '209' '21' '210' '211' '214' '215' '218' '219' '22' '220' '221' '223' '225' '226' '227' '228' '229' '23' '231' '232' '233' '234' '235' '237' '239' '24' '240' '241' '242' '243' '244' '245' '246' '247' '248' '249' '25' '250' '251' '252' '254' '256' '257' '258' '259' '26' '260' '261' '262' '263' '264' '265' '266' '267' '268' '27' '270' '271' '273' '276' '277' '278' '279' '280' '281' '282' '283' '285' '286' '287' '288' '29' '290' '291' '292' '293' '294' '296' '297' '298' '299' '3' '30' '300' '301' '302' '303' '304' '307' '308' '309' '31' '310' '311' '312' '313' '314' '315' '316' '318' '319' '32' '320' '321' '322' '323' '324' '325' '326' '327' '328' '329' '330' '331' '332' '333' '334' '335' '336' '338' '34' '341' '342' '343' '344' '346' '347' '348' '349' '35' '350' '351' '352' '353' '354' '355' '356' '357' '358' '37' '38' '39' '4' '40' '41' '43' '44' '45' '46' '47' '48' '49' '5' '50' '51' '53' '54' '55' '56' '58' '59' '6' '60' '61' '62' '65' '66' '67' '68' '69' '70' '72' '73' '74' '75' '77' '8' '80' '82' '84' '92' '93' '96' '97' '98' 'base'
names=('sl_a' 'sl_b' 'sl_c' 'sl_d' 'sl_e' 's1_a' 's1_b' 's1_c' 's1_d' 's1_e' 's2_a' 's2_b' 's2_c' 's2_d' 's2_e' 's3_a' 's3_b' 's3_c' 's3_d' 's3_e'    
       'rl_a' 'rl_b' 'rl_c' 'rl_d' 'rl_e' 'r1_a' 'r1_b' 'r1_c' 'r1_d' 'r1_e' 'r2_a' 'r2_b' 'r2_c' 'r2_d' 'r2_e' 'r3_a' 'r3_b' 'r3_c' 'r3_d' 'r3_e')    
stwds=('sl_a' 'sl_b' 'sl_c' 'sl_d' 'sc01'
       'sl_a' 'sl_b' 'sl_c' 'sl_d' 'sc01'
       'sl_a' 'sl_b' 'sl_c' 'sl_d' 'sc01'
       'sl_a' 'sl_b' 'sl_c' 'sl_d' 'sc01'
       'sl_a' 'sl_b' 'sl_c' 'sl_d' 'sc01'
       'sl_a' 'sl_b' 'sl_c' 'sl_d' 'sc01'
       'sl_a' 'sl_b' 'sl_c' 'sl_d' 'sc01'
       'sl_a' 'sl_b' 'sl_c' 'sl_d' 'sc01')
nums=('127' '246' '351' '62' '320' '127' '246' '351' '62' '320' '127' '246' '351' '62' '320' '127' '246' '351' '62' '320'    
      '127' '246' '351' '62' '320' '127' '246' '351' '62' '320' '127' '246' '351' '62' '320' '127' '246' '351' '62' '320')    
well=('sc01' 'sc01' 'sc01' 'sc01' 'sc01' 'ctet1' 'ctet1' 'ctet1' 'ctet1' 'ctet1' 'ctet2' 'ctet2' 'ctet2' 'ctet2' 'ctet2' 'ctet3' 'ctet3' 'ctet3' 'ctet3' 'ctet3'    
      'rl01' 'rl01' 'rl01' 'rl01' 'rl01' 'rtet1' 'rtet1' 'rtet1' 'rtet1' 'rtet1' 'rtet2' 'rtet2' 'rtet2' 'rtet2' 'rtet2' 'rtet3' 'rtet3' 'rtet3' 'rtet3' 'rtet3')    
for i in "${!names[@]}" 
do
cn=${names[$i]}
rl=${nums[$i]}
wl=${well[$i]}
st=${stwds[$i]}

# Executable
mkdir ./sims/$cn
mkdir ./sims/$cn/flow
mkdir ./sims/$cn/flow/rch
mkdir ./sims/$cn/flow/mod2tec
mkdir ./sims/$cn/flow/chdp
mkdir ./sims/$cn/flow/chdp/csv
mkdir ./sims/$cn/tran
mkdir ./sims/$cn/tran/mod2tec
mkdir ./sims/$cn/figs
mkdir ./sims/$cn/figs/hydro
ln -sf /data/projects/cpcco/bin/mf2k-mst-cpcc09dpl.x ./sims/$cn/flow/.
ln -sf /data/projects/cpcco/bin/mt3d-mst-cpcc09dpl.x ./sims/$cn/tran/.
nl=7

# base simulation files that don't change realization to realization
# GEO
ln -sf ../../../comm/flow/geo_/htop.ref ./sims/$cn/flow/model_top.ref
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

ln -sf ../../../comm/flow/base/P2Wv9.1.bas ./sims/$cn/flow/.
ln -sf ./chdp/P2R.chd ./sims/$cn/flow/P2Wv9.1.chd
ln -sf ../../../comm/flow/geo_/P2Wv9.1.dis ./sims/$cn/flow/.
ln -sf ../../../comm/flow/base/P2Wv9.1.lmt ./sims/$cn/flow/.
ln -sf ../../../comm/flow/prop/P2Wv9.1.lpf ./sims/$cn/flow/.
ln -sf ../../../comm/flow/bcnd/P2Wv9.1.mnwi ./sims/$cn/flow/.
ln -sf ../../../comm/flow/base/P2Wv9.1.mst ./sims/$cn/flow/.
ln -sf ../../../comm/flow/base/P2Wv9.1.nam ./sims/$cn/flow/P2R.nam
ln -sf ../../../comm/flow/base/P2Wv9.1_ato.oc ./sims/$cn/flow/.
ln -sf ../../../comm/flow/base/P2Wv9.1.ort ./sims/$cn/flow/.
ln -sf ../../../comm/flow/bcnd/P2Wv9.1.rch ./sims/$cn/flow/.
ln -sf ../../../run_hist.sh ./sims/$cn/flow/.

#THINGS TO CHANGE
ln -sf ../../../comm/flow/bcnd/P2Wv9.1_$wl\.mnw2 ./sims/$cn/flow/P2Wv9.1.mnw2
# Property Files for each realization
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2R2W/ss_Layer_$c.ref ./sims/$cn/flow/ss_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2R2W/sy_Layer_$c.ref ./sims/$cn/flow/sy_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2R2W/hk_Layer_$c.ref ./sims/$cn/flow/hk_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2R2W/sconc1_layer_$c.ref ./sims/$cn/tran/sconc1_layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/ensb/real_$rl\_iter_2/P2R2W/prsity_layer_$c.ref ./sims/$cn/tran/prsity_layer_$c.ref
done
# Recharge Files
for f in `basename -a ./comm/ensb/real_$rl\_iter_2/P2R2W/rech*.ref`
do 
ln -sf ../../../../comm/ensb/real_$rl\_iter_2/P2R2W/$f ./sims/$cn/flow/rch/$f
done
for f in `basename -a ./comm/ensb/real_$rl\_iter_2/P2R2W/rch*.ref`
do 
ln -sf ../../../../comm/ensb/real_$rl\_iter_2/P2R2W/$f ./sims/$cn/flow/rch/$f
done

#####CHD STUFF

ln -sf ../../../../../../settings.fig ./sims/$cn/flow/chdp/.
ln -sf ../../../../comm/flow/bcnd/chdp/mod2obs_prd.in ./sims/$cn/flow/chdp/.
ln -sf ../../../../comm/flow/bcnd/chdp/mod2obs_hst.in ./sims/$cn/flow/chdp/.
ln -sf ../../../../comm/flow/bcnd/chdp/P2R2W_chd.crd ./sims/$cn/flow/chdp/P2R.crd
ln -sf ../../../../comm/flow/bcnd/chdp/P2R2W_chd.lst ./sims/$cn/flow/chdp/P2R.lst
ln -sf ../../../../comm/flow/bcnd/chdp/param.json ./sims/$cn/flow/chdp/.
ln -sf ../../../../comm/flow/bcnd/chdp/grid_2W_chd.txt ./sims/$cn/flow/chdp/.
ln -sf /data/projects/cpcco/app/tor-055/util/chdgenerate.py ./sims/$cn/flow/chdp/.
ln -sf /data/projects/cpcco/app/tor-055/util/split_chd.py ./sims/$cn/flow/chdp/.
ln -sf ../../../../comm/flow/bcnd/chdp/P2Rchd1.smp ./sims/$cn/flow/chdp/P2R1.smp
ln -sf ../../../../comm/flow/bcnd/chdp/P2Rchd2.smp ./sims/$cn/flow/chdp/P2R2.smp
ln -sf /data/projects/cpcco/app/tor-055/util/mod2obs_d.x ./sims/$cn/flow/chdp/.
ln -sf ../../../../../stwd/sims/$st/flow/mod2tec/P2Rv9.1_SW.spc ./sims/$cn/flow/chdp/P2R.spc
ln -sf ../../../../../stwd/sims/$st/flow/P2Rv9.1.hds ./sims/$cn/flow/chdp/P2R1.hds
ln -sf ../../../../../stwd/sims/$st/pred/P2Rv9.1.hds ./sims/$cn/flow/chdp/P2R2.hds

# MOD2TEC FILES

ln -sf ../../../../../../settings.fig ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../../../settings.fig ./sims/$cn/tran/mod2tec/.
ln -sf /data/projects/cpcco/src/pest/gwutils/many2tim_d.x ./sims/$cn/flow/mod2tec/.
ln -sf /data/projects/cpcco/src/pest/gwutils/mod2hyd_d.x ./sims/$cn/flow/mod2tec/.
ln -sf /data/projects/cpcco/src/pest/gwutils/mod2hyd_d.x ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2Rv9.1_SW.spc ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2Rv9.1_2W.spc ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2Rv9.1_SW.spc ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2Rv9.1_2W.spc ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/many2tim_d.in ./sims/$cn/flow/mod2tec/.
ln -sf ../P2Wv9.1.hds ./sims/$cn/flow/mod2tec/P2R.hds
ln -sf ../P2RGWM.ucn ./sims/$cn/tran/mod2tec/P2R.ucn
ln -sf ../../comm/mod2tec/post.sh ./sims/$cn/.
ln -sf ../../../../comm/mod2tec/mod2hyd_hds_zp1.in ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/mod2hyd_hds_mon.in ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/mod2hyd_cnc_zp1.in ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/mod2hyd_cnc_mon.in ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/2W.crd ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/2W.crd ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/2W_InjExt.crd ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/2W_InjExt.crd ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/Extraction_WELL_Screen_Info.txt ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/Monitoring_WELL_Screen_Info.txt ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/Extraction_WELL_Screen_Info.txt ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/Monitoring_WELL_Screen_Info.txt ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/getSimEquiv_2W_ext.pl ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/getSimEquiv_2W_mon.pl ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/getSimEquiv_2Wc_ext.pl ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/getSimEquiv_2Wc_mon.pl ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2R_hds.tpl ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2R_InjExt_hds.tpl ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2R_cnc.tpl ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2R_InjExt_cnc.tpl ./sims/$cn/tran/mod2tec/.

##### MAKE FIGURE FILES  ##########
ln -sf ../../../comm/figs/bdjurdsv.cpg ./sims/$cn/figs/.
ln -sf ../../../comm/figs/bdjurdsv.prj ./sims/$cn/figs/.
ln -sf ../../../comm/figs/bdjurdsv.shp ./sims/$cn/figs/.
ln -sf ../../../comm/figs/bdjurdsv.sbn ./sims/$cn/figs/.
ln -sf ../../../comm/figs/bdjurdsv.sbx ./sims/$cn/figs/.
ln -sf ../../../comm/figs/bdjurdsv.shx ./sims/$cn/figs/.
ln -sf ../../../comm/figs/bdjurdsv.dbf ./sims/$cn/figs/.
ln -sf ../../../comm/figs/BuildExtPlots.R ./sims/$cn/figs/.
ln -sf ../../../comm/figs/BuildObsPlots.R ./sims/$cn/figs/.
ln -sf ../../../comm/figs/Extraction_WELL_Screen_Info.txt ./sims/$cn/figs/.
ln -sf ../../../comm/figs/Monitoring_WELL_Screen_Info.txt ./sims/$cn/figs/.
ln -sf ../../../comm/figs/v8.3.2_massextract_2015_onward.txt ./sims/$cn/figs/.
ln -sf ../../../comm/figs/ctet_well_by_well_observed.csv ./sims/$cn/figs/well_by_well_observed.csv
ln -sf ../../../comm/figs/200w_head.smp ./sims/$cn/figs/head.smp
ln -sf ../../../comm/figs/200w_ctet_ext.smp ./sims/$cn/figs/cnex.smp
ln -sf ../../../comm/figs/200w_ctet_mon.smp ./sims/$cn/figs/cnmn.smp

ln -sf ../flow/P2Wv9.1.ftl ./sims/$cn/tran/.
ln -sf ../flow/P2Wv9.1.tso ./sims/$cn/tran/.

# MT3D Input Files

ln -sf ../../../comm/tran/mt3d/P2RGWM.adv ./sims/$cn/tran/.
ln -sf ../../../comm/tran/mt3d/P2RGWM.btn ./sims/$cn/tran/.
ln -sf ../../../comm/tran/mt3d/P2RGWM.dsp ./sims/$cn/tran/.
ln -sf ../../../comm/tran/mt3d/P2RGWM.gcg ./sims/$cn/tran/.
ln -sf ../../../comm/tran/mt3d/P2RGWM.nam ./sims/$cn/tran/.
ln -sf ../../../comm/tran/hssm/P2RGWM.hss ./sims/$cn/tran/.
ln -sf ../../../comm/tran/hssm/P2RGWM.ssm ./sims/$cn/tran/.
# Property Files for each realization
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/tran/prop/al_2w_layer_$c.ref ./sims/$cn/tran/al_2w_layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/tran/prop/rhob_layer_$c.ref ./sims/$cn/tran/rhob_layer_$c.ref
done
ln -sf ../../../comm/tran/prop/trpt.ref ./sims/$cn/tran/.
ln -sf ../../../comm/tran/prop/trpv.ref ./sims/$cn/tran/.

ln -sf ../../../comm/flow/geo_/htop.ref ./sims/$cn/tran/.
ln -sf ../../../comm/flow/geo_/delc.ref ./sims/$cn/tran/delc.ref
ln -sf ../../../comm/flow/geo_/delr.ref ./sims/$cn/tran/delr.ref
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/tran/geo_/dz_layer_$c.ref ./sims/$cn/tran/dz_layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/tran/geo_/icbund_layer_$c.ref ./sims/$cn/tran/icbund_layer_$c.ref
done
ln -sf ../../../comm/tran/rect/P2RGWM.rct ./sims/$cn/tran/.
ln -sf ../../../comm/tran/rect/dmcoef1.ref ./sims/$cn/tran/.
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/tran/rect/sp11_layer_$c.ref ./sims/$cn/tran/sp11_layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/tran/rect/sp21_layer_$c.ref ./sims/$cn/tran/sp21_layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/tran/rect/rc11_layer_$c.ref ./sims/$cn/tran/rc11_layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/tran/rect/rc21_layer_$c.ref ./sims/$cn/tran/rc21_layer_$c.ref
done


done

