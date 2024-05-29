

clear
use "$data/final datasets/surveydata_merged.dta", clear
 

drop trust_acoruna trust_albacete trust_barcelona trust_bilbao trust_caceres trust_gijon trust_laspalmasgran trust_logrono trust_madrid trust_murcia trust_palmamallorca trust_pamplona trust_santander trust_sevilla trust_valencia trust_valladolid trust_zaragoza trustindex z_trustindex z_trust_acoruna z_trust_albacete z_trust_barcelona z_trust_bilbao z_trust_caceres z_trust_gijon z_trust_laspalmasgran z_trust_logrono z_trust_madrid z_trust_murcia z_trust_palmamallorca z_trust_pamplona z_trust_santander z_trust_sevilla z_trust_valencia z_trust_valladolid z_trust_zaragoza


gen id_number=_n

keep id_number sentiments_* trust_* similarity_new_* year_enter_lottery province_age17 region_age17 region_lottery* region_military same_region_17_lottery yearofbirth cluster regionalidentity predictedregionalism nationalisticregion nationalisticregion2 militaryservice_mult1

reshape long sentiments_ trust_ similarity_new_, i(id_number) j(region_number)


rename sentiments_ sentiments
rename similarity_new_ similarity_new

*now I need to generate a variable that indicates whether individual `i' did the military service i region `r'

gen region=""
replace region="andalucia" if region_number==1
replace region="aragon" if region_number==2
replace region="asturias" if region_number==3
replace region="baleares" if region_number==4
replace region="canarias" if region_number==5
replace region="cantabria" if region_number==6
replace region="castilla y leon" if region_number==7
replace region="castilla la mancha" if region_number==8
replace region="catalunya" if region_number==9
replace region="extremadura" if region_number==10
replace region="galicia" if region_number==11
replace region="madrid" if region_number==12
replace region="murcia" if region_number==13
replace region="navarra" if region_number==14
replace region="rioja" if region_number==15
replace region="comunidad valenciana" if region_number==16
replace region="pais vasco" if region_number==17


gen assigned_to_region=0
replace assigned_to_region=1 if region_military==region




foreach var in sentiments trust similarity_new{
  summ `var', d
gen z_`var'=(`var'-r(mean))/r(sd)
 }
 
 gen index_regionsp = (z_sentiments + z_trust)/2

 foreach var in index_regionsp{
  summ `var', d
gen z_`var'=(`var'-r(mean))/r(sd)
 }
 
 egen group_region_region_17=group(region_number region_age17)

 
save "$data/final datasets/surveydata_reshaped.dta", replace
