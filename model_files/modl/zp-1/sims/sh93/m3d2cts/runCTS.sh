#!/bin/bash
./m3d2cts_dp.x < m3d2cts.in
sed "s/replacval/    -0.999    /g" "template.cts" > "../tran/P2RGWM.cts"
