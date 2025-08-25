./mf2k-mst-cpcc09dpl.x P2Rv9.1.nam
cd mpath
./mpath5.x mpath_fin.rsp
rm temp.cbf
rm summary.pth
cd ..
cd mod2tec
./mod2hyd_d.x < mod2hyd_d.in
cd ..
rm P2Rv9.1.cbb

