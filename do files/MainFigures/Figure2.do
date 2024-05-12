
clear


use "$data/final datasets/surveydata_merged.dta"
 
version 15

global controls i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv
gen constant = 1


foreach var of varlist z_identity z_nation_sentiment z_proud_spanish z_sentiment_flag{
xi: areg  `var' , a(cluster)
predict `var'_resid, resid
}


*****index.

distplot z_identity_resid if nationalisticregion2==1, over(other_region_17_mili) name(z_identity_residbytreat_nat, replace) legend(label(1 "In Home Region") label(2 "Outside of Home Region") position(6))   title("Panel A: From Region with Peripheral Nationalism", size(medium)) ytitle("") xtitle("Residualized Identification Index (z-score)") lcolor(blue red) xsize(10) ysize(10)
graph export "$output/z_identity_nat.pdf", replace
graph save "$output/z_identity_nat.gph", replace 	 

distplot z_identity_resid if nationalisticregion2!=1, over(other_region_17_mili) name(z_identity_residbytreat_nonnat, replace) legend(label(1 "In Home Region") label(2 "Outside of Home Region") position(6))  title("Panel B: From Region without Peripheral Nationalism", size(medium)) ytitle("") xtitle("Residualized Identification Index (z-score)") lcolor(blue red) xsize(10) ysize(10)
graph save "$output/z_identity_nonnat.gph", replace	 
graph export "$output/z_identity_nonnat.pdf", replace

graph combine "$output/z_identity_nat.gph" "$output/z_identity_nonnat.gph"
graph export "$output/figure_2.pdf", replace
