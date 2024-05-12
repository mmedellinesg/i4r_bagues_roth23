


clear 
insheet using "$data/Lucidsurvey/December Pilot/provincia-codigo_provincia.txt"
keep codigo_provincia region
rename codigo_provincia province
rename region region_string
save "$data/Lucidsurvey/December Pilot/codigo_provincia-region.dta", replace

**This database includes information on selected variables from CIS surveys number 2234, 2277, 2317, 2379, 2447, 2592, 2680, 2825, 2912, 2998, 3110.
*This information can be requested from CIS at https://analisis.cis.es/fid/fid.jsp


clear
import spss using "$data/surveys cis/FID_2675.sav"
rename _v1 male
recode male (2=0) (-99=.)
rename _v2 province
rename _v3 citizenship
rename _v4 patriotism

**we add name of region
merge n:1 province using "$data/Lucidsurvey/December Pilot/codigo_provincia-region.dta"
drop if _==2
drop _

gen nationalistic=0
replace nationalistic=1 if region_string=="baleares" |  region_string=="catalunya" |  region_string=="pais vasco" |  region_string=="navarra" |  region_string=="galicia" 


*we drop foreigners
drop if citizenship==2 | citizenship==9

*we drop city-regions - only 8 obs each
drop if region_string=="melilla" | region_string=="ceuta"


replace patriotism=. if (patriotism==9 | patriotism==8 | patriotism==-99)


gen  proud_spanish = .
replace proud_spanish=0 if patriotism!=.
replace proud_spanish=1 if patriotism==1
 
la var proud_spanish "Proud to be Spanish"

table region_string, c(mean proud_spanish count proud_spanish) format(%9.2f) 

