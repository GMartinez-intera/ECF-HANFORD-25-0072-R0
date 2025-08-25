
for cn in 'hhb' 'hhn' 'hlb' 'hln' 'hnb' 'hnn' 'lhb' 'lhn' 'llb' 'lln' 'lnb' 'lnn' 'nhb' 'nhn' 'nlb' 'nln' 'nnb' 'nnn' 'nnr' 'hhd' 'hld' 'hnd' 'lhd' 'lld' 'lnd' 'nhd' 'nld' 'nnd'
do
cd ./nsbs/$cn
pwd
grep "HSS TIME-VARYING" P2RGWM.m3d | tail -n 1  
cd ../..
done

