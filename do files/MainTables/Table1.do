



clear
use "$data/final datasets/surveydata_merged_withmissings.dta", clear
 
  
  
 areg other_region_17_mili same_region_birth_17 high_education siblings small_sizemunicipality same_region_father fath_notinlaborforce high_education_father fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv same_region_mother moth_notinlaborforce high_education_mother moth_ind_agr moth_ind_serv , cl(cluster) a(cluster)

 test same_region_birth_17 high_education siblings small_sizemunicipality same_region_father fath_notinlaborforce high_education_father fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv same_region_mother moth_notinlaborforce high_education_mother moth_ind_agr moth_ind_serv  
 


loc covars "same_region_birth_17 high_education siblings small_sizemunicipality same_region_father fath_notinlaborforce high_education_father fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv same_region_mother moth_notinlaborforce high_education_mother moth_ind_agr moth_ind_serv"


/* Balance tables */


    preserve

    clear all
    eststo clear
    estimates drop _all

    set obs 10
    qui gen x = 1
    qui gen y = 1

    forval i = 1/4 {

        qui eststo col`i': reg x y

    }

    restore

/* Statistics */

    loc tabletitle "Randomization check for experiment `expid'"
    loc rowstats ""
    loc rowlabels ""
    loc colnames " "Same region service" "Diff. region service" "P-value(High - Low)" "Observations" "

    loc varlength: list sizeof covars
    loc varindex = 1

    mat def P1 = J(`varlength', 1, .)
    mat def P2 = J(`varlength', 1, .)
    mat def P3 = J(`varlength', 1, .)

    foreach var in `covars' {


        cap noi {
            qui sum `var' if other_region_17_mili == 0
            estadd loc `var'_mean = string(r(mean), "%9.2f"): col1
        }

        cap noi {
            qui sum `var' if other_region_17_mili == 1
            estadd loc `var'_mean = string(r(mean), "%9.2f"): col2
        }



        cap noi {
           xi: areg `var' other_region_17_mili , cl(cluster) a(cluster)
            qui test other_region_17_mili = 0
            estadd loc `var'_mean = string(r(p), "%9.3f"): col3
            mat def P3[`varindex', 1] = r(p)
        }
		
				
				 cap noi {
            qui sum `var' 
            estadd loc `var'_mean =  string(r(N), "%9.0f"): col4
        }

        loc rowstats "`rowstats' `var'_mean `var'_sd"
        loc rowlabels "`rowlabels' `"`: var la `var''"' " " "

        loc ++varindex

    }

 
    esttab * using "$output/table_1", replace cells(none) booktabs nonotes nonum compress alignment(c) nogap noobs nobaselevels label mtitle(`colnames') stats(`rowstats', labels(`rowlabels'))
    eststo clear





