
clear

use "$data/final datasets/surveydata_merged.dta", clear
 
* assigned_nationalistic other_region_17_mili assigned_nationalistic_other

gen assigned_othernationalistic=0
replace assigned_othernationalistic = assigned_nationalistic if nationalisticregion2==1 & other_region_17_mili==1

gen assigned_otherNONnationalistic=0
replace assigned_otherNONnationalistic = assigned_nationalistic==0 if nationalisticregion2==1 & other_region_17_mili==1

 xi:   areg z_identity  assigned_othernationalistic assigned_otherNONnationalistic $controls if nationalisticregion2==1, cl(cluster) a(cluster)

 
gen nonPN_assigned_othernat=0
replace nonPN_assigned_othernat = assigned_nationalistic if nationalisticregion2!=1 & other_region_17_mili==1

gen nonPN_assigned_otherNONnat=0
replace nonPN_assigned_otherNONnat = assigned_nationalistic==0 if nationalisticregion2!=1 & other_region_17_mili==1

 xi:   areg z_identity  nonPN_assigned_othernat nonPN_assigned_otherNONnat $controls if nationalisticregion2!=1, cl(cluster) a(cluster)


global controls  i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv

loc experiments " z_nation_sentiment z_proud_spanish z_sentiment_flag z_identity"

*  
* gen nat_assignednat = assigned_nationalistic*nationalisticregion2
* gen prednat_assignednat = assigned_nationalistic*predictedregionalism2


 xi:    areg z_identity assigned_nationalistic_other assigned_nationalistic other_region_17_mili $controls, cl(cluster) a(cluster)


 xi:    areg z_identity assigned_nationalistic $controls, cl(cluster) a(cluster)
 
 xi:    areg z_identity assigned_nationalistic $controls if nationalisticregion2==1, cl(cluster) a(cluster)
 xi:    areg z_identity assigned_nationalistic $controls if nationalisticregion2!=1, cl(cluster) a(cluster)

 xi:    areg z_identity nat_assignednat assigned_nationalistic nationalisticregion2 $controls , cl(cluster) a(cluster)

 
 xi:    areg z_identity prednat_assignednat assigned_nationalistic predictedregionalism2 $controls , cl(cluster) a(cluster)
 
 
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


 xi:   areg `choice'  assigned_othernationalistic assigned_otherNONnationalistic $controls if nationalisticregion2==1, cl(cluster) a(cluster)
 *****baseline category: home region.
 *****other region not nationalistic.
 *****other region but nationalistic.
 
    sigstar assigned_othernationalistic, prec(3)
    estadd loc thisstat2 = "`r(bstar)'": col`colnum'
    estadd loc thisstat3 = "`r(sestar)'": col`colnum'
	
	
 sigstar assigned_otherNONnationalistic, prec(3)
    estadd loc thisstat5 = "`r(bstar)'": col`colnum'
    estadd loc thisstat6 = "`r(sestar)'": col`colnum'
				
    estadd loc thisstat8 = `e(N)': col`colnum'
	

 xi:   areg `choice' nonPN_assigned_othernat nonPN_assigned_otherNONnat $controls if nationalisticregion2==0, cl(cluster)  a(cluster)
    sigstar nonPN_assigned_othernat, prec(3)
    estadd loc thisstat11 = "`r(bstar)'": col`colnum'
    estadd loc thisstat12 = "`r(sestar)'": col`colnum'
	
	
 sigstar nonPN_assigned_otherNONnat, prec(3)
    estadd loc thisstat14 = "`r(bstar)'": col`colnum'
    estadd loc thisstat15 = "`r(sestar)'": col`colnum'	
		
    estadd loc thisstat17 = `e(N)': col`colnum'
    estadd loc thisstat18 = "Y": col`colnum'
    estadd loc thisstat19 = "Y": col`colnum'

	

	
			
	loc ++colnum
    loc colnames "`colnames' `"`: var la `choice''"'"

}
	
loc rowlabels " "{\bf Panel A: From PN Region}" "Sent to Other Region with PN" " " " " "Sent to Other Region without PN" " " " " "Observations" " " "{\bf Panel B: From Non-PN Region}" "Sent to Other Region with PN" " " " " "Sent to Other Region without PN" " " " " "Observations" "Year Lottery FE $\times$ Province FE" "Controls" "  
loc rowstats ""

forval i = 1/19 {
    loc rowstats "`rowstats' thisstat`i'"
}


esttab * using "$output/identity_assignedtoPNregion.tex", replace cells(none) booktabs nonotes nomtitles /*nonum*/ compress alignment(c) nogap noobs nobaselevels label stats(`rowstats', labels(`rowlabels')) ///
  mgroups("\shortstack{Attachment\\to\\Spain}" "\shortstack{Proud \\to be\\ Spanish}" "\shortstack{Positive\\emotions\\Spanish flag}" "\shortstack{Identity\\Index}", pattern(1 1 1 1 1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))

	
	
	*sentiment_index similarity_index
	
	eststo clear	


*nation_sentiment proud_spanish sentiment_flag belongint_regions_1 belongint_regions_2 belongint_regions_3 belongint_regions_4 belongint_regions_5 belongint_regions_6



*gen identity=nation_sentiment+proud_spanish+sentiment_flag













