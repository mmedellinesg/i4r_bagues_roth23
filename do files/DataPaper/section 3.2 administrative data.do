	
clear

*Spanish Census data

use "$data/census/census.dta", clear

replace age=. if age==999


gen mobile_region=.
foreach i in 1991 2011 {
replace mobile_region=1 if region_birth!="" & region_`i'!="" & region_birth!=region_`i' & year==`i' 
replace mobile_region=0 if region_birth!="" & region_`i'!="" & region_birth==region_`i' & year==`i'
}

label var mobile_region "Lives in region different from region of birth"

table year if age>=25 & age<=55  [pweight=factor], c(mean mobile_region count mobile_region)




