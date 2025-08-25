for cn in  'sc01'    
       	#'0' '1' '10' '102' '103' '104' '106' '107' '108' '11' '110' '112' '113' '114' '117' '118' '12' '120' '122' '123' '124' '125' '126' '127' '128' '13' '133' '14' '140' '142' '143' '144' '146' '147' '149' '15' '150' '151' '152' '153' '154' '156' '157' '158' '159' '16' '160' '162' '163' '164' '165' '166' '168' '17' '171' '172' '173' '175' '176' '177' '178' '179' '18' '180' '182' '183' '184' '185' '186' '187' '189' '190' '192' '193' '195' '196' '197' '198' '199' '2' '20' '200' '201' '202' '203' '204' '205' '206' '207' '208' '209' '21' '210' '211' '214' '215' '218' '219' '22' '220' '221' '223' '225' '226' '227' '228' '229' '23' '231' '232' '233' '234' '235' '237' '239' '24' '240' '241' '242' '243' '244' '245' '246' '247' '248' '249' '25' '250' '251' '252' '254' '256' '257' '258' '259' '26' '260' '261' '262' '263' '264' '265' '266' '267' '268' '27' '270' '271' '273' '276' '277' '278' '279' '280' '281' '282' '283' '285' '286' '287' '288' '29' '290' '291' '292' '293' '294' '296' '297' '298' '299' '3' '30' '300' '301' '302' '303' '304' '307' '308' '309' '31' '310' '311' '312' '313' '314' '315' '316' '318' '319' '32' '320' '321' '322' '323' '324' '325' '326' '327' '328' '329' '330' '331' '332' '333' '334' '335' '336' '338' '34' '341' '342' '343' '344' '346' '347' '348' '349' '35' '350' '351' '352' '353' '354' '355' '356' '357' '358' '37' '38' '39' '4' '40' '41' '43' '44' '45' '46' '47' '48' '49' '5' '50' '51' '53' '54' '55' '56' '58' '59' '6' '60' '61' '62' '65' '66' '67' '68' '69' '70' '72' '73' '74' '75' '77' '8' '80' '82' '84' '92' '93' '96' '97' '98' 'base'
do
# Executable
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
ln -sf ../../../../comm/mod2tec/mod2hyd_hds_zp1.in ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/mod2hyd_hds_mon.in ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/mod2hyd_cnc_zp1.in ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/mod2hyd_cnc_mon.in ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/2W.crd ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/2W.crd ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2R_hds.tpl ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2R_InjExt_hds.tpl ./sims/$cn/flow/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2R_cnc.tpl ./sims/$cn/tran/mod2tec/.
ln -sf ../../../../comm/mod2tec/P2R_InjExt_cnc.tpl ./sims/$cn/tran/mod2tec/.
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



done

