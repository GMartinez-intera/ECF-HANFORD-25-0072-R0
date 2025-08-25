for cn in '0' '1' '10' '102' '103' '104' '106' '107' '108' '11' '110' '112' '113' '114' '117' '118' '12' '120' '122' '123' '124' '125' '126' '127' '128' '13' '133' '14' '140' '142' '143' '144' '146' '147' '149' '15' '150' '151' '152' '153' '154' '156' '157' '158' '159' '16' '160' '162' '163' '164' '165' '166' '168' '17' '171' '172' '173' '175' '176' '177' '178' '179' '18' '180' '182' '183' '184' '185' '186' '187' '189' '190' '192' '193' '195' '196' '197' '198' '199' '2' '20' '200' '201' '202' '203' '204' '205' '206' '207' '208' '209' '21' '210' '211' '214' '215' '218' '219' '22' '220' '221' '223' '225' '226' '227' '228' '229' '23' '231' '232' '233' '234' '235' '237' '239' '24' '240' '241' '242' '243' '244' '245' '246' '247' '248' '249' '25' '250' '251' '252' '254' '256' '257' '258' '259' '26' '260' '261' '262' '263' '264' '265' '266' '267' '268' '27' '270' '271' '273' '276' '277' '278' '279' '280' '281' '282' '283' '285' '286' '287' '288' '29' '290' '291' '292' '293' '294' '296' '297' '298' '299' '3' '30' '300' '301' '302' '303' '304' '307' '308' '309' '31' '310' '311' '312' '313' '314' '315' '316' '318' '319' '32' '320' '321' '322' '323' '324' '325' '326' '327' '328' '329' '330' '331' '332' '333' '334' '335' '336' '338' '34' '341' '342' '343' '344' '346' '347' '348' '349' '35' '350' '351' '352' '353' '354' '355' '356' '357' '358' '37' '38' '39' '4' '40' '41' '43' '44' '45' '46' '47' '48' '49' '5' '50' '51' '53' '54' '55' '56' '58' '59' '6' '60' '61' '62' '65' '66' '67' '68' '69' '70' '72' '73' '74' '75' '77' '8' '80' '82' '84' '92' '93' '96' '97' '98' 'base'
do
# Executable
#mkdir ./smhs/wf_$cn
#mkdir ./smhs/wf_$cn/rch
#mkdir ./smhs/wf_$cn/mod2tec
ln -sf /state/partition1/chprc/bin/mf2k-mst-cpcc09dpl.x ./smhs/wf_$cn/.

# base simulation files that don't change realization to realization
# GEO
ln -sf ../../wf_hist/P2RSW/model_top.ref ./smhs/wf_$cn/model_top.ref
for ((c=1;c<=8;c++)) do
  ln -sf ../../wf_hist/P2RSW/botm_layer_$c.ref ./smhs/wf_$cn/botm_layer_$c.ref
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../wf_hist/P2RSW/ibound_layer_$c.ref ./smhs/wf_$cn/ibound_layer_$c.ref
done
ln -sf ../../wf_hist/P2RSW/delc.ref ./smhs/wf_$cn/delc.ref
ln -sf ../../wf_hist/P2RSW/delr.ref ./smhs/wf_$cn/delr.ref
for ((c=1;c<=8;c++)) do
  ln -sf ../../wf_hist/P2RSW/strt_layer_$c.ref ./smhs/wf_$cn/strt_layer_$c.ref
done
# MODFLOW Input Files

ln -sf ../../wf_hist/P2RSW/P2Rv9.1.bas ./smhs/wf_$cn/P2Rv9.1.bas
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.chd ./smhs/wf_$cn/P2Rv9.1.chd
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.riv ./smhs/wf_$cn/P2Rv9.1.riv
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.dis ./smhs/wf_$cn/P2Rv9.1.dis
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.hfb ./smhs/wf_$cn/P2Rv9.1.hfb
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.lmt ./smhs/wf_$cn/P2Rv9.1.lmt
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.lpf ./smhs/wf_$cn/P2Rv9.1.lpf
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.mnw2 ./smhs/wf_$cn/P2Rv9.1.mnw2
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.mnwi ./smhs/wf_$cn/P2Rv9.1.mnwi
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.mst ./smhs/wf_$cn/P2Rv9.1.mst
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.nam ./smhs/wf_$cn/P2Rv9.1.nam
ln -sf ../../wf_hist/P2RSW/P2Rv9.1_ato.oc ./smhs/wf_$cn/P2Rv9.1_ato.oc
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.ort ./smhs/wf_$cn/P2Rv9.1.ort
ln -sf ../../wf_hist/P2RSW/P2Rv9.1.rch ./smhs/wf_$cn/P2Rv9.1.rch
ln -sf ../../run_hist.sh ./smhs/wf_$cn/.
# Property Files for each realization
for ((c=1;c<=8;c++)) do
  ln -sf ../../prop/real_$cn\_iter_2/P2RSW/ss_Layer_$c.ref ./smhs/wf_$cn/ss_Layer_$c.ref
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../prop/real_$cn\_iter_2/P2RSW/sy_Layer_$c.ref ./smhs/wf_$cn/sy_Layer_$c.ref
done
for ((c=1;c<=8;c++)) do
  ln -sf ../../prop/real_$cn\_iter_2/P2RSW/hk_Layer_$c.ref ./smhs/wf_$cn/hk_Layer_$c.ref
done
# Recharge Files
for f in `basename -a ./prop/real_$cn\_iter_2/P2RSW/rech*.ref`
do 
ln -sf ../../../prop/real_$cn\_iter_2/P2RSW/$f ./smhs/wf_$cn/rch/$f
#echo "ln -sf ./$f ./nsbs/$cn/hss/."
done


# MOD2TEC FILES 
ln -sf ../../../mod2tec/settings.fig ./smhs/wf_$cn/mod2tec/.
ln -sf ../../../mod2tec/many2tim_d.in ./smhs/wf_$cn/mod2tec/.
ln -sf ../../../mod2tec/many2tim_d.x ./smhs/wf_$cn/mod2tec/.
for ((c=1;c<=8;c++)) do
  ln -sf ../../../prop/real_$cn\_iter_2/P2RSW/prsity_layer_$c.ref ./sims/wf_$cn/mpath/.
done

done

