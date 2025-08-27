#!/bin/bash 
python diagnostics_start_heads_compare.py --dir1 /data/projects/gmartinez/ECF-HANFORD-25-0072-R0/model_files/modl/bc/base/flow --namefile1 P2RBC.nam --dir2 /data/projects/gmartinez/ECF-HANFORD-25-0072-R0/References/Not_EMMA/rpo_base_ciecoc/base/flow --namefile2 P2RBC.nam --label1 sh93 --label2 original --make-diff --tag v4

