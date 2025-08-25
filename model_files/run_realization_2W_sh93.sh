#!/bin/bash

# [0] - sh93 - name run 
# [1] - zp-1 - model area
# [2] - 320  - ensemble number
# [3] - sh93 - name run site-wide 
# [4] - 25202, SP 69 end of 12/31/2011
python run_realization_2W.py sh93 zp-1 320 sh93 25202.0 >> sh93.log 2>> sh93_error.log

#python post-process-MT.py ./modl/zp-1/sims/sh93 P2Wv9.1.BYND_out "Realization 320  - sh93 - Minimum Phi" > ph93.log &


