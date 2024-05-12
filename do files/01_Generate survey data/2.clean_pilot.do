

clear
insheet using "$data/Lucidsurvey/December Pilot/raw_anonymized.csv", names

gen sample="pilot"

rename finished finish
destring *, replace


************************************We keep only respondents who participated in the lottery**********************

****Randomly exempted from the military service (`excedente de cupo')

gen excedente_de_cupo=.
*0 if entered the lottery
replace excedente_de_cupo=0 if militaryservice==1
replace excedente_de_cupo=1 if whynoservice==1


keep if militaryservice==1 | excedente_de_cupo==1


**Note: in the pilot we collected information about all provinces where the conscript spent some time during his service

rename provincemilitary province_military
split province_military, p(",")
forvalues i=1(1)11 {
destring province_military`i', replace
}

rename province_birth_fath province_birth_father
rename province_birth_moth province_birth_mother

drop if province_birth==.
save "$data/Lucidsurvey/December Pilot/our survey.dta", replace



**We need to add information about region:
foreach i in birth birth_father birth_mother age17 residence military1 military2 military3 military4 military5 military6 military7 military8 military9 military10 military11 {

clear 
insheet using "$data/Lucidsurvey/December Pilot/provincia-codigo_provincia.txt"
replace codigo_provincia=_n
keep codigo_provincia region region_militar_tierra
rename codigo_provincia province_`i'
rename region region_`i'
renam region_militar_tierra area_`i'
save "$data/Lucidsurvey/December Pilot/codigo_provincia-region_`i'.dta", replace
}

clear
use "$data/Lucidsurvey/December Pilot/our survey.dta"
erase "$data/Lucidsurvey/December Pilot/our survey.dta"
foreach i in birth birth_father birth_mother age17 residence military1 military2 military3 military4 military5 military6 military7 military8 military9 military10 military11 {
merge n:1 province_`i' using "$data/Lucidsurvey/December Pilot/codigo_provincia-region_`i'.dta"
erase "$data/Lucidsurvey/December Pilot/codigo_provincia-region_`i'.dta"
drop if _==2
drop _
}


***********Let us define whether the individual did the military service in the same province

forvalues i=1(1)11 {
gen same_province_17_mili`i'=.
replace same_province_17_mili`i'=1 if province_military`i'==province_age17 & militaryservice==1  & province_military`i'!=.
replace same_province_17_mili`i'=0 if province_military`i'!=province_age17 & militaryservice==1  & province_military`i'!=.
}

egen same_province_17_mili=rmin(same_province_17_mili1 - same_province_17_mili11)

forvalues i=1(1)11 {
drop same_province_17_mili`i' /*province_military`i'*/ province_military`i'
}


*we need to take into account that individuals may do the military service in different regions
forvalues i=1(1)11 {
foreach j in region {
gen same_`j'_17_mili`i'=.
replace same_`j'_17_mili`i'=1 if `j'_military`i'==`j'_age17 & militaryservice==1  & `j'_military`i'!=""
replace same_`j'_17_mili`i'=0 if `j'_military`i'!=`j'_age17 & militaryservice==1  & `j'_military`i'!=""
}
}

foreach j in region {
egen same_`j'_17_mili=rmin(same_`j'_17_mili1 - same_`j'_17_mili11)
}

foreach j in region {
gen `j'_military=""
replace `j'_military=`j'_age17 if same_`j'_17_mili==1
forvalues i=1(1)11 {
replace `j'_military=`j'_military`i' if `j'_military`i'!=`j'_age17 & `j'_military==""
}
}

forvalues i=1(1)11 {
foreach j in region {
drop same_`j'_17_mili`i' `j'_military`i'
}
}

 
*Year lottery:

gen lottery=1
gen year_lottery = startyear_military - 1
foreach  i in province region {
gen same_`i'_17_lottery=same_`i'_17_mili
*gen `i'_lottery=`i'_military
}

**year lottery for individuals with excedente_de_cupo
*yearofbirth is coded with 1920=1
replace year_lottery=yearofbirth+20 if excedente==1 & yearofbirth+1919<=1966
replace year_lottery=yearofbirth+19 if excedente==1 & yearofbirth+1919==1967 & monthofbirth>=1 & monthofbirth<=4
replace year_lottery=yearofbirth+20 if excedente==1 & yearofbirth+1919==1967 & monthofbirth>=5 & monthofbirth<=12
replace year_lottery=yearofbirth+19 if excedente==1 & yearofbirth+1919==1968 & monthofbirth>=1 & monthofbirth<=8
replace year_lottery=yearofbirth+20 if excedente==1 & yearofbirth+1919==1968 & monthofbirth>=9 & monthofbirth<=12
replace year_lottery=yearofbirth+19 if excedente==1 & yearofbirth+1919>=1969 & yearofbirth!=.
*year_lottery is coded with 1950=1
replace year_lottery=year_lottery-30 if excedente==1

rename finish finished

rename years_outsideprovinc years_outside

save "$data/Lucidsurvey/December Pilot/surveydatafinal.dta", replace 



