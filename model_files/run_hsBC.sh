# GM 7/29/2025 Based on revised from run_hs2W.sh. Changes based on base/flow/P2RBC.nam
# Probably create symbolic link to the right location
cd chdp
./mod2obs_d.x < mod2obs_act.in
python split_chd.py P2RBC_chd.out   # revise how P2RBC_chd.out is used. is chdgenerate.py using it?
python chdgenerate.py --c grid_BC_chd.txt --o P2RBC.chd
cd ..
cd hds
python srt_heads.py 
cd ..
./mf2k-mst-cpcc09dpl.x P2RBC.nam
#cd mod2tec                    # I am thinking this is for hydrograph genreation, no needed, just flow files to run transport      
#./mod2hyd_d.x < mod2hyd_CV.in #TBD 
#./mod2hyd_d.x < mod2hyd_2W.in #TBD
cd ..
#rm P2Wv9.1.ftl  # needed for cts and transport
rm P2Wv9.1.cbb   # I feel we do not need it now
#rm P2Wv9.1.hds

