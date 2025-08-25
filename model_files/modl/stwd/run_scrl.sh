

names=('sl_a' 'sl_b' 'sl_c' 'sl_d')    
nums=('127' '246' '351' '62')    
for i in "${!names[@]}" 
do
cn=${names[$i]}
rl=${nums[$i]}

cd ./sims/$cn/flow
./run_hist.sh > file.log &
cd ../../..

done

