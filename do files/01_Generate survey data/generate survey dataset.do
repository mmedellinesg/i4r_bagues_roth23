	

clear

*we download data from the main surveys conducted by dynata and lucid
do "$do/01_Generate survey data/1.clean_dynata_and_lucid.do"
*creates "data/mainsurveys_clean.dta" 

*we download data from the pilot survey
do "$do/01_Generate survey data/2.clean_pilot.do"
*creates "data/Lucidsurvey/December Pilot/surveydatafinal.dta"

**We merge the survey datasets and we clean them ******************
 
do "$do/01_Generate survey data/3.clean_merged_file.do"

*creates:
*"$data/final datasets/surveydata_merged_withexcedente.dta"
*"$data/final datasets/surveydata_merged_withmissings.dta"
*"$data/final datasets/surveydata_merged.dta"

**We add information on province population and gdp
do "$do/01_Generate survey data/4.adding provincial population and gdp.do"
*adds variables population_province_age17 population_province_lottery gdp_province_age17 gdp_province_lottery

*********We create a reshaped file
 
do "$do/01_Generate survey data/5.create reshaped file.do"
*creates "$data/Dynata survey/surveydata_reshaped.dta"


