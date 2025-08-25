cd chdp
./mod2obs_d.x < mod2obs_act.in
python split_chd.py P2R2W_chd.out
python chdgenerate.py --c grid_2W_chd.txt --o P2Wv9.1.chd
cd ..
cd hds
python srt_heads.py 
cd ..
./mf2k-mst-cpcc09dpl.x P2Wv9.1.nam
cd mod2tec
./mod2hyd_d.x < mod2hyd_CV.in
./mod2hyd_d.x < mod2hyd_2W.in
cd ..
rm P2Wv9.1.ftl
rm P2Wv9.1.cbb
#rm P2Wv9.1.hds

