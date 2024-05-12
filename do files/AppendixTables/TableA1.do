
clear

*first we prepare the dataset with population characteristics from CIS

do "$do/02_generate_population_characteristics/cis data for table A1.do"

*now we combine our survey data with the CIS data 
use "$data/final datasets/surveydata_merged_withmissings.dta", clear

gen cis =0

gen college= (education>=8 & education<=9) if education!=.
la var college "College graduate"
la var employed "Employed"

append using "$data/final datasets/cis data for table A1.dta"
	label var inc_cts "Income"
	global list_variables " high_education college notinlaborforce employed inc_cts nation_sentiment proud_spanish sentiment_flag leftright"

	
	reg yearofbirth cis, cluster(province_residence)
est store yearofbirth
	
	foreach i in $list_variables  {
	reghdfe `i' cis, absorb(yearofbirth) cluster(province_residence)
	est store `i'
	}

	estout yearofbirth $list_variables , /*
	*/ cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) p(fmt(%9.3f))) stats(N N_rc, /*
	*/ fmt(%9.0g %9.0g)  labels(N "Right-censored obs."))legend /*
	*/ collabels(, none) posthead("") prefoot("") /*
	*/ postfoot("") varwidth(10) modelwidth(7) delimiter("")  style(fixed) /*
	*/ starlevels(* 0.10 ** 0.05 *** 0.01)

*************************************************************************************




la var leftright "Ideology Scale"
la var same_region_birth_17 "Same Region at age 17"

tempfile main
save `main', replace

clear all
eststo clear
estimates drop _all

loc columns = 8

set obs 10
gen x = 1
gen y = 1

forval i = 1/`columns' {
	eststo col`i': reg x y
} 

loc count = 1

loc statnames ""
loc varlabels ""

/* Custom fill cells */

use `main', clear



foreach yvar of varlist yearofbirth high_education college notinlaborforce employed inc_cts nation_sentiment proud_spanish sentiment_flag leftright siblings  small_sizemunicipality same_region_17_mili startyear_military same_region_birth_17 high_education_father same_region_father high_education_mother   same_region_mother     {
 
tab leftright

 
 *loc covars "     "


 
 
	qui sum `yvar' if cis==0, d

	cap: estadd loc thisstat`count' = string(`r(mean)', "%9.2f"): col1
	cap: estadd loc thisstat`count' = string(`r(sd)', "%9.2f"): col2
	cap: estadd loc thisstat`count' = string(`r(p50)', "%9.0f"): col3
	cap: estadd loc thisstat`count' = string(`r(min)', "%9.0f"): col4
	cap: estadd loc thisstat`count' = string(`r(max)', "%9.0f"): col5
	cap: estadd loc thisstat`count' = `r(N)': col6

	qui sum `yvar' if cis==1, d
	cap: estadd loc thisstat`count' = string(`r(mean)', "%9.2f"): col7
	reghdfe `yvar' cis, absorb(yearofbirth) cluster(province_residence)
	            qui test cis = 0
		          cap:   estadd loc `yvar'_mean = string(r(p), "%9.3f"): col8
		
         *   estadd loc thisstat`count' = string(r(p), "%9.3f"): col8

	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'
	loc varlabels "`varlabels' "`thisvarlabel'" "
	loc statnames "`statnames' thisstat`count'"
	loc count = `count' + 1
	

}

/* Footnotes */

loc prehead "\begin{tabular}{l*{`columns'}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular}"

loc footnote "This table presents basic summary statistics for each row variable."

esttab col* using "$output/sumstats_withcis.tex", booktabs cells(none) nonum nogap mtitle("Mean" "SD" "Median" "Min." "Max." "Obs." "Mean: CIS (2015 wave)" "P-value") stats(`statnames', labels(`varlabels')) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") compress wrap replace

eststo clear

