for cn in  'sc01'    
       	#'0' '1' '10' '102' '103' '104' '106' '107' '108' '11' '110' '112' '113' '114' '117' '118' '12' '120' '122' '123' '124' '125' '126' '127' '128' '13' '133' '14' '140' '142' '143' '144' '146' '147' '149' '15' '150' '151' '152' '153' '154' '156' '157' '158' '159' '16' '160' '162' '163' '164' '165' '166' '168' '17' '171' '172' '173' '175' '176' '177' '178' '179' '18' '180' '182' '183' '184' '185' '186' '187' '189' '190' '192' '193' '195' '196' '197' '198' '199' '2' '20' '200' '201' '202' '203' '204' '205' '206' '207' '208' '209' '21' '210' '211' '214' '215' '218' '219' '22' '220' '221' '223' '225' '226' '227' '228' '229' '23' '231' '232' '233' '234' '235' '237' '239' '24' '240' '241' '242' '243' '244' '245' '246' '247' '248' '249' '25' '250' '251' '252' '254' '256' '257' '258' '259' '26' '260' '261' '262' '263' '264' '265' '266' '267' '268' '27' '270' '271' '273' '276' '277' '278' '279' '280' '281' '282' '283' '285' '286' '287' '288' '29' '290' '291' '292' '293' '294' '296' '297' '298' '299' '3' '30' '300' '301' '302' '303' '304' '307' '308' '309' '31' '310' '311' '312' '313' '314' '315' '316' '318' '319' '32' '320' '321' '322' '323' '324' '325' '326' '327' '328' '329' '330' '331' '332' '333' '334' '335' '336' '338' '34' '341' '342' '343' '344' '346' '347' '348' '349' '35' '350' '351' '352' '353' '354' '355' '356' '357' '358' '37' '38' '39' '4' '40' '41' '43' '44' '45' '46' '47' '48' '49' '5' '50' '51' '53' '54' '55' '56' '58' '59' '6' '60' '61' '62' '65' '66' '67' '68' '69' '70' '72' '73' '74' '75' '77' '8' '80' '82' '84' '92' '93' '96' '97' '98' 'base'
do
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
  ln -sf ../../../comm/flow/prop/ss_Layer_$c.ref ./sims/$cn/flow/ss_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/prop/sy_Layer_$c.ref ./sims/$cn/flow/sy_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/prop/hk_Layer_$c.ref ./sims/$cn/flow/hk_Layer_$c.ref
done
# Recharge Files
for f in `basename -a ./comm/flow/bcnd/rech*.ref`
do 
ln -sf ../../../../comm/flow/bcnd/$f ./sims/$cn/flow/rch/$f
#echo "ln -sf ./$f ./nsbs/$cn/hss/."
done
for f in `basename -a ./comm/flow/bcnd/rch*.ref`
do 
ln -sf ../../../../comm/flow/bcnd/$f ./sims/$cn/flow/rch/$f
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
ln -sf ../../../comm/pred/bcnd/P2Rv9.1.mnw2 ./sims/$cn/pred/.
ln -sf ../../../comm/flow/bcnd/P2Rv9.1.mnwi ./sims/$cn/pred/.
ln -sf ../../../comm/flow/base/P2Rv9.1.mst ./sims/$cn/pred/.
ln -sf ../../../comm/flow/base/P2Rv9.1.nam ./sims/$cn/pred/P2R.nam
ln -sf ../../../comm/flow/base/P2Rv9.1_ato.oc ./sims/$cn/pred/.
ln -sf ../../../comm/flow/base/P2Rv9.1.ort ./sims/$cn/pred/.
ln -sf ../../../comm/pred/bcnd/P2Rv9.1.rch ./sims/$cn/pred/.
ln -sf ../../../run_hist.sh ./sims/$cn/pred/.
# Property Files for each realization
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/prop/ss_Layer_$c.ref ./sims/$cn/pred/ss_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/prop/sy_Layer_$c.ref ./sims/$cn/pred/sy_Layer_$c.ref
done
for ((c=1;c<=$nl;c++)) do
  ln -sf ../../../comm/flow/prop/hk_Layer_$c.ref ./sims/$cn/pred/hk_Layer_$c.ref
done
# Recharge Files
for f in `basename -a ./comm/pred/bcnd/rch*.ref`
do 
ln -sf ../../../../comm/pred/bcnd/$f ./sims/$cn/pred/rch/$f
#echo "ln -sf ./$f ./nsbs/$cn/hss/."
done

done

