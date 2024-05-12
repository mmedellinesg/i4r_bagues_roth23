
clear

use "$data/final datasets/surveydata_merged.dta", clear
 
 

global controls  i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv

loc experiments " z_nation_sentiment z_proud_spanish z_sentiment_flag z_identity"

gen exposure = 0 if yearofbirth<1970
replace exposure = yearofbirth - 1970

gen other_region_17_mili_exp = other_region_17_mili*exposure

 xi:    areg z_nation_sentiment other_region_17_mili $controls if region_age17=="catalunya", cl(cluster) a(cluster)
 xi:    areg z_proud_spanish other_region_17_mili $controls if region_age17=="catalunya", cl(cluster) a(cluster)
 xi:    areg z_sentiment_flag other_region_17_mili $controls if region_age17=="catalunya", cl(cluster) a(cluster)
 xi:    areg z_identity other_region_17_mili $controls if region_age17=="catalunya", cl(cluster) a(cluster)

  xi:    areg z_nation_sentiment other_region_17_mili_exp other_region_17_mili exposure $controls if region_age17=="catalunya", cl(cluster) a(cluster)
 xi:    areg z_proud_spanish other_region_17_mili_exp other_region_17_mili exposure $controls if region_age17=="catalunya", cl(cluster) a(cluster)
 xi:    areg z_sentiment_flag other_region_17_mili_exp other_region_17_mili exposure $controls if region_age17=="catalunya", cl(cluster) a(cluster)
 xi:    areg z_identity other_region_17_mili_exp other_region_17_mili exposure $controls if region_age17=="catalunya", cl(cluster) a(cluster)


gen bas_catal = (region_age17=="catalunya" | region_age17=="pais vasco")

gen basque_catal_gal = (region_age17=="catalunya" | region_age17=="pais vasco" | region_age17=="galicia")

gen basque_catal_gal_nav = (region_age17=="catalunya" | region_age17=="pais vasco" | region_age17=="galicia" | region_age17=="navarra")

gen basque_catal_gal_nav_bal = (region_age17=="catalunya" | region_age17=="pais vasco" | region_age17=="galicia" | region_age17=="navarra" | region_age17=="baleares")

 gen basque_catal_gal_nav_bal_can = (region_age17=="catalunya" | region_age17=="pais vasco" | region_age17=="galicia" | region_age17=="navarra" | region_age17=="baleares" | region_age17=="canarias")

  gen bas_cat_gal_nav_bal_can_rio = (region_age17=="catalunya" | region_age17=="pais vasco" | region_age17=="galicia" | region_age17=="navarra" | region_age17=="baleares" | region_age17=="canarias"  | region_age17=="rioja")

  
 foreach var of varlist bas_catal basque_catal_gal basque_catal_gal_nav basque_catal_gal_nav_bal basque_catal_gal_nav_bal_can bas_cat_gal_nav_bal_can_rio {
 gen T_`var' = other_region_17_mili*`var'
 } 
 
 
 
preserve

clear all
eststo clear
estimates drop _all

set obs 10
qui gen x = 1
qui gen y = 1

loc columns = 0

foreach choice in `experiments' {

    loc ++columns
    qui eststo col`columns': reg x y

}

restore


/* Statistics */

loc colnum = 1
loc colnames ""




foreach choice in `experiments' {


***OLS


 xi:   qui areg `choice' other_region_17_mili T_basque_catal_gal basque_catal_gal $controls, cl(cluster) a(cluster)
    sigstar other_region_17_mili, prec(3)
    estadd loc thisstat2 = "`r(bstar)'": col`colnum'
    estadd loc thisstat3 = "`r(sestar)'": col`colnum'
	

 sigstar T_basque_catal_gal, prec(3)
    estadd loc thisstat5 = "`r(bstar)'": col`colnum'
    estadd loc thisstat6 = "`r(sestar)'": col`colnum'
		
test 	other_region_17_mili + T_basque_catal_gal = 0
    estadd loc thisstat8 = string(r(p), "%9.3f"):col`colnum'			
	
*basque_catal_gal basque_catal_gal_nav basque_catal_gal_nav_bal basque_catal_gal_nav_bal_can	

 xi:   areg `choice' T_basque_catal_gal_nav other_region_17_mili basque_catal_gal_nav $controls, cl(cluster)  a(cluster)
    sigstar other_region_17_mili, prec(3)
    estadd loc thisstat11 = "`r(bstar)'": col`colnum'
    estadd loc thisstat12 = "`r(sestar)'": col`colnum'
	
	
 sigstar T_basque_catal_gal_nav, prec(3)
    estadd loc thisstat14 = "`r(bstar)'": col`colnum'
    estadd loc thisstat15 = "`r(sestar)'": col`colnum'	
	
test 	other_region_17_mili + T_basque_catal_gal_nav = 0
    estadd loc thisstat17 = string(r(p), "%9.3f"):col`colnum'			
		
	

 xi:   areg `choice' T_basque_catal_gal_nav_bal other_region_17_mili basque_catal_gal_nav_bal $controls, cl(cluster)  a(cluster)
    sigstar other_region_17_mili, prec(3)
    estadd loc thisstat20 = "`r(bstar)'": col`colnum'
    estadd loc thisstat21 = "`r(sestar)'": col`colnum'
	
	
 sigstar T_basque_catal_gal_nav_bal, prec(3)
    estadd loc thisstat23 = "`r(bstar)'": col`colnum'
    estadd loc thisstat24 = "`r(sestar)'": col`colnum'	
	
test 	other_region_17_mili + T_basque_catal_gal_nav_bal = 0
    estadd loc thisstat26 = string(r(p), "%9.3f"):col`colnum'		
	


 xi:   areg `choice' T_basque_catal_gal_nav_bal_can other_region_17_mili basque_catal_gal_nav_bal_can $controls, cl(cluster)  a(cluster)
    sigstar other_region_17_mili, prec(3)
    estadd loc thisstat29 = "`r(bstar)'": col`colnum'
    estadd loc thisstat30 = "`r(sestar)'": col`colnum'
	
	
 sigstar T_basque_catal_gal_nav_bal_can, prec(3)
    estadd loc thisstat32 = "`r(bstar)'": col`colnum'
    estadd loc thisstat33 = "`r(sestar)'": col`colnum'	
	
test 	other_region_17_mili + T_basque_catal_gal_nav_bal_can = 0
    estadd loc thisstat35 = string(r(p), "%9.3f"):col`colnum'			
	
	

 xi:   areg `choice' T_bas_cat_gal_nav_bal_can_rio other_region_17_mili bas_cat_gal_nav_bal_can_rio $controls, cl(cluster)  a(cluster)
    sigstar other_region_17_mili, prec(3)
    estadd loc thisstat38 = "`r(bstar)'": col`colnum'
    estadd loc thisstat39 = "`r(sestar)'": col`colnum'
	
	
 sigstar T_bas_cat_gal_nav_bal_can_rio, prec(3)
    estadd loc thisstat41 = "`r(bstar)'": col`colnum'
    estadd loc thisstat42 = "`r(sestar)'": col`colnum'	
	
test 	other_region_17_mili + T_bas_cat_gal_nav_bal_can_rio = 0
    estadd loc thisstat44 = string(r(p), "%9.3f"):col`colnum'			
	
	
    estadd loc thisstat46 = `e(N)': col`colnum'
    estadd loc thisstat47 = "Y": col`colnum'
    estadd loc thisstat48 = "Y": col`colnum'



	
			
	loc ++colnum
    loc colnames "`colnames' `"`: var la `choice''"'"

}
	
loc rowlabels " "{\bf Panel A}" "Other region (a)" " " " " "Other region $\times$ (b)" "Bas + Nav + Cat" " " "P-value (a+b)" " " "{\bf Panel B}" "Other region (a)" " " " " "Other region $\times$ (b)" "Bas + Cat + Nav + Gal" " " "P-value (a+b)" " " "{\bf Panel C}" "Other region (a)" " " " " "Other region $\times$ (b)" "Bas + Cata + Nav + Gal + Bal" " " "P-value (a+b)" " " "{\bf Panel D}" "Other region (a)" " " " " "Other region $\times$ (b)" "Bas + Cata + Nav + Gal + Bal + Can" " " "P-value (a+b)" " " "{\bf Panel E}" "Other region (a)" " " " " "Other region $\times$ (b)" "Bas + Cata + Nav + Gal + Bal + Can + Rio" " " "P-value (a+b)" " " "Observations" "Year Lottery FE $\times$ Province FE" "Controls" "  
loc rowstats ""

forval i = 1/48 {
    loc rowstats "`rowstats' thisstat`i'"
}


esttab * using "$output/identity_combined_heterorobustness.tex", replace cells(none) booktabs nonotes nomtitles /*nonum*/ compress alignment(c) nogap noobs nobaselevels label stats(`rowstats', labels(`rowlabels')) ///
  mgroups("\shortstack{Attachment\\to\\Spain}" "\shortstack{Proud \\to be\\ Spanish}" "\shortstack{Positive\\emotions\\Spanish flag}" "\shortstack{Identity\\Index}", pattern(1 1 1 1 1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))

	
	
	*sentiment_index similarity_index
	
	eststo clear	


*nation_sentiment proud_spanish sentiment_flag belongint_regions_1 belongint_regions_2 belongint_regions_3 belongint_regions_4 belongint_regions_5 belongint_regions_6



*gen identity=nation_sentiment+proud_spanish+sentiment_flag













