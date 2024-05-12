


*** We add information on provincial gdp and population

**Population

clear
use "$data/provincial data/poblacion 1900-2000.dta"
*source: Instituto Nacional de Estadistica, Cifras oficiales de los Censos respectivos
*available here: https://www.ine.es/dynt3/inebase/index.htm?padre=580&capsel=580
*population available every 5 years - we interpolate in between

expand 5, gen(new)
keep codigo_provincia year poblacion new

sort codigo_provincia  year new poblacion

replace year=year[_n-1]+1 if new==1

gen imputation=poblacion if new==0

* Replicator's note: This procedure artificially assumes that the value of population for the year after the last available in the data is zero. It does not impact the final results because the last relevant year is prior to 1999.
replace imputation=poblacion[_n-1]+(poblacion[_n+4]-poblacion[_n-1])*.2 if new==1 & new[_n-1]==0
replace imputation=poblacion[_n-2]+(poblacion[_n+3]-poblacion[_n-2])*.4 if new==1 & new[_n-2]==0
replace imputation=poblacion[_n-3]+(poblacion[_n+2]-poblacion[_n-3])*.6 if new==1 & new[_n-3]==0
replace imputation=poblacion[_n-4]+(poblacion[_n+1]-poblacion[_n-4])*.8 if new==1 & new[_n-4]==0

keep codigo_provincia  year imputation
rename imputation population_province_age17
rename codigo_provincia province_age17
rename year year_enter_lottery
save "$data/provincial data/poblacion 1900-2000_province_age17.dta", replace
rename population_province_age17 population_province_lottery
rename province_age17 province_lottery
save "$data/provincial data/poblacion 1900-2000_province_lottery.dta", replace


**GPD

clear
use "$data/provincial data/pib provincial 1930-2000.dta"
*Producto interior bruto, a precios básicos (millones de pesetas)
*source: Alcaide, J. (2004): Evolución económica de las regiones y provincias españolas en el siglo XX, ed. Fundación BBVA, Table A.1.43

expand 5, gen(new)
keep codigo_provincia year pib new

sort codigo_provincia  year new pib

replace year=year[_n-1]+1 if new==1

gen imputation=pib if new==0

* Replicator's note: Same comment as above.
replace imputation=pib[_n-1]+(pib[_n+4]-pib[_n-1])*.2 if new==1 & new[_n-1]==0
replace imputation=pib[_n-2]+(pib[_n+3]-pib[_n-2])*.4 if new==1 & new[_n-2]==0
replace imputation=pib[_n-3]+(pib[_n+2]-pib[_n-3])*.6 if new==1 & new[_n-3]==0
replace imputation=pib[_n-4]+(pib[_n+1]-pib[_n-4])*.8 if new==1 & new[_n-4]==0

keep codigo_provincia  year imputation
rename imputation gdp_province_age17
rename codigo_provincia province_age17
rename year year_enter_lottery
save "$data/provincial data/pib provincial 1930-2000_province_age17.dta", replace
rename gdp_province_age17 gdp_province_lottery
rename province_age17 province_lottery
save "$data/provincial data/pib provincial 1930-2000_province_lottery.dta", replace


clear
use "$data/final datasets/surveydata_merged.dta"
merge n:n province_age17 year_enter_lottery   using "$data/provincial data/poblacion 1900-2000_province_age17.dta"
erase "$data/provincial data/poblacion 1900-2000_province_age17.dta"
drop if _merge==2
drop _merge
merge n:n province_lottery year_enter_lottery   using "$data/provincial data/poblacion 1900-2000_province_lottery.dta"
erase "$data/provincial data/poblacion 1900-2000_province_lottery.dta"
drop if _merge==2
drop _merge
merge n:n province_age17 year_enter_lottery using "$data/provincial data/pib provincial 1930-2000_province_age17.dta"
erase "$data/provincial data/pib provincial 1930-2000_province_age17.dta"
drop if _merge==2
drop _merge
merge n:n province_lottery year_enter_lottery using "$data/provincial data/pib provincial 1930-2000_province_lottery.dta"
erase "$data/provincial data/pib provincial 1930-2000_province_lottery.dta"
drop if _merge==2
drop _merge
save "$data/final datasets/surveydata_merged.dta", replace



