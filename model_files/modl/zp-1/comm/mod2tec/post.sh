cd flow/mod2tec
./mod2hyd_d.x < mod2hyd_hds_zp1.in
./mod2hyd_d.x < mod2hyd_hds_mon.in
perl getSimEquiv_2W_ext.pl
perl getSimEquiv_2W_mon.pl
cd ../..
cd tran/mod2tec
./mod2hyd_d.x < mod2hyd_cnc_zp1.in
./mod2hyd_d.x < mod2hyd_cnc_mon.in
perl getSimEquiv_2Wc_ext.pl
perl getSimEquiv_2Wc_mon.pl
cd ../..

