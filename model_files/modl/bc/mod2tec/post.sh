
./m2k2max_dp.x < m2k2max.in
cp AREA_ZONES.inf ZONES.inf
./zonm3d_dp.x  < zonm3d.in
cp zone_mass.out zone_mass_AR.out
./m3d2mas_dp.x < m3d2mas.in
cp mas_out.out mas_out_AR.out
./m2k2ddn.x < m2k2ddn.in
cp zonal_out.out zonal_AR.out

