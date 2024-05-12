

*********WE USE DATA FROM CENSUS 1991 (2%SAMPLE) AND 2011

*census microdata is available at the Spanish Statistics Institute (INE) *https://ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736176992&menu=resultados&idp=1254735572981#!tabs-1254736195714

***reading census data 1991

**1991 - 2% version, it has information on month of birth

	clear
	infix tipo 1 province_code_1991 2-3 municipio 4-6 female 8 /*
	*/ month_birth 9-10 year_birth 11-13 estado_civil 20 lugar_nacimiento 21 /*
	*/ province_code_birth 25-26 lugar_residencia 27 province_code_1990 31-32 lugar_residencia_1986 33 province_code_1986 37-38 /*
	*/ lugar_residencia_1981 39 province_code_1981 37-38 education_curso 53-54 education 55-56  /*
	*/ actividad 60-61 profesion 66-67 age 71-73 factor 93-99 /*
	*/ using "$data/census/1991_2%/MUES02.PERSONAS.TXT"

replace year_birth=101 if year_birth==999
replace year_birth=1992-year_birth
gen year=1991
recode female (1=0) (6=1)

gen mili=0
replace mili=1 if actividad==1
replace province_code_birth=province_code_1991 if lugar_nacimiento==1   |  lugar_nacimiento==2  |  lugar_nacimiento==3
replace province_code_1990=province_code_1991 if lugar_residencia==1 | lugar_residencia==2 | lugar_residencia==3
replace province_code_1986=province_code_1991 if lugar_residencia_1986==1 | lugar_residencia_1986==2 | lugar_residencia_1986==3
replace province_code_1981=province_code_1991 if lugar_residencia_1981==1 | lugar_residencia_1981==2 | lugar_residencia_1981==3


gen employed=.
replace employed=0 if actividad!=.
replace employed=1 if actividad==2

gen unemployed=.
replace unemployed=0 if actividad!=.
replace unemployed=1 if actividad==3 | actividad==4

gen married=0
replace married=1 if estado_civil==2
save "$data/census/1991_2%/census1991.dta", replace


***reading census data 2011

*I will first extract the province of birth of the partner
clear
infix province_code_2011 1-2 municipality 3-5 hueco 6-15 order 16-19 factor 20-33 month_birth 34-35 year_birth 36-39 age 40-42 female 43 province_code_birth 50-51 size_municipality 52-54 /*
*/ year_arrival_region 63-66 province_code_previous 74-75 province_code_2001 92-93 /*
*/ estado_civil 111 education 113-114 hijos_mujer 121-122 RELA 123 order_partner 190-191 str tipoper  194 EDADPAD 238-239 ESTUPAD 245 origen_pareja 260/*
*/ estado_civil_pareja 262 tipo_nucleo 266 hijos_hogar 269-270 tipo_pareja 275-276 tipo_pareja_mismo_sexo 277-278 age_difference 279-280 /*
*/using "$data/census/2011/MicrodatosCP_NV_per_nacional_3VAR.txt"

keep province_code_2011 municipality hueco province_code_birth order_partner age
rename order_partner order
rename age age_partner
rename province_code_birth province_code_birth_partner
keep if order!=.
save "$data/census/2011/partner province.dta", replace


*and I will need also information on region codes
clear 
insheet using "$data/Lucidsurvey/December Pilot/provincia-codigo_provincia.txt"
keep codigo_provincia region
rename codigo_provincia province_code_birth
rename region region_birth
save "$data/Lucidsurvey/December Pilot/codigo_provincia-region_birth.dta", replace
rename province_code_birth province_code_birth_partner
rename region_birth region_birth_partner
save "$data/Lucidsurvey/December Pilot/codigo_provincia-region_partner.dta", replace
rename province_code_birth_partner province_code_2011
rename region_birth_partner region
save "$data/Lucidsurvey/December Pilot/codigo_provincia-region.dta", replace



clear
infix province_code_2011 1-2 municipality 3-5 hueco 6-15 order 16-19 factor 20-33 month_birth 34-35 year_birth 36-39 age 40-42 female 43 province_code_birth 50-51 size_municipality 52-54 /*
*/ year_arrival_region 63-66 province_code_previous 74-75 province_code_2001 92-93 /*
*/ estado_civil 111 education 113-114 hijos_mujer 121-122 RELA 123 order_partner 190-191 str tipoper  194 EDADPAD 238-239 ESTUPAD 245 origen_pareja 260/*
*/ estado_civil_pareja 262 tipo_nucleo 266 hijos_hogar 269-270 tipo_pareja 275-276 tipo_pareja_mismo_sexo 277-278 age_difference 279-280 /*
*/using "$data/census/2011/MicrodatosCP_NV_per_nacional_3VAR.txt"
*information on partner
merge 1:1 province_code_2011 municipality hueco order using "$data/census/2011/partner province.dta"
erase "$data/census/2011/partner province.dta"
drop _
*region codes
merge n:1 province_code_birth using "$data/Lucidsurvey/December Pilot/codigo_provincia-region_birth.dta"
erase "$data/Lucidsurvey/December Pilot/codigo_provincia-region_birth.dta"
drop _
merge n:1 province_code_birth_partner using "$data/Lucidsurvey/December Pilot/codigo_provincia-region_partner.dta"
erase "$data/Lucidsurvey/December Pilot/codigo_provincia-region_partner.dta"
drop _
merge n:1 province_code_2011 using "$data/Lucidsurvey/December Pilot/codigo_provincia-region.dta"
erase "$data/Lucidsurvey/December Pilot/codigo_provincia-region.dta"
drop _

gen unemployed=.
replace unemployed=0 if RELA==1
replace unemployed=1 if RELA==2 | RELA==3
*invalidez permanente, jubilado, otra situacion
replace unemployed=. if RELA==4 | RELA==5 | RELA==6 

gen employed=.
replace employed=0 if RELA!=.
replace employed=1 if RELA==1

/*
tipoper 
C si vive con su cónyuge
P si es padre y no vive con su cónyuge
M si es madre y no vive con su cónyuge
H si es hijo
blanco si no pertenece a ningún núcleo"
estado civil
"1 Soltero
2 Casado
3 Viudo
4 Separado
5 Divorciado"
*/ 

recode female (1=0) (6=1)
gen married=0
replace married=1 if estado_civil==2
recode age_difference (8=.)

gen cohabitation=.
replace cohabitation=1 if tipoper=="C"
replace cohabitation=0 if tipoper!="C"

gen married_or_cohabiting=0
replace married_or_cohabiting=1 if married==1 | cohabitation==1

gen ever_married=.
replace ever_married=0 if estado_civil==1
replace ever_married=1 if estado_civil>=2 & estado_civil<=5

gen foreign_partner=.
replace foreign_partner=0 if origen_pareja==2
replace foreign_partner=1 if origen_pareja>=3 & origen_pareja<=9


*We homogeneize estudios for 2001 and 2011
/*
2001
Nivel de estudios 	ESREAL	
	01	Analfabetos
	02	Sin estudios
	03	Primer grado
		Segundo grado
	04	  ESO, EGB, Bachillerato Elemental
	05	  Bachillerato Superior
	06	  FP Grado Medio
	07	  FP Grado Superior
		Tercer grado
	08	  Diplomatura
	09	  Licenciatura
	10	  Doctorado
2011
1 No sabe leer o escribir
2 Sabe leer y escribir pero fue menos de 5 años a la escuela
3 Fue a la escuela 5 o más años pero no llegó al último curso de ESO, EGB o Bachiller Elemental
4 Llegó al último curso de ESO, EGB o Bachiller Elemental o tiene el Certificado de Escolaridad o de Estudios Primarios

5 Bachiller (LOE, LOGSE), BUP, Bachiller Superior, COU, PREU
6 FP grado medio, FP I, Oficialía industrial o equivalente, Grado Medio de Música y Danza, Certificados de Escuelas Oficiales de Idiomas
7 FP grado superior, FP II, Maestría industrial o equivalente
8 Diplomatura universitaria, Arquitectura Técnica, Ingeniería Técnica o equivalente
9 Grado Universitario o equivalente
10 Licenciatura, Arquitectura, Ingeniería o equivalente
11 Máster oficial universitario (a partir de 2006), Especialidades Médicas o análogos
12 Doctorado
blanco, si tiene menos de 16 años
*/

recode education (10=9) (11=9) (12=10)


gen year=2011
save "$data/census/2011/census 2011.dta", replace

***We join all the datasets

use "$data/census/2011/census 2011.dta"
erase "$data/census/2011/census 2011.dta"
append using  "$data/census/1991_2%/census1991.dta"
erase "$data/census/1991_2%/census1991.dta"

gen active=0
replace active=1 if employed==1 | unemployed==1 | mili==1

foreach i in 1991 2011  {
gen migrated_`i'=.
replace migrated_`i'=0 if province_code_`i'==province_code_birth & province_code_birth!=. & province_code_`i'!=.
replace migrated_`i'=1 if province_code_`i'!=province_code_birth & province_code_birth!=. & province_code_`i'!=.
}




replace factor=50 if year==1991


gen partner=.
replace partner=0 if year==2011
replace partner=1 if province_code_birth_partner!=. | age_partner!=.

gen partner_other_province=.
replace partner_other_province=0 if province_code_birth==province_code_birth_partner & province_code_birth!=.
replace partner_other_province=1 if province_code_birth!=province_code_birth_partner & province_code_birth!=. & province_code_birth_partner!=.


/*
gen migrated_1986_1991=.
replace migrated_1986_1991=0 if province_code_1986==province_code_1991 & province_code_1986!=. & province_code_1991!=.
replace migrated_1986_1991=1 if province_code_1986!=province_code_1991 & province_code_1986!=. & province_code_1991!=.
*/

gen migrated_other_province=.
replace migrated_other_province=0 if (year==1991 & migrated_1991==0) | (year==2011 & migrated_2011==0)
replace migrated_other_province=1 if (year==1991 & migrated_1991==1) | (year==2011 & migrated_2011==1)



keep year education year_birth month_birth  province_code_birth female province_code_* factor age employed* unemployed active mili partner partner_other_province   migrated_other_province
save "$data/census/census.dta", replace



**we introduce regions

foreach i in birth birth_partner previous 1981 1986 1990 1991 2001 2011 {
clear 
insheet using "$data/Lucidsurvey/December Pilot/provincia-codigo_provincia.txt"
keep codigo_provincia region
rename codigo_provincia province_code_`i'
rename region region_`i'
save "$data/Lucidsurvey/December Pilot/codigo_provincia-region_`i'.dta", replace
}


clear
use "$data/census/census.dta"
foreach i in  birth birth_partner previous 1981 1986 1990 1991 2001 2011 {
merge n:1 province_code_`i' using "$data/Lucidsurvey/December Pilot/codigo_provincia-region_`i'.dta", update
drop if _==2
drop _
}

gen migrated_other_region=.
replace migrated_other_region=0 if (year==1991 & region_1991==region_birth) | (year==2001 & region_2001==region_birth) | (year==2011 & region_2011==region_birth)  & region_birth!=""
replace migrated_other_region=1 if (year==1991 & region_1991!=region_birth) | (year==2001 & region_2001!=region_birth) | (year==2011 & region_2011!=region_birth)  & region_birth!=""

gen partner_other_region=.
replace partner_other_region=0 if region_birth==region_birth_partner & region_birth!=""
replace partner_other_region=1 if region_birth!=region_birth_partner & region_birth!="" & region_birth_partner!=""

gen nationalistic_region=0
replace nationalistic_region=1 if region_birth=="baleares" |  region_birth=="catalunya" |  region_birth=="pais vasco" |  region_birth=="navarra" |  region_birth=="galicia" 



save "$data/census/census.dta", replace
