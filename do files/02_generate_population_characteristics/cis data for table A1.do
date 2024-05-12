
*******We prepare the dataset used in table A1, using data from a survey conducted by the Spanish Sociological Center (CIS) 


clear 
insheet using "$data/Lucidsurvey/December Pilot/provincia-codigo_provincia.txt"
keep codigo_provincia region
rename codigo_provincia province
rename region region_string
save "$data/Lucidsurvey/December Pilot/codigo_provincia-region.dta", replace


**
*This file includes information from Study n° 3110 of the Centro de Investigaciones Sociológicas (CIS):
*the original data is available here: https://analisis.cis.es/formulario.jsp?dwld=/Microdatos/MD3110.zip

clear
import spss using "$data/surveys cis/3110.sav"
**we add name of region_`i
rename PROV province
merge n:1 province using "$data/Lucidsurvey/December Pilot/codigo_provincia-region.dta"
drop if _==2
drop _



**sample selection
*Spaniards
rename P0 citizenship
drop if citizenship==2
*who did the compulsory military service
keep if P53==2
*men
rename P51 male
recode male (2=0) (-99=.)
keep if male==1
*born between 1929 and 1974
rename P52 age
gen yearofbirth = 2015 - age
drop if yearofbirth>=1974
drop if yearofbirth<=1929

**we deal with missing values

rename P62 household_income
rename P63 income
foreach i in  household_income income {
replace `i'=. if `i'==98 | `i'==99 | `i'==-99
}

rename P3 proud_spanish
rename P2 nation_sentiment
rename P4 flag
rename P5 anthem
foreach i in proud_spanish nation_sentiment flag anthem  {
replace `i'=. if `i'==8 | `i'==9 | `i'==-99
}


recode flag (1=4) (2=3) (5=2) (3=1) (4=0) , gen(sentiment_flag)
la define label_sentiment_flag 4 "Siento una emoción muy fuerte" 3 "Siento algo de emoción" 2 "Siento muy poca emoción" 1 "No siento nada especial" 0 "Experimento un sentimiento negativo"
label values  sentiment_flag label_sentiment_flag


replace nation_sentiment = -  nation_sentiment + 5
la define label_nation_sentiment 4 "Me siento únicamente español/a" 3 "Me siente más español/a que de mi comunidad autónoma de origen" 2 "Me siento tan español/a como de mi comunidad autónoma de origen" 1 "Me siento más de mi comunidad autónoma de origen que español/a" 0 "Me siento únicamente de mi comunidad autónoma de origen"
label values  nation_sentiment label_nation_sentiment


replace proud_spanish = - proud_spanish + 5
la define label_proud_spanish 4 "Muy orgulloso/a" 3 "Bastante orgulloso/a" 2 "Poco orgulloso/a" 1 "Nada orgulloso/a"
label values  proud_spanish label_proud_spanish




 
rename P49 leftright
replace leftright=. if (leftright==99 | leftright==98)

replace ESTUDIOS=. if ESTUDIOS==9
gen high_education = ESTUDIOS>=3 if ESTUDIOS!=.

gen college= ESTUDIOS>=6 if ESTUDIOS!=.


gen cis = 1


rename P58 employmentstatus_cis

/*
G.2	SituaciÛn laboral de la persona entrevistada
** VALORES:
1:Trabaja
2:Jubilado/a o pensionista (anteriormente ha trabajado)
3:Pensionista (anteriormente no ha trabajado)
4:Parado/a y ha trabajado antes
5:Parado/a y busca su primer empleo
6:Estudiante
7:Trabajo domÈstico no remunerado
8:Otra situaciÛn
9:N.C.
*/


gen notinlaborforce = (employmentstatus==2 | employmentstatus==3  | employmentstatus==6   | employmentstatus==7   | employmentstatus==8) if employmentstatus!=.

gen employed=.
replace employed=0 if employmentstatus_cis!=.
replace employed=1 if employmentstatus_cis==1

gen unemployed=.
replace unemployed=0 if notinlaborforce==0
replace unemployed=1 if employmentstatus==4  | employmentstatus==5

gen inc_cts = . if income==1
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

*in 2020 euros (https://datos.bancomundial.org/indicator/NY.GDP.DEFL.ZS?end=2020&locations=ES&start=2015)
replace inc_cts=inc_cts*1.05385

rename province province_residence

la var college "College Degree"
la var employed "Employed"
la var high_education "High School Graduate"
la var nation_sentiment "Identify with Spain"
la var proud_spanish "Proud to be Spanish"
la var sentiment_flag "Positive Emotions Spanish Flag"
la var notinlaborforce "Not in labor force"
label var unemployed "Unemployed at the time of the survey"
la var inc_cts "Net monthly hh income (cts)"


keep  inc_cts notinlaborforce employed unemployed high_education college proud_spanish sentiment_flag yearofbirth nation_sentiment cis leftright  region_string province 

save "$data/final datasets/cis data for table A1.dta", replace

