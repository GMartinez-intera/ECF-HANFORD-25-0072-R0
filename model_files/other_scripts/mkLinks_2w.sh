for cn in '0' '1' '10' '102' '103' '104' '106' '107' '108' '11' '110' '112' '113' '114' '117' '118' '12' '120' '122' '123' '124' '125' '126' '127' '128' '13' '133' '14' '140' '142' '143' '144' '146' '147' '149' '15' '150' '151' '152' '153' '154' '156' '157' '158' '159' '16' '160' '162' '163' '164' '165' '166' '168' '17' '171' '172' '173' '175' '176' '177' '178' '179' '18' '180' '182' '183' '184' '185' '186' '187' '189' '190' '192' '193' '195' '196' '197' '198' '199' '2' '20' '200' '201' '202' '203' '204' '205' '206' '207' '208' '209' '21' '210' '211' '214' '215' '218' '219' '22' '220' '221' '223' '225' '226' '227' '228' '229' '23' '231' '232' '233' '234' '235' '237' '239' '24' '240' '241' '242' '243' '244' '245' '246' '247' '248' '249' '25' '250' '251' '252' '254' '256' '257' '258' '259' '26' '260' '261' '262' '263' '264' '265' '266' '267' '268' '27' '270' '271' '273' '276' '277' '278' '279' '280' '281' '282' '283' '285' '286' '287' '288' '29' '290' '291' '292' '293' '294' '296' '297' '298' '299' '3' '30' '300' '301' '302' '303' '304' '307' '308' '309' '31' '310' '311' '312' '313' '314' '315' '316' '318' '319' '32' '320' '321' '322' '323' '324' '325' '326' '327' '328' '329' '330' '331' '332' '333' '334' '335' '336' '338' '34' '341' '342' '343' '344' '346' '347' '348' '349' '35' '350' '351' '352' '353' '354' '355' '356' '357' '358' '37' '38' '39' '4' '40' '41' '43' '44' '45' '46' '47' '48' '49' '5' '50' '51' '53' '54' '55' '56' '58' '59' '6' '60' '61' '62' '65' '66' '67' '68' '69' '70' '72' '73' '74' '75' '77' '8' '80' '82' '84' '92' '93' '96' '97' '98' 'base'
do
# Executable
mkdir ./sm2w/wf_$cn
mkdir ./sm2w/wf_$cn/chdp
mkdir ./sm2w/wf_$cn/chdp/csv
mkdir ./sm2w/wf_$cn/hds
mkdir ./sm2w/wf_$cn/rch
mkdir ./sm2w/wf_$cn/mod2tec
ln -sf /state/partition1/chprc/bin/mf2k-mst-cpcc09dpl.x ./sm2w/wf_$cn/.
ln -sf /state/partition1/chprc/src/pest/gwutils/mod2obs_d.x ./sm2w/wf_$cn/chdp/.
ln -sf /state/partition1/chprc/src/pest/gwutils/mod2hyd_d.x ./sm2w/wf_$cn/mod2tec/.

# base simulation files that don't change realization to realization
# GEO
ln -sf ../../P2R2W/model_top.ref ./sm2w/wf_$cn/model_top.ref
for ((c=1;c<=7;c++)) do
  ln -sf ../../P2R2W/botm_layer_$c.ref ./sm2w/wf_$cn/botm_layer_$c.ref
done
for ((c=1;c<=7;c++)) do
  ln -sf ../../P2R2W/ibound_layer_$c.ref ./sm2w/wf_$cn/ibound_layer_$c.ref
done
ln -sf ../../P2R2W/delc.ref ./sm2w/wf_$cn/delc.ref
ln -sf ../../P2R2W/delr.ref ./sm2w/wf_$cn/delr.ref
# MODFLOW Input Files

ln -sf ../../P2R2W/P2Wv9.1.bas ./sm2w/wf_$cn/P2Wv9.1.bas
ln -sf ../../P2R2W/P2Wv9.1.dis ./sm2w/wf_$cn/P2Wv9.1.dis
ln -sf ../../P2R2W/P2Wv9.1.lmt ./sm2w/wf_$cn/P2Wv9.1.lmt
ln -sf ../../P2R2W/P2Wv9.1.lpf ./sm2w/wf_$cn/P2Wv9.1.lpf
ln -sf ../../P2R2W/P2Wv9.1.mnw2 ./sm2w/wf_$cn/P2Wv9.1.mnw2
ln -sf ../../P2R2W/P2Wv9.1.mnwi ./sm2w/wf_$cn/P2Wv9.1.mnwi
ln -sf ../../P2R2W/P2Wv9.1.mst ./sm2w/wf_$cn/P2Wv9.1.mst
ln -sf ../../P2R2W/P2Wv9.1.nam ./sm2w/wf_$cn/P2Wv9.1.nam
ln -sf ../../P2R2W/P2Wv9.1_ato.oc ./sm2w/wf_$cn/P2Wv9.1_ato.oc
ln -sf ../../P2R2W/P2Wv9.1.ort ./sm2w/wf_$cn/P2Wv9.1.ort
ln -sf ../../P2R2W/P2Wv9.1.rch ./sm2w/wf_$cn/P2Wv9.1.rch
ln -sf ../../run_hs2W.sh ./sm2w/wf_$cn/.
# Property Files for each realization
for ((c=1;c<=7;c++)) do
  ln -sf ../../pst_arrays_iter2/real_$cn\_iter_2/P2R2W/ss_Layer_$c.ref ./sm2w/wf_$cn/ss_Layer_$c.ref
done
for ((c=1;c<=7;c++)) do
  ln -sf ../../pst_arrays_iter2/real_$cn\_iter_2/P2R2W/sy_Layer_$c.ref ./sm2w/wf_$cn/sy_Layer_$c.ref
done
for ((c=1;c<=7;c++)) do
  ln -sf ../../pst_arrays_iter2/real_$cn\_iter_2/P2R2W/hk_Layer_$c.ref ./sm2w/wf_$cn/hk_Layer_$c.ref
done
# Recharge Files
for f in `basename -a ./pst_arrays_iter2/real_$cn\_iter_2/P2R2W/rech*.ref`
do 
#echo "ln -sf ./$f ./nsbs/$cn/hss/."
  ln -sf ../../../pst_arrays_iter2/real_$cn\_iter_2/P2R2W/$f ./sm2w/wf_$cn/rch/.
done

# CHD FILES 
ln -sf ./chdp/P2Wv9.1.chd ./sm2w/wf_$cn/P2Wv9.1.chd
ln -sf ../../../chdp/chdgenerate.py ./sm2w/wf_$cn/chdp/chdgenerate.py
ln -sf ../../../chdp/grid_2W_chd.txt ./sm2w/wf_$cn/chdp/.
ln -sf ../../../chdp/mod2obs_act.in ./sm2w/wf_$cn/chdp/.
ln -sf ../../../smhs/wf_$cn/P2Rv9.1.hds ./sm2w/wf_$cn/chdp/.
ln -sf ../../../chdp/param_real.json ./sm2w/wf_$cn/chdp/param.json
ln -sf ../../../chdp/split_chd.py ./sm2w/wf_$cn/chdp/.
ln -sf ../../../chdp/P2R2W_chd.crd ./sm2w/wf_$cn/chdp/.
ln -sf ../../../chdp/P2R2W_chd.smp ./sm2w/wf_$cn/chdp/.
ln -sf ../../../chdp/P2R2W_chd.lst ./sm2w/wf_$cn/chdp/.
ln -sf ../../../chdp/settings.fig ./sm2w/wf_$cn/chdp/.
ln -sf ../../../hds/P2Rv9.1_SW.spc ./sm2w/wf_$cn/chdp/P2Rv9.1.spc

# starting heads FILES 
ln -sf ../../../hds/srt_heads.py ./sm2w/wf_$cn/hds/.
ln -sf ../../../hds/spc2spc.py ./sm2w/wf_$cn/hds/.
ln -sf ../../../hds/P2Rv9.1_2W.spc ./sm2w/wf_$cn/hds/.
ln -sf ../../../hds/P2Rv9.1_SW.spc ./sm2w/wf_$cn/hds/.
ln -sf ../../../flopy ./sm2w/wf_$cn/hds/.
ln -sf ../../../smhs/wf_$cn/P2Rv9.1.hds ./sm2w/wf_$cn/hds/.
ln -sf ../../../smhs/wf_$cn/P2Rv9.1.nam ./sm2w/wf_$cn/hds/.
ln -sf ../../../smhs/wf_$cn/P2Rv9.1.dis ./sm2w/wf_$cn/hds/.
ln -sf ../../../smhs/wf_$cn/P2Rv9.1.bas ./sm2w/wf_$cn/hds/.
ln -sf ../../../smhs/wf_$cn/delr.ref ./sm2w/wf_$cn/hds/.
ln -sf ../../../smhs/wf_$cn/delc.ref ./sm2w/wf_$cn/hds/.
ln -sf ../../../smhs/wf_$cn/model_top.ref ./sm2w/wf_$cn/hds/.
for ((c=1;c<=8;c++)) do
  ln -sf ../../../smhs/wf_$cn/botm_layer_$c.ref ./sm2w/wf_$cn/hds/.
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../../smhs/wf_$cn/strt_layer_$c.ref ./sm2w/wf_$cn/hds/.
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../../smhs/wf_$cn/ibound_layer_$c.ref ./sm2w/wf_$cn/hds/.
done

for ((c=1;c<=8;c++)) do
  ln -sf ./hds/shd_new_$c.ref ./sm2w/wf_$cn/strt_layer_$c.ref
done

# MOD2TEC FILES 
ln -sf ../../../mod2tec/settings.fig ./sm2w/wf_$cn/mod2tec/.
ln -sf ../../../mod2tec/mod2hyd_CV.in ./sm2w/wf_$cn/mod2tec/.
ln -sf ../../../mod2tec/mod2hyd_2W.in ./sm2w/wf_$cn/mod2tec/.
ln -sf ../../../mod2tec/P2R_COVID.crd ./sm2w/wf_$cn/mod2tec/.
ln -sf ../../../mod2tec/P2R_trnd_act_hds.crd ./sm2w/wf_$cn/mod2tec/.
ln -sf ../../../mod2tec/P2R_trnd_act_hds.crd ./sm2w/wf_$cn/mod2tec/.
ln -sf ../../../hds/P2Rv9.1_2W.spc ./sm2w/wf_$cn/mod2tec/P2Rv9.1_2W.spc
done

