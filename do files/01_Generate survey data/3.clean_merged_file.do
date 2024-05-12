

clear
use "$data/mainsurveys_clean.dta"
erase "$data/mainsurveys_clean.dta"
append using "$data/Lucidsurvey/December Pilot/surveydatafinal.dta", force
erase "$data/Lucidsurvey/December Pilot/surveydatafinal.dta"



**we adjust coding of some variables
replace yearofbirth = yearofbirth + 1919
replace yearofbirth_check = yearofbirth_check + 1929

foreach i in year_lottery startyear_military social_sorteado_year endyear_service {
replace `i' = `i' + 1949
}


replace start_empl = start_empl + 13 if start_empl!=.

****Sample selection

**We keep only individuals who finished the survey, gave consent, born in Spain, male, and who were consistent in their answers and for whom we know treatment status
keep if finished==1
keep if consent==4
keep if borninspain==1
keep if gender==2
drop if same_region_17_lottery==. & excedente_de_cupo!=1
drop borninspain gender consent finished


****We drop if father was in the military (N=135)
drop if father_occupation==10 

****We drop individuals who provide inconsiste answers (N=368) e.g. replied differently when asked twice about province of birth


gen inconsistent_provincemili = province_mili_check!=province_military if province_mili_check!=. & militaryservice==1
tab inconsistent_provincemili


gen inconsistent_yob = yearofbirth_check!=yearofbirth  if yearofbirth_check!=.
tab inconsistent_yob

gen inconsistent_province17 = province17_check!=province_age17 if province17_check!=. & province_age17!=.
tab inconsistent_province17

gen inconsistent_responses = (inconsistent_province17==1 | inconsistent_yob==1 | inconsistent_provincemili==1)
tab inconsistent_responses

drop if inconsistent_responses==1


*random lottery only implemented until 1991. so only have random variation for those who started the service in 1992 or before!
*after 1992 applicants reported preferences
  
drop if startyear_military>=1993 & startyear_military!=.
drop if year_lottery>=1992 & year_lottery!=.
drop if yearofbirth>=1974

gen age_military=startyear_military-yearofbirth

drop if age_military<16 | (age_military>30 & age_military!=.)


******Apparently some individuals participated more than once in the survey
*To avoid using twice information for the same individual, we drop duplicated observations for individuals using the same IP and born in the same year and month
 
label variable id "Anonymized identifier for IP"
duplicates report id monthofbirth yearofbirth


*first we drop duplicated observations that appear in the pilot (N=104)
gsort id monthofbirth yearofbirth sample -startdate
drop if id==id[_n-1] & monthofbirth==monthofbirth[_n-1] & yearofbirth==yearofbirth[_n-1] & sample=="pilot" & id!=.


*we drop the earlier duplicated observation (N=239)
gsort id monthofbirth yearofbirth -startdate 
drop if id==id[_n-1] & monthofbirth==monthofbirth[_n-1] & yearofbirth==yearofbirth[_n-1] & id!=.
drop id startdate


/*count
count
**N=3618
tab sample militaryservice
*Pilot=551
tab  excedente_de_cupo
*excedente=386
tab social_sorteado
*objetores=93
sum year_lottery
*/

********************************************************************************
*********************We create new variables ***********************************
********************************************************************************

*Same province or region of residence and birth


foreach i in province_birth province_birth_father province_birth_mother province_residence {
gen same_`i'_17=.
replace same_`i'_17=1 if `i'==province_age17 & province_age17!=. & `i'!=.
replace same_`i'_17=0 if `i'!=province_age17 & province_age17!=. & `i'!=.
}

*region
foreach i in region_birth region_birth_father region_birth_mother region_residence {
gen same_`i'_17=.
replace same_`i'_17=1 if `i'==region_age17 & region_age17!="" & `i'!=""
replace same_`i'_17=0 if `i'!=region_age17 & region_age17!="" & `i'!=""
}

*********************************We measure the number of friends **********************************



tostring province_age17 province_military , replace

**We need to identify the number of friends / we will use the index command
*to avoid getting wrong matches, temporarily, I add a comma at the beginning and the end of friends variables, then I remove it

foreach i in friends_province province_age17 province_military  {
replace `i'=","+`i'+"," if `i'!=""
}

gen friends_same_province=.
replace friends_same_province=0 if friends_province!=""
replace friends_same_province=1 if index(friends_province,province_age17)!=0 & province_age17!=""

gen friends_province_mili=.
replace friends_province_mili=0 if friends_province!=""
replace friends_province_mili=1 if index(friends_province,province_military)!=0 & province_military!=""

ssc install egenmore

egen number_friends=noccur(friends_province) if friends_province!="", string(",") 
replace number_friends=number_friends-1 if friends_province!=""

gen number_friends_other_provinces=number_friends-friends_same_province

gen number_friends_exclprovmili=number_friends_other_provinces
*note: we need to take into account that sometimes province_age17==province_military
replace number_friends_exclprovmili=number_friends_exclprovmili-friends_province_mili if province_age17!=province_military


 *now I remove the initial and the final commas
 foreach i in friends_province province_age17 province_military {
replace `i'=substr(`i',2,.) if substr(`i',1,1)==","
replace `i'=substr(`i',1,length(`i')-1) if substr(`i',length(`i'),1)==","
}
 
destring province_age17 province_military, replace


**We construct variables measuring individual characteristics
 
gen high_education = education >=5 if education!=.
gen high_education_father = education_father>=5 if education_father!=.
gen high_education_mother = education_mother>=5 if education_mother!=.
gen small_sizemunicipality = sizemunicipality<=3 if sizemunicipality!=.
replace siblings = siblings - 1

gen inc_cts = 0 if income==1
replace inc_cts = 150 if income==2 & income!=.
replace inc_cts = 450 if income==3 & income!=.
replace inc_cts = 750 if income==4 & income!=.
replace inc_cts = 1050 if income==5 & income!=.
replace inc_cts = 1500 if income==6 & income!=.
replace inc_cts = 2100 if income==7 & income!=.
replace inc_cts = 2700 if income==8 & income!=.
replace inc_cts = 3750 if income==9 & income!=.
replace inc_cts = 5250 if income==10 & income!=.
replace inc_cts = 6750 if income==11 & income!=.
replace inc_cts=. if income==.

*4 "Retired" 5 "Homemaker" 6 "Childcare" 7 "Student" 8 "Unemployed" 9 "Disabled" 10 "Other"
gen notinlaborforce=.
replace notinlaborforce=0 if occupation!=.
replace notinlaborforce=1 if occupation==12 |  (employmentstatus>=4 & employmentstatus<=6) | employmentstatus==9

replace employed = (employmentstatus>=1 & employmentstatus<=3) if employmentstatus!=.
tab employed, m
gen unemployed = (employmentstatus==8) if ((employmentstatus>=1 & employmentstatus<=3) | employmentstatus==8)

gen moth_notinlaborforce = (mother_occupation==12)  if mother_occupation!=.
gen fath_notinlaborforce = (father_occupation==12)  if father_occupation!=.

****define other occupation variables here.

gen fath_ind_agr = industry_father==1 if industry_father!=.
gen fath_ind_industr = industry_father==2 if industry_father!=.
gen fath_ind_constr = industry_father==3 if industry_father!=.
gen fath_ind_serv = industry_father==4 if industry_father!=.
gen fath_ind_other = industry_father==5 if industry_father!=.


gen moth_ind_agr = industry_mother==1 if industry_mother!=.
gen moth_ind_industr = industry_mother==2 if industry_mother!=.
gen moth_ind_constr = industry_mother==3 if industry_mother!=.
gen moth_ind_serv = industry_mother==4 if industry_mother!=.
gen moth_ind_other = industry_mother==5 if industry_mother!=.



*****************************OUTCOME VARIABLES


**share of people from same region of origin in the military 
bys region_military region_age17: egen conscripts_i_j=count(_n)
bys region_military: egen conscripts_j=count(_n)
gen share_conscripts_i_j=(conscripts_i_j-1)/(conscripts_j-1)

gen conscripts_other_regions=1-share_conscripts_i_j

drop conscripts_i_j conscripts_j share_conscripts_i_j



****
  
replace exposure_regions = - exposure_regions + 5
replace exposure_socioec = - exposure_socioec + 5
replace experience_military = - experience_military + 5

foreach var of varlist experience_military exposure_regions exposure_socioec{
summ `var', d
gen z_`var'=(`var'-r(mean))/r(sd)
}


gen turnout = turnout_congress==2 if turnout_congress!=.
drop turnout_congress
gen PSOE = votingparty==1 if votingparty!=.

gen PP = votingparty==2 if votingparty!=.
gen Vox = votingparty==3 if votingparty!=.
gen Ciudadanos = votingparty==4 if votingparty!=.
gen Unidas_Podemos = votingparty==5 if votingparty!=.
gen ERC_Sobiranistes = votingparty==6 if votingparty!=.
gen EAJ_PNV = votingparty==7 if votingparty!=.
gen JxCAT = votingparty==8 if votingparty!=.
gen Otros_partidos = votingparty==9 if votingparty!=.
gen En_blanco = votingparty==10 if votingparty!=.
gen votedregionalist = (ERC_Sobiranistes==1 | EAJ_PNV==1 | JxCAT==1)

gen groupishness = givinga_b_2
drop givinga_b_2
gen universalism = givinga_b_1
drop givinga_b_1
foreach var of varlist nation_sentiment proud_spanish sentiment_flag{
replace `var' = -`var' + 5 
}

gen identity=nation_sentiment+proud_spanish+sentiment_flag


***create a variable for clusters****

rename walletbeliefs1_1 trust_acoruna
rename walletbeliefs1_2 trust_albacete
rename walletbeliefs1_3 trust_barcelona
rename walletbeliefs1_4 trust_bilbao
rename walletbeliefs1_5 trust_caceres
rename walletbeliefs1_6 trust_gijon
rename walletbeliefs1_7 trust_laspalmasgran
rename walletbeliefs1_8 trust_logrono
rename walletbeliefs1_9 trust_madrid
rename walletbeliefs1_10 trust_murcia
rename walletbeliefs1_11 trust_palmamallorca
rename walletbeliefs1_12 trust_pamplona
rename walletbeliefs1_13 trust_santander
rename walletbeliefs1_14 trust_sevilla
rename walletbeliefs1_15 trust_valencia
rename walletbeliefs1_16 trust_valladolid
rename walletbeliefs1_17 trust_zaragoza



*****Other outcome variables*********************************************

*****recode variables 

recode catalonyindependence (2=0) (4=.)
rename catalonyindependence favor_independence_referendum
*gen for_independence = catalonyindependence==1 if catalonyindependence!=.


rename personality_1 selfdiscipline
rename personality_2 openness
rename personality_3 obeidienceauthority

** We define ever_outside


gen ever_outside=.

replace ever_outside=0 if years_outside==0 & (same_region_17_mili==1 | same_region_17_mili==.)  & same_region_birth_17==1 & same_region_residence_17==1
replace ever_outside=1 if (years_outside>0 & years_outside!=.) | same_region_17_mili==0 |  same_region_birth_17==0  | same_region_residence_17==0


********************************************************************************
********************************************************************************
***************************create indices***************************************
********************************************************************************
********************************************************************************




foreach var of varlist universalism groupishness identity nation_sentiment proud_spanish sentiment_flag regionaldistribution views_regionautonomy favor_independence_referendum leftright {
summ `var', d
gen z_`var'=(`var'-r(mean))/r(sd)
}


foreach var of varlist  trust_acoruna trust_albacete trust_barcelona trust_bilbao trust_caceres trust_gijon trust_laspalmasgran trust_logrono trust_madrid trust_murcia trust_palmamallorca trust_pamplona trust_santander trust_sevilla trust_valencia trust_valladolid trust_zaragoza{
replace `var' = - `var' + 5
}



 gen trustindex=.
replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_valencia  + trust_valladolid + trust_zaragoza)/16 if region_age17=="andalucia"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid)/16 if region_age17=="aragon"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="asturias"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="baleares"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16  if region_age17=="canarias"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="cantabria"

replace trustindex = (trust_acoruna + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="castilla la mancha"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_zaragoza)/16 if region_age17=="castilla y leon"

replace trustindex = (trust_acoruna + trust_albacete + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="catalunya"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valladolid + trust_zaragoza)/16 if region_age17=="comunidad valenciana"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="extremadura"

replace trustindex = (trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="galicia"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="madrid"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="murcia"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="navarra"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_caceres + trust_gijon + trust_laspalmasgran + trust_logrono + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="pais vasco"

replace trustindex = (trust_acoruna + trust_albacete + trust_barcelona + trust_bilbao + trust_caceres + trust_gijon + trust_laspalmasgran + trust_madrid + trust_murcia  + trust_palmamallorca + trust_pamplona + trust_santander + trust_sevilla + trust_valencia + trust_valladolid + trust_zaragoza)/16 if region_age17=="rioja"


replace  becas_seneca = - becas_seneca + 5

 

 ***propertly code up.
 tab sample 
 
 gen similarity = similarity_new_1 if sample!="pilot"
 replace similarity_new_1=. if sample!="pilot"

 
foreach var of varlist similarity becas_seneca trustindex trust_acoruna trust_albacete trust_barcelona trust_bilbao trust_caceres trust_gijon trust_laspalmasgran trust_logrono trust_madrid trust_murcia trust_palmamallorca trust_pamplona trust_santander trust_sevilla trust_valencia trust_valladolid trust_zaragoza{
 summ `var', d
gen z_`var'=(`var'-r(mean))/r(sd)
 }


 foreach var of varlist selfdiscipline openness obeidienceauthority{
  summ `var', d
gen z_`var'=(`var'-r(mean))/r(sd)
 }


   replace  similarity_new_1 = beliefs_similarcultu_1 if similarity_new_1==. & (region_residence==region_birth)
   replace  similarity_new_2 = beliefs_similarcultu_2 if similarity_new_2==. & (region_residence==region_birth)
   replace  similarity_new_3 = beliefs_similarcultu_3 if similarity_new_3==. & (region_residence==region_birth)
   replace  similarity_new_4 = beliefs_similarcultu_4 if similarity_new_4==. & (region_residence==region_birth)
   replace  similarity_new_5 = beliefs_similarcultu_5 if similarity_new_5==. & (region_residence==region_birth)
   replace  similarity_new_6 = beliefs_similarcultu_6 if similarity_new_6==. & (region_residence==region_birth)
   replace  similarity_new_7 = beliefs_similarcultu_7 if similarity_new_7==. & (region_residence==region_birth)
   replace  similarity_new_8 = beliefs_similarcultu_8 if similarity_new_8==. & (region_residence==region_birth)
   replace  similarity_new_9 = beliefs_similarcultu_9 if similarity_new_9==. & (region_residence==region_birth)
   replace  similarity_new_10 = beliefs_similarcultu_10 if similarity_new_10==. & (region_residence==region_birth)
   replace  similarity_new_11 = beliefs_similarcultu_11 if similarity_new_11==. & (region_residence==region_birth)
   replace  similarity_new_12 = beliefs_similarcultu_12 if similarity_new_12==. & (region_residence==region_birth)
   replace  similarity_new_13 = beliefs_similarcultu_13 if similarity_new_13==. & (region_residence==region_birth)
   replace  similarity_new_14 = beliefs_similarcultu_14 if similarity_new_14==. & (region_residence==region_birth)
   replace  similarity_new_15 = beliefs_similarcultu_15 if similarity_new_15==. & (region_residence==region_birth)
   replace  similarity_new_16 = beliefs_similarcultu_16 if similarity_new_16==. & (region_residence==region_birth)
   replace  similarity_new_17 = beliefs_similarcultu_17 if similarity_new_17==. & (region_residence==region_birth)
  
 drop beliefs_similarcultu_*
 
  
 gen  simil_andaluces = similarity_new_1
 gen  simil_aragon = similarity_new_2
 gen  simil_astur = similarity_new_3
 gen  simil_baleares = similarity_new_4
 gen  simil_canarios = similarity_new_5
 gen  simil_cantabros = similarity_new_6
 gen  simil_catell_leon = similarity_new_7
 gen  simil_catell_mechegos = similarity_new_8
 gen  simil_catalanes = similarity_new_9
 gen  simil_extremenos = similarity_new_10
 gen  simil_gallegos = similarity_new_11
 gen  simil_madrilenos = similarity_new_12
 gen  simil_murcianos = similarity_new_13
 gen  simil_navarros = similarity_new_14
 gen  simil_rioja = similarity_new_15
 gen  simil_valenc = similarity_new_16
 gen  simil_vascos = similarity_new_17
 

 


 
  foreach var of varlist simil_andaluces simil_aragon simil_astur simil_baleares simil_canarios simil_cantabros simil_catell_leon simil_catell_mechegos simil_catalanes simil_extremenos simil_gallegos simil_madrilenos simil_murcianos simil_navarros simil_rioja simil_valenc simil_vascos{
xi: reg `var' i.region_age17 if same_region_17_mili==1 & (region_birth==region_age17), r

predict pred_`var', xb
 }
 
 gen predictedsimilarity =.
 replace predictedsimilarity = pred_simil_andaluces if region_military=="andalucia"
 replace predictedsimilarity = pred_simil_aragon if region_military=="aragon"
 replace predictedsimilarity = pred_simil_astur if region_military=="asturias"
 replace predictedsimilarity = pred_simil_baleares if region_military=="baleares"
 replace predictedsimilarity = pred_simil_canarios if region_military=="canarias"
 replace predictedsimilarity = pred_simil_cantabros if region_military=="cantabria"
 replace predictedsimilarity = pred_simil_catell_mechegos if region_military=="castilla la mancha"
 replace predictedsimilarity = pred_simil_catell_leon if region_military=="castilla y leon"
 replace predictedsimilarity = pred_simil_catalanes if region_military=="catalunya"
 replace predictedsimilarity = pred_simil_valenc if region_military=="comunidad valenciana"
 replace predictedsimilarity = pred_simil_extremenos if region_military=="extremadura"
 replace predictedsimilarity = pred_simil_gallegos if region_military=="galicia"
 replace predictedsimilarity = pred_simil_madrilenos if region_military=="madrid"
 replace predictedsimilarity = pred_simil_murcianos if region_military=="murcia"
 replace predictedsimilarity = pred_simil_navarros if region_military=="navarra"
 replace predictedsimilarity = pred_simil_vascos if region_military=="pais vasco"
 replace predictedsimilarity = pred_simil_rioja if region_military=="rioja"

tab predictedsimilarity, m  

 

 gen  sentim_andaluces = sentiments_1
 gen  sentim_aragon = sentiments_2
 gen  sentim_astur = sentiments_3
 gen  sentim_baleares = sentiments_4
 gen  sentim_canarios = sentiments_5
 gen  sentim_cantabros = sentiments_6
 gen  sentim_catell_leon = sentiments_7
 gen  sentim_catell_mechegos = sentiments_8
 gen  sentim_catalanes = sentiments_9
 gen  sentim_extremenos = sentiments_10
 gen  sentim_gallegos = sentiments_11
 gen  sentim_madrilenos = sentiments_12
 gen  sentim_murcianos = sentiments_13
 gen  sentim_navarros = sentiments_14
 gen  sentim_rioja = sentiments_15
 gen  sentim_valenc = sentiments_16
 gen  sentim_vascos = sentiments_17
 
 foreach var of varlist sentim_andaluces sentim_aragon sentim_astur sentim_baleares sentim_canarios sentim_cantabros sentim_catell_leon sentim_catell_mechegos sentim_catalanes sentim_extremenos sentim_gallegos sentim_madrilenos sentim_murcianos sentim_navarros sentim_rioja sentim_valenc sentim_vascos{
 xi: reg `var' i.region_age17 if same_region_17_mili==1, r
predict pred_`var', xb
 }
 
  gen predictedsentiment =.
 replace predictedsentiment = pred_sentim_andaluces if region_military=="andalucia"
 replace predictedsentiment = pred_sentim_aragon if region_military=="aragon"
 replace predictedsentiment = pred_sentim_astur if region_military=="asturias"
 replace predictedsentiment = pred_sentim_baleares if region_military=="baleares"
 replace predictedsentiment = pred_sentim_canarios if region_military=="canarias"
 replace predictedsentiment = pred_sentim_cantabros if region_military=="cantabria"
 replace predictedsentiment = pred_sentim_catell_mechegos if region_military=="castilla la mancha"
 replace predictedsentiment = pred_sentim_catell_leon if region_military=="castilla y leon"
 replace predictedsentiment = pred_sentim_catalanes if region_military=="catalunya"
 replace predictedsentiment = pred_sentim_valenc if region_military=="comunidad valenciana"
 replace predictedsentiment = pred_sentim_extremenos if region_military=="extremadura"
 replace predictedsentiment = pred_sentim_gallegos if region_military=="galicia"
 replace predictedsentiment = pred_sentim_madrilenos if region_military=="madrid"
 replace predictedsentiment = pred_sentim_murcianos if region_military=="murcia"
 replace predictedsentiment = pred_sentim_navarros if region_military=="navarra"
 replace predictedsentiment = pred_sentim_vascos if region_military=="pais vasco"
 replace predictedsentiment = pred_sentim_rioja if region_military=="rioja"
 

 gen trust_1 = trust_sevilla
 gen trust_2 = trust_zaragoza
 gen trust_3 = trust_gijon
 gen trust_4 = trust_palmamallorca
 gen trust_5 = trust_laspalmasgran
 gen trust_6 = trust_santander
 gen trust_7 = trust_valladolid
 gen trust_8 = trust_albacete
 gen trust_9 = trust_barcelona
 gen trust_10 = trust_caceres
 gen trust_11 = trust_acoruna
 gen trust_12 = trust_madrid
 gen trust_13 = trust_murcia
 gen trust_14 = trust_pamplona
 gen trust_15 = trust_logrono
 gen trust_16 = trust_valencia
 gen trust_17 = trust_bilbao

              
 foreach var of varlist trust_acoruna trust_albacete trust_barcelona trust_bilbao trust_caceres trust_gijon trust_laspalmasgran trust_logrono trust_madrid trust_murcia trust_palmamallorca trust_pamplona trust_santander trust_sevilla trust_valencia trust_valladolid trust_zaragoza{
 xi: reg `var' i.region_age17 if same_region_17_mili==1, r
predict pred_`var', xb
 }
 
  gen predictedtrust =.
  replace predictedtrust = pred_trust_sevilla if region_military=="andalucia"
 replace predictedtrust = pred_trust_zaragoza if region_military=="aragon"
 replace predictedtrust = pred_trust_gijon if region_military=="asturias"
 replace predictedtrust = pred_trust_palmamallorca if region_military=="baleares"
 replace predictedtrust = pred_trust_laspalmasgran if region_military=="canarias"
 replace predictedtrust = pred_trust_santander if region_military=="cantabria"
 replace predictedtrust = pred_trust_valladolid if region_military=="castilla la mancha"
 replace predictedtrust = pred_trust_albacete if region_military=="castilla y leon"
 replace predictedtrust = pred_trust_barcelona if region_military=="catalunya"
 replace predictedtrust = pred_trust_caceres if region_military=="extremadura"
 replace predictedtrust = pred_trust_acoruna if region_military=="galicia"
 replace predictedtrust = pred_trust_madrid if region_military=="madrid"
 replace predictedtrust = pred_trust_murcia if region_military=="murcia"
 replace predictedtrust = pred_trust_pamplona if region_military=="navarra"
 replace predictedtrust = pred_trust_logrono if region_military=="rioja"
 replace predictedtrust = pred_trust_valencia if region_military=="comunidad valenciana"
 replace predictedtrust = pred_trust_bilbao if region_military=="pais vasco"
  
 
 
 
 gen sentiment_index=.
replace sentiment_index = (sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="andalucia"
replace sentiment_index = (sentim_andaluces + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="aragon"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="asturias"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="baleares"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="canarias"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="cantabria"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_catell_leon + sentim_cantabros + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="castilla la mancha"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_catell_mechegos + sentim_cantabros + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="castilla y leon"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos  + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="catalunya"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_vascos)/16 if region_age17=="comunidad valenciana"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes   + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="extremadura"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="galicia"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="madrid"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_navarros + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="murcia"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos  + sentim_rioja + sentim_valenc + sentim_vascos)/16 if region_age17=="navarra"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_rioja + sentim_valenc)/16 if region_age17=="pais vasco"
replace sentiment_index = (sentim_andaluces + sentim_aragon + sentim_astur + sentim_baleares + sentim_canarios + sentim_cantabros + sentim_catell_leon + sentim_catell_mechegos + sentim_catalanes + sentim_extremenos + sentim_gallegos + sentim_madrilenos + sentim_murcianos + sentim_navarros + sentim_valenc + sentim_vascos)/16 if region_age17=="rioja"

corr trustindex sentiment_index

 
foreach var of varlist  sentiment_index predictedsimilarity predictedsentiment predictedtrust{
summ `var', d
gen z_`var'=(`var'-r(mean))/r(sd)
}


 
 **Missing values in control variables

 foreach i in siblings industry_father industry_mother sizemunicipality {
 gen `i'_string=string(`i')
 }
*siblings
foreach i in 5 6 7 8 9 10 {
replace siblings_string="4" if siblings_string=="`i'"
}
 
gen missing_moveprovinceofbi = moveprovinceofbi==.
replace moveprovinceofbi=-1 if moveprovinceofbi==.
 
 
 **** level of randomization
 
 
 replace year_lottery=startyear_military-1 if startyear_military!=.
 
egen cluster = group(province_age17 year_lottery)


gen identify_nationcontrol = z_identity if same_region_17_mili==1

qbys region_age17: egen regionalidentity2 = mean(identify_nationcontrol)

egen regionalidentity = std(regionalidentity2)
replace regionalidentity = -regionalidentity


   
  gen nationalisticregion2 = (region_age17=="pais vasco" | region_age17=="navarra" | region_age17=="catalunya" | region_age17=="galicia" |region_age17=="baleares")
  
     gen nationalisticregion = (region_age17=="pais vasco"  | region_age17=="catalunya" | region_age17=="galicia")

	 tab fath_notinlaborforce  
	 tab moth_notinlaborforce 
	 	 
	 
	 foreach var of varlist same_region_birth_17 same_region_birth_mother_17 same_region_birth_father_17   yearofbirth  high_education_father  high_education_mother{
	 gen n_`var' = nationalisticregion2*`var'

	 }
	 
	 gen fath_notinlaborforce_n = nationalisticregion2*fath_notinlaborforce
	 gen moth_notinlaborforce_n = nationalisticregion2*moth_notinlaborforce
	 gen sizemunicipality_n = nationalisticregion2*sizemunicipality
	 
reg z_identity n_* nationalisticregion2 same_region_birth_17 same_region_birth_father_17 same_region_birth_mother_17 fath_notinlaborforce_n  fath_notinlaborforce moth_notinlaborforce_n sizemunicipality_n sizemunicipality moth_notinlaborforce   yearofbirth  high_education_father  high_education_mother if same_region_17_lottery==1, r
 predict predictednaionallism, xb
 	

reg z_identity n_* nationalisticregion2 same_region_birth_17 same_region_birth_father_17 same_region_birth_mother_17        yearofbirth  high_education_father  high_education_mother if same_region_17_lottery==1, r
 predict predictednaionallism_2, xb
 		
replace 	predictednaionallism = predictednaionallism_2 if predictednaionallism==.
	 
gen predictedregionalism2 = - predictednaionallism
egen predictedregionalism = std(predictedregionalism2)
 
replace region_military= region_lottery if region_military==""
gen assigned_nationalistic = (region_military=="pais vasco" | region_military=="navarra" | region_military=="catalunya" | region_military=="galicia" |region_military=="baleares") if region_military!=""
	   
 gen nat_assignednat = assigned_nationalistic*nationalisticregion2
 gen prednat_assignednat = assigned_nationalistic*predictedregionalism2

 
 ****************************************************
********************We clean some variables*********

rename lottery enter_lottery
 
rename year_lottery year_enter_lottery
 
gen other_region_17_mili = same_region_17_lottery==0 if same_region_17_lottery!=.

replace same_region_17_lottery=0 if excedente_de_cupo==1
replace other_region_17_mili=0 if excedente_de_cupo==1
  
gen assigned_nationalistic_other = assigned_nationalistic*other_region_17_mili

 
  gen other_region_17_mili_HET = other_region_17_mili*nationalisticregion
  gen other_region_17_mili_HET2 = other_region_17_mili*regionalidentity
  gen other_region_17_mili_HET3 = other_region_17_mili*nationalisticregion2
  gen other_region_17_mili_HET4 = other_region_17_mili*predictedregionalism

 
  gen same_region_17_mili_HET = same_region_17_lottery*nationalisticregion
  gen same_region_17_mili_HET2 = same_region_17_lottery*regionalidentity
  gen same_region_17_mili_HET3 = same_region_17_lottery*nationalisticregion2
  gen same_region_17_mili_HET4 = same_region_17_lottery*predictedregionalism
 

 
 
**********************Labels**********************

la var exposure_regions "More contact with people from other regions"
la var exposure_socioec "More contact with people with different socioeconomic backgrounds"


la var high_education "High school graduate"
la var high_education_father "High school graduate: father"
la var high_education_mother "High school graduate: mother"
la var small_sizemunicipality "Small municipality (less than 50k)"
la var inc_cts "Net monthly hh income (cts)"


la var yearofbirth "Year of birth"
la var monthofbirth "Month of birth"
la var education "Education"
la var education_father "Education of father"
la var education_mother "Education of mother"
la var siblings "Number of siblings"
la var siblings_string "Number of siblings (string variable)"
la var sizemunicipality "Size of municipality"
la var sizemunicipality_string "Size of municipality (string variable)"
la var income "Net household income"



la var notinlaborforce "Not in labor force"
la var moth_notinlaborforce "Mother: Not in labor force"
la var fath_notinlaborforce "Father: Not in labor force"

la var fath_ind_agr "Father: agriculture"
la var fath_ind_industr "Father: industrial"
la var fath_ind_constr "Father: construction"
la var fath_ind_serv "Father: service"
la var fath_ind_other "Father: other industry"

la var moth_ind_agr "Mother: agriculture"
la var moth_ind_industr "Mother: industrial"
la var moth_ind_constr "Mother: construction"
la var moth_ind_serv "Mother: service"
la var moth_ind_other "Mother: other industry"

/*
la var empl_ft "Full-time employed"
la var empl_pt "Part-time employed"
la var empl_self "Self-employed"
la var empl_ret "Retired"
la var empl_homemaker "Homemaker"
la var empl_children "Taking care of children"
la var empl_student "Student"
la var empl_unempl "Unemployed"
la var empl_disabled "Disabled"
la var empl_other "Employment: Other"


la var occ_managers "Directors and managers"
la var occ_scitech "Scientific and intellectual technicians and professionals"
la var occ_technicians "Technicians; support professionals"
la var occ_accounting "Accounting, administrative and other office employees"
la var occ_cateringsales "Catering, personal, protection and sales service workers"
la var occ_skilledagr "Skilled workers in the agricultural, livestock, forestry and fisheries sector"
la var occ_craftsmen "Craftsmen and skilled workers"
la var occ_plantoperators "Plant and machinery operators and assemblers"
la var occ_elementary "Elementary occupations"
la var occ_military "Military occupations"

la var fath_occ_managers "Father: Directors and managers"
la var fath_occ_scitech "Father: Scientific and intellectual technicians and professionals"
la var fath_occ_technicians "Father: Technicians; support professionals"
la var fath_occ_accounting "Father: Accounting, administrative and other office employees"
la var fath_occ_cateringsales "Father: Catering, personal, protection and sales service workers"
la var fath_occ_skilledagr "Father: Skilled workers in the agricultural, livestock, forestry and fisheries sector"
la var fath_occ_craftsmen "Father: Craftsmen and skilled workers"
la var fath_occ_plantoperators "Father: Plant and machinery operators and assemblers"
la var fath_occ_elementary "Father: Elementary occupations"
la var fath_occ_military "Father: Military occupations"


la var moth_occ_managers "Mother: Directors and managers"
la var moth_occ_scitech "Mother: Scientific and intellectual technicians and professionals"
la var moth_occ_technicians "Mother: Technicians; support professionals"
la var moth_occ_accounting "Mother: Accounting, administrative and other office employees"
la var moth_occ_cateringsales "Mother: Catering, personal, protection and sales service workers"
la var moth_occ_skilledagr "Mother: Skilled workers in the agricultural, livestock, forestry and fisheries sector"
la var moth_occ_craftsmen "Mother: Craftsmen and skilled workers"
la var moth_occ_plantoperators "Mother: Plant and machinery operators and assemblers"
la var moth_occ_elementary "Mother: Elementary occupations"
la var moth_occ_military "Mother: Military occupations"
*/

la var exposure_regions "More contact with people from other regions"
la var exposure_socioec "More contact with people with different socioeconomic backgrounds"


label define educationlabel 1 "No education" 2 "Five years"  3 "Primary education" 4 "Vocational training 1st" 5 "Vocational training 2nd" 6 "High School Graduate" 7 "3-years college degree" 8 "College graduate" 9 "PhD"

label values  education_father educationlabel
label values  education_mother educationlabel
label values  education educationlabel

la var same_province_17_mili "Military service in own province"
la var same_region_17_mili "Military service in own region"

la var same_province_17_lottery "Assigned to own province"
la var same_region_17_mili "Assigned to own region"

label variable province_lottery "Province assigned in the lottery"

la var startyear_military "Year: Start service"
la var same_province_birth_17 "Same province"

rename same_province_birth_father same_province_father
la var same_province_father "Father: Same province"
rename same_province_birth_mother same_province_mother
la var same_province_mother "Mother: Same province"

 


rename same_region_birth_father_17 same_region_father
rename same_region_birth_mother_17 same_region_mother
  
 
 
 la var same_region_birth_17 "Same Region at 17 as at birth"
 la var same_region_father "Same Region as Father's region of birth"
 la var same_region_mother "Same Region as Mothers's region of birth"
 
 
 
la var favor_independence_referendum "In favor of independence referendum"
 
 label define provincelabel  /* 
*/ 1 "A Coruña"/*
*/ 2 "Alava"/*
*/ 3 "Albacete"/*
*/ 4 "Alicante"/*
*/ 5 "Almería"/*
*/ 6 "Asturias"/*
*/ 7 "Avila"/*
*/ 8 "Badajoz"/*
*/ 9 "Barcelona"/*
*/ 10 "Burgos"/*
*/ 11 "Cáceres"/*
*/ 12 "Cádiz"/*
*/ 13 "Cantabria"/*
*/ 14 "Castellón"/*
*/ 15 "Ceuta"/*
*/ 16 "Ciudad Real"/*
*/ 17 "Córdoba"/*
*/ 18 "Cuenca"/*
*/ 19 "Girona"/*
*/ 20 "Granada"/*
*/ 21 "Guadalajara"/*
*/ 22 "Guipúzcoa"/*
*/ 23 "Huelva"/*
*/ 24 "Huesca"/*
*/ 25 "Illes Balears"/*
*/ 26 "Jaén"/*
*/ 27 "La Rioja"/*
*/ 28 "Las Palmas"/*
*/ 29 "León"/*
*/ 30 "Lleida"/*
*/ 31 "Lugo"/*
*/ 32 "Madrid"/*
*/ 33 "Málaga"/*
*/ 34 "Melilla"/*
*/ 35 "Murcia"/*
*/ 36 "Navarra"/*
*/ 37 "Ourense"/*
*/ 38 "Palencia"/*
*/ 39 "Pontevedra"/*
*/ 40 "Salamanca"/*
*/ 41 "Santa Cruz de Tenerife"/*
*/ 42 "Segovia"/*
*/ 43 "Sevilla"/*
*/ 44 "Soria"/*
*/ 45 "Tarragona"/*
*/ 46 "Teruel"/*
*/ 47 "Toledo"/*
*/ 48 "Valencia"/*
*/ 49 "Valladolid"/*
*/ 50 "Vizcaya"/*
*/ 51 "Zamora"/*
*/ 52 "Zaragoza"
 
foreach i in province_birth province_age17 province_residence province_birth_fath province_birth_moth province_military province_lottery  {
 label values `i' provincelabel
 }
 

la var same_region_residence_17 "Same Region as at age 17"
la var nation_sentiment "Identify with Spain"
la var proud_spanish "Proud to be Spanish"
la var sentiment_flag "Positive Emotions Spanish Flag"

label define label_employment 1 "Full-time" 2 "Part-time" 3 "Self-employed" 4 "Retired" 5 "Homemaker" 6 "Childcare" 7 "Student" 8 "Unemployed" 9 "Disabled" 10 "Other"

label values employmentstatus label_employment

label define label_occupation 1 "Directores y gerentes" 2 "Técnicos y profesionales científicos e intelectuales" 3 "Técnicos; profesionales de apoyo" 4 "Empleados contables, administrativos y otros empleados de oficina" 5 "Trabajadores de los servicios de restauración, personales, protección y vendedores" 6 "Trabajadores cualificados en el sector agrícola, ganadero, forestal y pesquero" 7 "Artesanos y trabajadores/​as cualificados/​as de las industrias manufactureras y la construcción, excepto operadores de instalaciones y maquinaria" 8 "Operadores de instalaciones y maquinaria, y montadores" 9 "Ocupaciones elementales" 10 "Ocupaciones militares" 11 "Parados" 12 "Inactivos (ni ocupado, ni parado,o trabajo doméstico no remunerado, etc.)" 13 "No procede (no estaba presente, había fallecido, etc.)" 14 "Otra"

label values occupation label_occupation

label values father_occupation label_occupation
label values mother_occupation label_occupation


la var militaryservice "Military service status"
la var social_sorteado "Social Service"
la var social_sorteado_year "Social Service - Year"
la var social_sorteado_prov "Social Service - Province Code"
la var whynoservice "Exempted from military service"
la var enter_lottery "Participated in the lottery"
la var lottery_excedente "Exempted from military service as a result of lottery"
la var year_enter_lottery "Year lottery"
la var province_birth "Province of birth"
la var moveprovinceofbi "Age when moved away from province of birth"
la var missing_moveprovinceofbi "Missing information for age when moved away from province of birth"
la var province_age17 "Province of residence at age 17"
la var province_residence "Province of current residence"
la var employmentstatus "Employment status"
la var occupation "Occupation"
la var father_occupation "Paternal occupation when individual was 17"
la var mother_occupation "Moternal occupation when individual was 17"
la var province_birth_father "Province of birth, father"
la var province_birth_mother "Province of birth, mother"
la var industry_father "Industry when individual was 17, father"
la var industry_father_string "Industry when individual was 17, father (string)"
la var industry_mother "Industry when individual was 17, mother"
la var industry_mother_string "Industry when individual was 17, mother (string)"
la var startmonth_military "Month: Start service"
la var duration_service "Duration service"
la var unit "Unit during service (Army/Navy/Air Force/Other)"
la var province_military "Province military service"
la var prov_mili_remainder "Province military service, remainder"
la var experience_military "Assessment of experience in military service"

label define label_experience_military 0 "It was a very positive experience" 1 "It was a positive experience" 2 "Neutral" 3 "It was a negative experience" 4 "It was a very negative experience"

label values  experience_military label_experience_military

la var friends_province "Province(s) of origin of friends during service"

la var outside_region "Did you ever live outside your region of birth? (include the period of the obligatory military service, if applicable)?"

la var years_outside "How many years did you live outside your region of birth? (include the period of military service, if applicable)"

la var emancipation  "At which age did you stop living with your parents permanently to move to live on your own? (1= age 18,..., 23=40 or more)"

la var start_empl "At which age did you have your first full-time job?"

la define label_nation_sentiment 4 "Me siento únicamente español/a" 3 "Me siente más español/a que de mi comunidad autónoma de origen" 2 "Me siento tan español/a como de mi comunidad autónoma de origen" 1 "Me siento más de mi comunidad autónoma de origen que español/a" 0 "Me siento únicamente de mi comunidad autónoma de origen"
label values  nation_sentiment label_nation_sentiment

la define label_proud_spanish 4 "Muy orgulloso/a" 3 "Bastante orgulloso/a" 2 "Poco orgulloso/a" 1 "Nada orgulloso/a"
label values  proud_spanish label_proud_spanish

la define label_sentiment_flag 4 "Siento una emoción muy fuerte" 3 "Siento algo de emoción" 2 "Siento muy poca emoción" 1 "No siento nada especial" 0 "Experimento un sentimiento negativo"
label values  sentiment_flag label_sentiment_flag

la var universalism "How much would you share with the person from Spain?"

la var groupishness "How much would you share with the person from your own region?"

la define label_trust 4 "Casi todas (más del 80%)" 3 "Entre el 60 y el 80%" 2 "Entre el 40 y el 60%" 1 "Entre el 40 y el 20%" 0 "Muy pocas (menos del 20%)" 

foreach i in acoruna albacete barcelona bilbao caceres gijon laspalmasgran logrono madrid murcia palmamallorca pamplona santander sevilla valencia valladolid zaragoza {
la var trust_`i' "How many wallets were returned in `i'"
label values trust_`i' label_trust
}

label var selfdiscipline "Me veo como autodisciplinado"
label var openness "Me veo abierto a nuevas experiencias"
label var obeidienceauthority "Es importante obedecer a las autoridades"
label var regionaldistribution "¿Nivel redistribución entre comunidades autónomas demasiado alto/adecuado/bajo?"

label var reintroduce_mili "¿De acuerdo con la reintroducción en España de un servicio militar obligatorio?"
label var becas_seneca "¿Presupuesto becas Seneca debería ser mucho mayor/mayor/igual/menor/mucho menor?"
	
forvalues i=1(1)17 {
label var similarity_new_`i' "¿se parecen al resto de españoles los habitantes de esta comunidad autónoma?"
}
label var sentiments_1 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Andalucía?"
label var sentiments_2 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Aragón?"
label var sentiments_3 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Asturias?"
label var sentiments_4 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Baleares?"
label var sentiments_5 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Canarias?"
label var sentiments_6 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Cantabria?"
label var sentiments_7 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Castilla-León?"
label var sentiments_8 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Castilla La Mancha"
label var sentiments_9 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Cataluña?"
label var sentiments_10 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Extremadura?"
label var sentiments_11 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Galicia?"
label var sentiments_12 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Madrid?"
label var sentiments_13 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Murcia?"
label var sentiments_14 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de Navarra?"
label var sentiments_15 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de la Rioja?"
label var sentiments_16 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes de la Comunidad Valenciana?"
label var sentiments_17 "¿Cuáles son sus sentimientos de simpatía o antipatía hacia los habitantes del País Vasco?"
label var leftright "Ideology: 1=far-left,...,10=far-right"

label var views_regionautonomy "¿Las comunidades autónomas han sido positivas para España?"

label var turnout "¿Votó usted en las últimas elecciones generales?"

label var votingparty "¿A qué partido votó usted en las últimas elecciones generales?"

label var province17_check "Province of residence at age 17 (check)"
label var province_mili_check "Province of military service (check)"
label var yearofbirth_check "Year of birth (check)"

label var lucid "Data collected by lucid"

label var finish "Finished the survey"

label var sample "Source of data"

label var excedente_de_cupo "Exempted from service"

la var region_birth "Region of birth"
la var region_birth_father "Region of birth of father"
la var region_birth_mother "Region of birth of mother"
la var region_age17 "Region of residence age 17"
la var region_residence "Region of current residence"
la var region_lottery "Region assigned in lottery"
la var region_military "Region military service"
 
la var  region_tierra_age17 "Military region of residence at age 17 - Army"
la var region_naval_age17 "Military region of residence at age 17 - Navy"
la var region_aire_age17 "Military region of residence at age 17 - Air Force"

la var  region_tierra_lottery "Military region assigned by lottery - Army"
la var  region_naval_lottery "Military region assigned by lottery - Navy"
la var  region_aire_lottery "Military region assigned by lottery - Air Force"

la var area_age17 "Military region of residence at age 17" 
la var area_lottery "Military region assigned by lottery"

la var same_region_17_lottery "Assigned to own region"
 
 la var employed "Employed"
 
capture  drop whynoservice_4_text

label var endyear_service "End of service: year"
label var end_monthservice "End of service: month"
label var provincemilitaryopen "Province of service: open question"

capture drop timing_friends_provi_firstclick timing_friends_provi_lastclick timing_friends_provi_pagesubmit timing_friends_provi_clickcount

capture drop belongint_regions_1-belongint_regions_6

capture drop q53_firstclick-q53_clickcount

capture drop q54_firstclick q54_lastclick q54_pagesubmit q54_clickcount

drop area_birth-area_military11

drop inconsistent_provincemili-inconsistent_responses

label var age_military "Age at the military service"

label var same_province_residence_17 "Same province of current residence as at age 17"

label var friends_same_province "Any friends during the military service from the province of origin"
label var friends_province_mili "Any friends during the military service from the province of service"
label var number_friends "Number of friends (at most 1 per province)"
label var number_friends_other_provinces "Number of friends from other provinces (at most 1 per province)"
label var number_friends_exclprovmili "Number of friends from other provinces, excluding province of service"

label var unemployed "Unemployed at the time of the survey"

label var conscripts_other_regions "Share of conscripts from other regions"

foreach i in experience_military exposure_regions exposure_socioec universalism groupishness identity nation_sentiment proud_spanish sentiment_flag regionaldistribution views_regionautonomy favor_independence_referendum leftright similarity becas_seneca trustindex trust_acoruna trust_albacete trust_barcelona trust_bilbao trust_caceres trust_gijon trust_laspalmasgran trust_logrono trust_madrid trust_murcia trust_palmamallorca trust_pamplona trust_santander trust_sevilla trust_valencia trust_valladolid trust_zaragoza selfdiscipline openness obeidienceauthority sentiment_index predictedsimilarity predictedsentiment predictedtrust{
label var z_`i' "Variable `i' standardized"
}


foreach i in PSOE PP Vox Ciudadanos Unidas_Podemos ERC_Sobiranistes EAJ_PNV JxCAT Otros_partidos En_blanco  {
label var `i' "Voted for `i' in most recent national election"
}

label var votedregionalist "Voted for ERC_Sobiranistes, EAJ_PNV or JxCAT in most recent national election"

label var identity "Sum of variables nation_sentiment, proud_spanish and sentiment_flag"

label var ever_outside "Has lived outside region of birth"

label var predictedsimilarity "Cultural similarity with region of military service (Predicted)"

foreach i in sentim_andaluces sentim_aragon sentim_astur sentim_baleares sentim_canarios sentim_cantabros sentim_catell_leon sentim_catell_mechegos sentim_catalanes sentim_extremenos sentim_gallegos sentim_madrilenos sentim_murcianos sentim_navarros sentim_rioja sentim_valenc sentim_vascos {
label var `i' "Sympathy towards inhabitants of this region (1- muy mal,..., 11- muy bien"
}

*drop trust_1-trust_17

 label var trust_1 "trust_sevilla"
 label var trust_2 "trust_zaragoza"
 label var trust_3 "trust_gijon"
 label var trust_4 "trust_palmamallorca"
 label var trust_5 "trust_laspalmasgran"
 label var trust_6 "trust_santander"
 label var trust_7 "trust_valladolid"
 label var trust_8 "trust_albacete"
 label var trust_9 "trust_barcelona"
 label var trust_10 "trust_caceres"
 label var trust_11 "trust_acoruna"
 label var trust_12 "trust_madrid"
 label var trust_13 "trust_murcia"
 label var trust_14 "trust_pamplona"
 label var trust_15 "trust_logrono"
 label var trust_16 "trust_valencia"
 label var trust_17 "trust_bilbao"
 
 


label var predictedtrust "Predicted trust towards region of military service"

label var sentiment_index "Sympathy towards inhabitants of other regions"

label var identify_nationcontrol "Variable `identity', for individuals serving in home region"
 label var regionalidentity2 "Average value of `identify_nationcontrol' in the region"
 
 label var nationalisticregion2 "Resident age 17 in Basque Country, Navarre, Catalonia, Galicia or Balearics"

  label var nationalisticregion "Resident age 17 in Basque Country, Catalonia, or Galicia"
 
 
foreach i in same_region_birth_17 same_region_birth_mother_17 same_region_birth_father_17 yearofbirth high_education_father high_education_mother {
label var n_`i' "Interaction between `i' and nationalisticregion2"
}

foreach i in fath_notinlaborforce moth_notinlaborforce  sizemunicipality {
label var `i'_n "Interaction between `i' and nationalisticregion2"
}

label var assigned_nationalistic "Served in Basque Country, Navarre, Catalonia, Galicia or Balearics"
save "$data/final datasets/surveydata_merged_withexcedente.dta", replace

**We drop individuals who were exempted from the military service 
drop if militaryservice==4
keep if excedente_de_cupo!=1


save "$data/final datasets/surveydata_merged_withmissings.dta", replace

foreach var of varlist sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv{
gen mis_`var' = `var'==.
replace `var'= 0 if `var'==.
}

label var prednat_assignednat "Interaction between assigned_nationalistic and nationalisticregion2"

label var other_region_17_mili "Served in a different region"

label var  assigned_nationalistic_other "Interaction between assigned_nationalistic and other_region_17_mili"

   label var other_region_17_mili_HET "Interaction other_region_17_mili*nationalisticregion"
   label var other_region_17_mili_HET2 "Interaction other_region_17_mili*regionalidentity"
   label var other_region_17_mili_HET3 "Interaction other_region_17_mili*nationalisticregion2"
   label var other_region_17_mili_HET4 "Interaction other_region_17_mili*predictedregionalism"

 
   label var same_region_17_mili_HET "Interaction same_region_17_lottery*nationalisticregion"
   label var same_region_17_mili_HET2 "Interaction same_region_17_lottery*regionalidentity"
   label var same_region_17_mili_HET3 "Interaction same_region_17_lottery*nationalisticregion2"
   label var same_region_17_mili_HET4 "Interaction same_region_17_lottery*predictedregionalism"
  
  
save "$data/final datasets/surveydata_merged.dta", replace
