
clear


use "$data/final datasets/surveydata_merged.dta", clear
 
 gen ft_employed =   employmentstatus ==1 if employmentstatus!=.
  gen pt_employed =   employmentstatus ==2  if employmentstatus!=.

  gen other_region_residence_17 = same_region_residence_17==0

  sum other_region_residence_17 if other_region_17_mili==0
    sum other_region_residence_17 if other_region_17_mili==1

  gen lninc = ln(1+inc_cts)
  
  gen inlaborforce = notinlaborforce == 0 
  
global controls i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv
 
loc experiments "other_region_residence_17 years_outside emancipation z_openness  z_exposure_socioec z_experience_military lninc inlaborforce"



 xi: areg other_region_residence_17 other_region_17_mili $controls if yearofbirth>=1968 & yearofbirth<=1973, cl(cluster) a(cluster)


  xi:    areg other_region_residence_17 other_region_17_mili $controls, cl(cluster) a(cluster)

 
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

 xi:    areg `choice' other_region_17_mili $controls, cl(cluster) a(cluster)
    sigstar other_region_17_mili, prec(3)
    estadd loc thisstat2 = "`r(bstar)'": col`colnum'
    estadd loc thisstat3 = "`r(sestar)'": col`colnum'
	


 xi:   areg `choice' other_region_17_mili_HET3 other_region_17_mili nationalisticregion2 $controls, cl(cluster) a(cluster)
    sigstar other_region_17_mili, prec(3)
    estadd loc thisstat6 = "`r(bstar)'": col`colnum'
    estadd loc thisstat7 = "`r(sestar)'": col`colnum'
	
	
 sigstar other_region_17_mili_HET3, prec(3)
    estadd loc thisstat9 = "`r(bstar)'": col`colnum'
    estadd loc thisstat10 = "`r(sestar)'": col`colnum'
		
test 	other_region_17_mili + other_region_17_mili_HET3 = 0
    estadd loc thisstat12 = string(r(p), "%9.3f"):col`colnum'			
	
	

 xi:   areg `choice' other_region_17_mili_HET4 other_region_17_mili predictedregionalism $controls, cl(cluster)  a(cluster)
    sigstar other_region_17_mili, prec(3)
    estadd loc thisstat15 = "`r(bstar)'": col`colnum'
    estadd loc thisstat16 = "`r(sestar)'": col`colnum'
	
	
 sigstar other_region_17_mili_HET4, prec(3)
    estadd loc thisstat18 = "`r(bstar)'": col`colnum'
    estadd loc thisstat19 = "`r(sestar)'": col`colnum'	
	
	
    estadd loc thisstat21 = `e(N)': col`colnum'
    estadd loc thisstat22 = "Y": col`colnum'
    estadd loc thisstat23 = "Y": col`colnum'


	
			
	loc ++colnum
    loc colnames "`colnames' `"`: var la `choice''"'"

}
	
loc rowlabels " "{\bf Panel A: Main}" "Other region" " " " " "{\bf Panel B: Binary}" "Other region (a)" " " " " "Other region $\times$ (b)" "Peripheral Nationalism" " " "P-value (a+b)" " " "{\bf Panel C: Continuous}" "Other region (a)" " " " " "Other region $\times$ (b)" "Low identification with Spain" " " "Observations" "Year Lottery FE $\times$ Province FE" "Controls" "  
loc rowstats ""

forval i = 1/23 {
    loc rowstats "`rowstats' thisstat`i'"
}


esttab * using "$output/mechanisms_combined.tex", replace cells(none) booktabs nonotes nomtitles /*nonum*/ compress alignment(c) nogap noobs nobaselevels label stats(`rowstats', labels(`rowlabels')) ///
  mgroups("\shortstack{Other region\\as at\\age 17}" "\shortstack{Years\\outside\\region of birth}" "\shortstack{Age out\\of parents'\\home}" "\shortstack{Open-\\ness to\\experiences}" "\shortstack{Exposure\\different\\socio back}"  "\shortstack{Positive\\Experience\\Mili}" "\shortstack{Log Labor\\Income}" "\shortstack{In Labor\\Force}", pattern(1 1 1 1 1 1 1 1 1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))

	
	
	
	
	eststo clear	


*nation_sentiment proud_spanish sentiment_flag belongint_regions_1 belongint_regions_2 belongint_regions_3 belongint_regions_4 belongint_regions_5 belongint_regions_6



*gen identity=nation_sentiment+proud_spanish+sentiment_flag












