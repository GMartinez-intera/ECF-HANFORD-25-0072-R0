for cn in '0' '1' '10' '102' '103' '104' '106' '107' '108' '11' '110' '112' '113' '114' '117' '118' '12' '120' '122' '123' '124' '125' '126' '127' '128' '13' '133' '14' '140' '142' '143' '144' '146' '147' '149' '15' '150' '151' '152' '153' '154' '156' '157' '158' '159' '16' '160' '162' '163' '164' '165' '166' '168' '17' '171' '172' '173' '175' '176' '177' '178' '179' '18' '180' '182' '183' '184' '185' '186' '187' '189' '190' '192' '193' '195' '196' '197' '198' '199' '2' '20' '200' '201' '202' '203' '204' '205' '206' '207' '208' '209' '21' '210' '211' '214' '215' '218' '219' '22' '220' '221' '223' '225' '226' '227' '228' '229' '23' '231' '232' '233' '234' '235' '237' '239' '24' '240' '241' '242' '243' '244' '245' '246' '247' '248' '249' '25' '250' '251' '252' '254' '256' '257' '258' '259' '26' '260' '261' '262' '263' '264' '265' '266' '267' '268' '27' '270' '271' '273' '276' '277' '278' '279' '280' '281' '282' '283' '285' '286' '287' '288' '29' '290' '291' '292' '293' '294' '296' '297' '298' '299' '3' '30' '300' '301' '302' '303' '304' '307' '308' '309' '31' '310' '311' '312' '313' '314' '315' '316' '318' '319' '32' '320' '321' '322' '323' '324' '325' '326' '327' '328' '329' '330' '331' '332' '333' '334' '335' '336' '338' '34' '341' '342' '343' '344' '346' '347' '348' '349' '35' '350' '351' '352' '353' '354' '355' '356' '357' '358' '37' '38' '39' '4' '40' '41' '43' '44' '45' '46' '47' '48' '49' '5' '50' '51' '53' '54' '55' '56' '58' '59' '6' '60' '61' '62' '65' '66' '67' '68' '69' '70' '72' '73' '74' '75' '77' '8' '80' '82' '84' '92' '93' '96' '97' '98' 'base'
do
# Executable
#mkdir ./sims/wf_$cn
#mkdir ./sims/wf_$cn/rch
#mkdir ./sims/wf_$cn/mpath
ln -sf /state/partition1/chprc/bin/mf2k-mst-cpcc09dpl.x ./sims/wf_$cn/.
ln -sf /state/partition1/chprc/bin/modpath-mst-chprc06dp.x ./sims/wf_$cn/mpath/.

# base simulation files that don't change realization to realization
# GEO
ln -sf ../../wf_pred/flow/P2RSW/model_top.ref ./sims/wf_$cn/model_top.ref
for ((c=1;c<=8;c++)) do
  ln -sf ../../wf_pred/flow/P2RSW/botm_layer_$c.ref ./sims/wf_$cn/botm_layer_$c.ref
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../wf_pred/flow/P2RSW/ibound_layer_$c.ref ./sims/wf_$cn/ibound_layer_$c.ref
done
ln -sf ../../wf_pred/flow/P2RSW/delc.ref ./sims/wf_$cn/delc.ref
ln -sf ../../wf_pred/flow/P2RSW/delr.ref ./sims/wf_$cn/delr.ref
for ((c=1;c<=8;c++)) do
  ln -sf ../../smhs/wf_$cn/mod2tec/P2Rv9.1_2018_shd_l_$c.ref ./sims/wf_$cn/P2RSW_shd_2018_ly$c.ref
done
# MODFLOW Input Files

ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.bas ./sims/wf_$cn/P2Rv9.1.bas
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.chd ./sims/wf_$cn/P2Rv9.1.chd
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.dis ./sims/wf_$cn/P2Rv9.1.dis
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.hfb ./sims/wf_$cn/P2Rv9.1.hfb
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.lmt ./sims/wf_$cn/P2Rv9.1.lmt
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.lpf ./sims/wf_$cn/P2Rv9.1.lpf
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.mnw2 ./sims/wf_$cn/P2Rv9.1.mnw2
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.mnwi ./sims/wf_$cn/P2Rv9.1.mnwi
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.mst ./sims/wf_$cn/P2Rv9.1.mst
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.nam ./sims/wf_$cn/P2Rv9.1.nam
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.oc ./sims/wf_$cn/P2Rv9.1.oc
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.ort ./sims/wf_$cn/P2Rv9.1.ort
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.rch ./sims/wf_$cn/P2Rv9.1.rch
ln -sf ../../wf_pred/flow/P2RSW/P2Rv9.1.riv ./sims/wf_$cn/P2Rv9.1.riv
ln -sf ../../run_mf2k.sh ./sims/wf_$cn/.
# Property Files for each realization
for ((c=1;c<=8;c++)) do
  ln -sf ../../prop/real_$cn\_iter_2/P2RSW/ss_Layer_$c.ref ./sims/wf_$cn/ss_Layer_$c.ref
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../prop/real_$cn\_iter_2/P2RSW/sy_Layer_$c.ref ./sims/wf_$cn/sy_Layer_$c.ref
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../prop/real_$cn\_iter_2/P2RSW/hk_Layer_$c.ref ./sims/wf_$cn/hk_Layer_$c.ref
done
# Recharge Files
for f in `basename -a ./rech/$cn/rch*.ref`
do 
ln -sf ../../../rech/$cn/$f ./sims/wf_$cn/rch/$f
#echo "ln -sf ./$f ./nsbs/$cn/hss/."
done


# MODPATH FILES 
#mpath
ln -sf ../../../wf_pred/flow/P2RSW/mpath/200E_Locs.loc ./sims/wf_$cn/mpath/.
ln -sf ../../../wf_pred/flow/P2RSW/mpath/modpath.dat ./sims/wf_$cn/mpath/.
ln -sf ../../../wf_pred/flow/P2RSW/mpath/P2Rv9.1.dis ./sims/wf_$cn/mpath/.
ln -sf ../../../wf_pred/flow/P2RSW/mpath/P2Rv9.1.dat ./sims/wf_$cn/mpath/.
ln -sf ../../../wf_pred/flow/P2RSW/mpath/mpath_fin.rsp ./sims/wf_$cn/mpath/.
ln -sf ../P2Rv9.1.cbb ./sims/wf_$cn/mpath/.
ln -sf ../P2Rv9.1.hds ./sims/wf_$cn/mpath/.
ln -sf ../../../mpath5.x ./sims/wf_$cn/mpath/.
for ((c=1;c<=8;c++)) do
  ln -sf ../../../prop/real_$cn\_iter_2/P2RSW/prsity_layer_$c.ref ./sims/wf_$cn/mpath/.
done

done

