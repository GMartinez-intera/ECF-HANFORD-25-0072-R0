cn=('Technetium-99') 
cc=('tc99') 
conc_div=('1000')
mass_div=('1.0e+12')
area_mlt=('2500')
conc_unt=('pCi')
mass_unt=('Ci')
area_unt=('m2')
zone=('AR')

for j in "${!zone[@]}"; do
  for i in "${!cc[@]}"; do
# Executable

    echo "${cn[i]} ${cc[i]} ${conc_div[i]} ${mass_div[i]} ${area_mlt[i]}\n"
    cp chart_output_list.tpl chart_output_list.txt
    sed -i "s/COCNAME/${cn[i]}/g" chart_output_list.txt
    sed -i "s/ZONECODE/${zone[j]}/g" chart_output_list.txt
    sed -i "s/COCCODE/${cc[i]}/g" chart_output_list.txt
    sed -i "s/COCMULTIPLY/${conc_div[i]}/g" chart_output_list.txt
    sed -i "s/UNITCODE/${conc_unt[i]}/g" chart_output_list.txt

    R -f Plot_CIE_Conc_Charts.R

  done
done

