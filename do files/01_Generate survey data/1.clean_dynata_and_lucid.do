


	***We obtained data from two different companies: Dynata and Lucid

	*We download the data collected by Dynata
	clear
	insheet using "$data/Dynata survey/raw_anonymized.csv", names
	gen sample="dynata"
	save "$data/Dynata survey/raw.dta", replace

	*We download the data collected by Lucid

	clear
	insheet using "$data/Lucidsurvey/Main/raw_anonymized.csv", names
	gen sample="lucid_main"
	append using "$data/Dynata survey/raw.dta"
	erase "$data/Dynata survey/raw.dta"
	destring *, replace


****************************We keep only respondents who participated in the lottery****************************

*Some individuals 
*we recode a few individuals who selected multiple options
/*
variable militaryservice coding:
1
Realicé el servicio militar obligatorio (la “mili”)
(I did the compulsory military service)
2
Presté el servicio militar con carácter voluntario (ejército profesional)
(I enrolled in the professional army)
3
Cumplí la prestación social obligatoria
(I did the social service)
4
Quedé exento de cumplir el servicio militar obligatorio
(I was exempted from serving in the compulsory military service)
5
Otras situaciones
(Other situations)
*/

* Replicator addition - to preserve original variable before recoding
gen militaryoriginal = militaryservice

* Replicator's note - All respondents who included 1 as an option are coded as 1
replace militaryservice="1" if substr(militaryservice,1,1)=="1"
replace militaryservice="3" if index(militaryservice,"3")!=0
replace militaryservice="4" if index(militaryservice,"4")!=0
replace militaryservice="2" if index(militaryservice,"2")!=0

* Replicator addition: We use a more conservative approach, where those who
* selected 1 + another choice are dropped.
gen militaryservice_mult1=(substr(militaryoriginal,1,2)=="1,")
*drop if militaryservice_mult1==1

destring militaryservice, replace

label define militaryservicelabel 1 "Compulsary military service" 2 "Served voluntarily in the army"  3 "Compulsary social service" 4 "Exempted" 5 "Other situations"

label values militaryservice militaryservicelabel



*lottery - three possible cases: (i) lottery+mili, (ii) lottery+exempted (iii) lottery + social service (objecion sobrevenida)

*1st mili
label define lotterylabel 1 "Assigned through a lottery" 0 "Not assigned through a lottery"
rename lottery_location lottery 
label values  lottery lotterylabel
recode lottery (2=0)


*Intention to treat: some people participated in the lottery but then decided to do the social service {"objecion sobrevenida"}
*2nd
replace lottery=1 if social_sorteado==1
replace lottery=0 if social_sorteado==2

replace year_enter_lottery=social_sorteado_year if social_sorteado_year!=.

*3rd
replace lottery=1 if lottery_excedente==1
replace lottery=0 if lottery_excedente==0


*exempted and voluntary did not enter lottery
replace lottery=0 if militaryservice==2 | militaryservice==5

keep if lottery==1

****************************We clean the dataset: rename variables etc

**we rename some variable names 
rename dateofbirth1_1 yearofbirth_check
rename dateofbirth2_1 monthofbirth
*rename dateofbirth3_1 dayofbirth

rename start_military1_1 startyear_military
rename start_military2_1 startmonth_military

rename province_birth_fath province_birth_father
rename province_birth_moth province_birth_mother

****Live at age 17

*we assign the province of birth if the respondent reply that they were still living in the same province at age 17
replace province_age17 = province_birth if moveprovinceofbi==1

*******Year military & year lottery
rename provincemili_check province_mili_check
rename provincemilitary3mon province_military3mon


***Missing values were coded as "53"

foreach i in province_military3mon province_military3mon social_sorteado_prov province_mili_check {
replace `i'=. if `i'==53
}






**We identify individuals who were randomly exempted from doing the military service:

gen excedente_de_cupo=.
replace excedente_de_cupo=0 if lottery==1
replace excedente_de_cupo=1 if lottery_excedente==1



***We also codify the province to which individuals where assigned


gen province_lottery=.
*1st
replace province_lottery=province_military3mon if lottery==1
*2nd
replace province_lottery=social_sorteado_prov if province_lottery==. & lottery==1

 
*for some observations with missing lottery date we input it based on their year of birth.

rename year_enter_lottery year_lottery
replace year_lottery = startyear_military - 1 if year_lottery==. & lottery==1
 
save "$data/mainsurveys_clean.dta", replace


***********************We add information on region*******************
*Note: the survey only collected information at the province level (50 provinces). We also assigned the corresponding region and the military region

**region-province correspondence 
foreach i in birth birth_father birth_mother age17 residence lottery military3mon /*mili_remainder1 mili_remainder2*/ {
clear 
insheet using "$data/Lucidsurvey/December Pilot/provincia-codigo_provincia.txt"
replace codigo_provincia=_n
keep codigo_provincia region region_militar*
rename codigo_provincia province_`i'
rename region region_`i'
save "$data/Lucidsurvey/December Pilot/codigo_provincia-region_`i'.dta", replace
}

**military region-province correspondence
foreach i in age17 lottery {
clear 
insheet using "$data/Lucidsurvey/December Pilot/provincia-codigo_provincia.txt"
replace codigo_provincia=_n
keep codigo_provincia region_militar*
rename codigo_provincia province_`i'
rename region_militar_tierra region_tierra_`i'
rename region_militar_naval region_naval_`i'
rename region_militar_aire region_aire_`i'
save "$data/Lucidsurvey/December Pilot/codigo_provincia-region_militar_`i'.dta", replace
}

**we introduce region
clear
use "$data/mainsurveys_clean.dta"
foreach i in birth birth_father birth_mother age17 residence lottery military3mon /*mili_remainder1 mili_remainder2 */{
merge n:1 province_`i' using "$data/Lucidsurvey/December Pilot/codigo_provincia-region_`i'.dta"
erase "$data/Lucidsurvey/December Pilot/codigo_provincia-region_`i'.dta"
drop if _==2
drop _
}

**we introduce military region
foreach i in age17 lottery {
merge n:1 province_`i' using "$data/Lucidsurvey/December Pilot/codigo_provincia-region_militar_`i'.dta"
erase "$data/Lucidsurvey/December Pilot/codigo_provincia-region_militar_`i'.dta"
drop if _==2
drop _
}

foreach i in age17 lottery {
gen area_`i'=""
replace area_`i'=region_tierra_`i' if unit==1 | unit==4
replace area_`i'=region_tierra_`i' if unit==. & militaryservice==3
replace area_`i'=region_aire_`i' if unit==2
replace area_`i'=region_naval_`i' if unit==3
}
drop region_militar_tierra* region_militar_naval* region_militar_aire*


*************We define variables indicating whether the individual was living at age 17 in the province or region of birth


gen same_province_17_mili=.
replace same_province_17_mili=1 if province_military==province_age17 & militaryservice==1 & province_military!=.
replace same_province_17_mili=0 if province_military!=province_age17 & militaryservice==1 & province_military!=.

gen same_province_17_lottery=.
replace same_province_17_lottery=1 if province_lottery==province_age17 & province_lottery!=. 
replace same_province_17_lottery=0 if province_lottery!=province_age17 & province_lottery!=. 



*we need to take into account that individuals may do the military service in different regions
*foreach var of varlist region_military3mon region_mili_remainder1 region_mili_remainder2 {
gen same_region_17_mili=.
replace same_region_17_mili=1 if (region_military3mon==region_age17 & (militaryservice==1)  & region_military3mon!="")
replace same_region_17_mili=0 if (region_military3mon!=region_age17 & (militaryservice==1)  & region_military3mon!="")

gen same_region_17_lottery=.
replace same_region_17_lottery=1 if (region_lottery==region_age17 & region_lottery!="")
replace same_region_17_lottery=0 if (region_lottery!=region_age17 & region_lottery!="")


**Years outside

recode outsideprovinc (2=0)
rename outsideprovinc outside_region

rename yearsoutside years_outside

replace years_outside=0 if outside_region==0


rename province_military3mon province_military

rename region_military3mon region_military


*employed (full-time + part-time + self-employed)

gen employed=.
replace employed=0 if employmentstatus!=.

save "$data/mainsurveys_clean.dta", replace



