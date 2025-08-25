
#for cn in 'crvi' 'cyan' 'ctet' 'i129' 'no3_' 'sr90' 'tc99' 'tce_' 'trit' 'utot'
for cn in 'tc99' 
do
cd ./nsbs/$cn
./runMt3d.sh > file.log &
cd ../..
done

