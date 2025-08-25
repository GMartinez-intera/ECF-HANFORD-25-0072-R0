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

    cp chart_area_list.tpl chart_area_list.txt
    sed -i "s/COCNAME/${cn[i]}/g" chart_area_list.txt
    sed -i "s/ZONECODE/${zone[j]}/g" chart_area_list.txt
    sed -i "s/COCCODE/${cc[i]}/g" chart_area_list.txt
    sed -i "s/COCMULTIPLY/${area_mlt[i]}/g" chart_area_list.txt
    sed -i "s/UNITCODE/${area_unt[i]}/g" chart_area_list.txt

    R -f Plot_CIE_Area_Charts.R

    cp chart_mass_list.tpl chart_mass_list.txt
    sed -i "s/COCNAME/${cn[i]}/g" chart_mass_list.txt
    sed -i "s/ZONECODE/${zone[j]}/g" chart_mass_list.txt
    sed -i "s/COCCODE/${cc[i]}/g" chart_mass_list.txt
    sed -i "s/COCMULTIPLY/${mass_div[i]}/g" chart_mass_list.txt
    sed -i "s/UNITCODE/${mass_unt[i]}/g" chart_mass_list.txt

    R -f Plot_CIE_Mass_Charts.R

  done
done

