./mod2obs_d.x < mod2obs_hst.in
./mod2obs_d.x < mod2obs_prd_dis.in
python split_chd.py P2Rchd1.out w
python split_chd.py P2Rchd2.out a
python chdgenerate.py --c grid_2W_chd.txt --o P2R.chd
