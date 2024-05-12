
 
 
clear

use "$data/final datasets/surveydata_reshaped.dta"


  gen assigned_to_region_HET = nationalisticregion*assigned_to_region
  gen assigned_to_region_HET2 = regionalidentity*assigned_to_region
  gen assigned_to_region_HET3 = nationalisticregion2*assigned_to_region
  gen assigned_to_region_HET4 = predictedregionalism*assigned_to_region


loc experiments "z_sentiments z_trust z_index_regionsp"

 

 
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

*xi: areg z_sentiments  assigned_to_region i.group_region_region_17, absorb(id_number) cluster(province_age17)
*xi: areg  z_trust  assigned_to_region i.group_region_region_17, absorb(id_number) cluster(province_age17)
*xi: areg  z_index_regionsp assigned_to_region i.group_region_region_17, absorb(id_number) cluster(province_age17)



xi: areg `choice' assigned_to_region i.group_region_region_17, absorb(id_number) cluster(id_number)
    sigstar assigned_to_region, prec(3)
    estadd loc thisstat2 = "`r(bstar)'": col`colnum'
    estadd loc thisstat3 = "`r(sestar)'": col`colnum'
	

xi: areg `choice' assigned_to_region assigned_to_region_HET3 i.group_region_region_17,absorb(id_number) cluster(id_number)
    sigstar assigned_to_region, prec(3)
    estadd loc thisstat6 = "`r(bstar)'": col`colnum'
    estadd loc thisstat7 = "`r(sestar)'": col`colnum'
	
	 sigstar assigned_to_region_HET3, prec(3)
    estadd loc thisstat9 = "`r(bstar)'": col`colnum'
    estadd loc thisstat10 = "`r(sestar)'": col`colnum'
test 	assigned_to_region_HET3 + assigned_to_region = 0
	
    estadd loc thisstat12 = string(r(p), "%9.3f"):col`colnum'	
	
	
xi: areg `choice' assigned_to_region assigned_to_region_HET4 i.group_region_region_17,absorb(id_number) cluster(id_number)
    sigstar assigned_to_region, prec(3)
    estadd loc thisstat15 = "`r(bstar)'": col`colnum'
    estadd loc thisstat16 = "`r(sestar)'": col`colnum'
	
	 sigstar assigned_to_region_HET4, prec(3)
    estadd loc thisstat18 = "`r(bstar)'": col`colnum'
    estadd loc thisstat19 = "`r(sestar)'": col`colnum'
 	

    estadd loc thisstat21 = `e(N)': col`colnum'
 estadd loc thisstat22 = "Y": col`colnum'
    estadd loc thisstat23 = "Y": col`colnum'

	
			
	loc ++colnum
    loc colnames "`colnames' `"`: var la `choice''"'"

}
	
loc rowlabels " "{\bf Panel A: Main}" "Assigned to region" " " " " "{\bf Panel B: Binary}" "Assigned to region (a)" " " " " "Assigned to region $\times$ (b)" "Peripheral Nationalism" " " "P-value (a+b)" " " "{\bf Panel C: Continuous}" "Assigned to region (a)" " " " " "Assigned to region $\times$ (b)" "Low identification with Spain" " " "Observations" "Individual FE" "Region $\times$ Question Region FE" "  
loc rowstats ""

forval i = 1/23 {
    loc rowstats "`rowstats' thisstat`i'"
}


esttab * using "$output/table_3.tex", replace cells(none) booktabs nonotes nomtitles /*nonum*/ compress alignment(c) nogap noobs nobaselevels label stats(`rowstats', labels(`rowlabels')) ///
  mgroups("\shortstack{Sentiment (z)}" "\shortstack{Trustworthiness (z)}" "\shortstack{Index (z)}" "\shortstack{Identity\\Index}", pattern(1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))

	
	

	eststo clear	














