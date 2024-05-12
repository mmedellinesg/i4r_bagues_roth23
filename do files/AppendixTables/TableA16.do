
clear


use "$data/final datasets/surveydata_merged_withexcedente.dta", clear

 
keep if enter_lottery==1
 
 
foreach var of varlist sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv{
gen mis_`var' = `var'==.
replace `var'= 0 if `var'==.
}

 gen mili = excedente_de_cupo==0 if excedente_de_cupo!=.

 gen mili_nat = mili*nationalisticregion2
 
  xi: areg z_identity mili  $controls , cl(cluster) a(cluster)

   xi:  areg z_identity same_region_17_lottery other_region_17_mili $controls, cl(cluster) a(cluster)
   xi:  areg z_nation_sentiment same_region_17_lottery other_region_17_mili $controls, cl(cluster) a(cluster)
   xi:  areg z_proud_spanish same_region_17_lottery other_region_17_mili $controls, cl(cluster) a(cluster)

   *z_nation_sentiment z_proud_spanish z_sentiment_flag
 
global controls i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv

 xi: areg z_identity same_region_17_lottery other_region_17_mili $controls  if nationalisticregion2==1, cl(cluster) a(cluster)

  xi: areg z_identity same_region_17_lottery other_region_17_mili $controls  if nationalisticregion2!=1, cl(cluster) a(cluster)


 xi: areg z_identity same_region_17_lottery other_region_17_mili $controls , cl(cluster) a(cluster)
 xi: areg z_identity excedente_de_cupo $controls , cl(cluster) a(cluster)

   
 xi: areg z_identity same_region_17_lottery other_region_17_mili $controls if nationalisticregion2==1, cl(cluster) a(cluster)
  xi: areg z_identity same_region_17_lottery other_region_17_mili $controls if nationalisticregion2!=1, cl(cluster) a(cluster)

  xi: areg z_identity excedente_de_cupo $controls if nationalisticregion2==1, cl(cluster) a(cluster)
  xi: areg z_identity excedente_de_cupo $controls if nationalisticregion2!=1, cl(cluster) a(cluster)

  

  xi: areg z_nation_sentiment same_region_17_lottery other_region_17_mili $controls if nationalisticregion2==1, cl(cluster) a(cluster)
  
  
  xi: areg z_proud_spanish same_region_17_lottery other_region_17_mili $controls if nationalisticregion2==1, cl(cluster) a(cluster)
  
   xi: areg z_sentiment_flag same_region_17_lottery other_region_17_mili $controls if nationalisticregion2==1, cl(cluster) a(cluster)
   
   xi: areg z_identity same_region_17_lottery other_region_17_mili $controls if nationalisticregion2==1, cl(cluster) a(cluster)

  
loc experiments "ever_outside z_nation_sentiment z_proud_spanish z_sentiment_flag z_identity"

   
  
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

 xi:  areg `choice' mili $controls, cl(cluster) a(cluster)
  sigstar mili, prec(3)
    estadd loc thisstat2 = "`r(bstar)'": col`colnum'
    estadd loc thisstat3 = "`r(sestar)'": col`colnum'

 xi:  areg `choice' same_region_17_lottery other_region_17_mili $controls, cl(cluster) a(cluster)
    sigstar other_region_17_mili, prec(3)
    estadd loc thisstat5 = "`r(bstar)'": col`colnum'
    estadd loc thisstat6 = "`r(sestar)'": col`colnum'
	
 sigstar same_region_17_lottery, prec(3)
    estadd loc thisstat8 = "`r(bstar)'": col`colnum'
    estadd loc thisstat9 = "`r(sestar)'": col`colnum'
 	
		
	
 xi:  areg `choice' same_region_17_lottery other_region_17_mili other_region_17_mili_HET3 same_region_17_mili_HET3 nationalisticregion2 $controls, cl(cluster) a(cluster)
  sigstar other_region_17_mili, prec(3)
    estadd loc thisstat13 = "`r(bstar)'": col`colnum'
    estadd loc thisstat14 = "`r(sestar)'": col`colnum'
	
 sigstar other_region_17_mili_HET3, prec(3)
    estadd loc thisstat16 = "`r(bstar)'": col`colnum'
    estadd loc thisstat17 = "`r(sestar)'": col`colnum'
				
		
sigstar same_region_17_lottery, prec(3)
    estadd loc thisstat19 = "`r(bstar)'": col`colnum'
    estadd loc thisstat20 = "`r(sestar)'": col`colnum'
	
 sigstar same_region_17_mili_HET3, prec(3)
    estadd loc thisstat22 = "`r(bstar)'": col`colnum'
    estadd loc thisstat23 = "`r(sestar)'": col`colnum'
		
		
test 	other_region_17_mili + other_region_17_mili_HET3 = 0
    estadd loc thisstat25 = string(r(p), "%9.3f"):col`colnum'			
	
test 	same_region_17_lottery + same_region_17_mili_HET3 = 0
    estadd loc thisstat26 = string(r(p), "%9.3f"):col`colnum'			
		
	
    estadd loc thisstat27 = `e(N)': col`colnum'
 estadd loc thisstat28 = "Y": col`colnum'
    estadd loc thisstat29 = "Y": col`colnum'

	
			
	loc ++colnum
    loc colnames "`colnames' `"`: var la `choice''"'"

}
	
loc rowlabels " "{\bf Panel A}" "Military service" " " "{\bf Panel B}" "Other Region" " " " " "Same Region" " " " " "{\bf Panel C}" " " "Other Region (a)" " " " " "Other Region $\times$ (b)" "Peripheral Nationalism" " " "Same Region (c)" " " " " "Same Region $\times$ (d)" "Peripheral Nationalism" " " "P-value (a+b)" "P-value (c+d)" "Observations" "Cohort FE" "Province FE" "Controls" "  
loc rowstats ""

forval i = 1/29 {
    loc rowstats "`rowstats' thisstat`i'"
}


esttab * using "$output/identity_same_other.tex", replace cells(none) booktabs nonotes nomtitles /*nonum*/ compress alignment(c) nogap noobs nobaselevels label stats(`rowstats', labels(`rowlabels')) ///
  mgroups("\shortstack{Any year\\outside of\\province}" "\shortstack{Attachment\\to\\Spain}" "\shortstack{Proud \\to be\\ Spanish}" "\shortstack{Positive\\emotions\\Spanish flag}" "\shortstack{Identity\\Index}", pattern(1 1 1 1 1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))

	
	
	*sentiment_index similarity_index
	
	eststo clear	


*nation_sentiment proud_spanish sentiment_flag belongint_regions_1 belongint_regions_2 belongint_regions_3 belongint_regions_4 belongint_regions_5 belongint_regions_6



*gen identity=nation_sentiment+proud_spanish+sentiment_flag













