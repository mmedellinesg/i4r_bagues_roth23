
clear

use "$data/final datasets/surveydata_merged.dta", clear
 
 
version 15

global controls i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv
gen constant = 1


foreach var of varlist z_identity z_nation_sentiment z_proud_spanish z_sentiment_flag{
xi: areg  `var' , a(cluster)
predict `var'_resid, resid
}


*nation sentiment

distplot z_nation_sentiment_resid if nationalisticregion2==1, over(other_region_17_mili) name(z_nation_sentiment_nat, replace) legend(label(1 "In Home Region") label(2 "Outside of Home Region") position(6))   title("Panel A: From Region with Peripheral Nationalism", size(medium)) ytitle("") xtitle("Residualized Identification with Spain (z)") lcolor(blue red) xsize(10) ysize(10)
graph export "$output/z_nation_sentiment_nat.pdf", replace
graph save "$output/z_nation_sentiment_nat.gph", replace	 

distplot z_nation_sentiment_resid if nationalisticregion2!=1, over(other_region_17_mili) name(z_nation_sentiment_nonnat, replace) legend(label(1 "In Home Region") label(2 "Outside of Home Region") position(6))  title("Panel B: From Region with Peripheral Nationalism", size(medium)) ytitle("") xtitle("Residualized Identification with Spain (z)") lcolor(blue red) xsize(10) ysize(10)
graph save "$output/z_nation_sentiment_nonnat.gph", replace	 
graph export "$output/z_nation_sentiment_nonnat.pdf", replace


graph combine  "$output/z_nation_sentiment_nat.gph" "$output/z_nation_sentiment_nonnat.gph", col(2)  xsize(20) ysize(10)
graph export "$output/z_nation_sentiment_dist.pdf", replace


*pride to be Spanish

  

distplot z_proud_spanish_resid if nationalisticregion2==1, over(other_region_17_mili) name(z_proud_spanish_nat, replace) legend(label(1 "In Home Region") label(2 "Outside of Home Region") position(6))   title("Panel C: From Region with Peripheral Nationalism", size(medium)) ytitle("") xtitle("Residualized Pride to be Spanish (z)") xsize(10) ysize(10) lcolor(blue red)
graph export "$output/z_nation_sentiment_nat.pdf", replace
graph save "$output/z_nation_sentiment_nat.gph", replace	 

distplot z_proud_spanish_resid if nationalisticregion2!=1, over(other_region_17_mili) name(z_proud_spanish_nonnat, replace) legend(label(1 "In Home Region") label(2 "Outside of Home Region") position(6))  title("Panel D: From Region without Peripheral Nationalism", size(medium)) ytitle("") xtitle("Residualized Pride to be Spanish (z)") xsize(10) ysize(10) lcolor(blue red)
graph save "$output/z_proud_spanish_resid_nonnat.gph", replace	 
graph export "$output/z_proud_spanish_resid_nonnat.pdf", replace


graph combine "$output/z_nation_sentiment_nat.gph" "$output/z_proud_spanish_resid_nonnat.gph", col(2)  xsize(20) ysize(10)
graph export "$output/z_proud_spanish_dist.pdf", replace	 



*emotions spanish flag




distplot z_sentiment_flag_resid if nationalisticregion2==1, over(other_region_17_mili) name(z_sentiment_flag_nat, replace) legend(label(1 "In Home Region") label(2 "Outside of Home Region") position(6))   title("Panel E: From Region with Peripheral Nationalism", size(medium)) ytitle("") xtitle("Residualized Sentiment towards the flag (z)") xsize(10) ysize(10) lcolor(blue red)
graph export "$output/z_sentiment_flag_resid_nat.pdf", replace
graph save "$output/z_sentiment_flag_resid_nat.gph", replace	 

distplot z_sentiment_flag_resid if nationalisticregion2!=1, over(other_region_17_mili) name(z_sentiment_flag_nonnat, replace) legend(label(1 "In Home Region") label(2 "Outside of Home Region") position(6))  title("Panel F: From Region without Peripheral Nationalism", size(medium)) ytitle("") xtitle("Residualized Sentiment towards the flag (z)") xsize(10) ysize(10) lcolor(blue red)
graph save "$output/z_sentiment_flag_resid_nonnat.gph", replace	 
graph export "$output/z_sentiment_flag_resid_nonnat.pdf", replace


graph combine "$output/z_sentiment_flag_resid_nat.gph" "$output/z_sentiment_flag_resid_nonnat.gph", col(2)  xsize(20) ysize(10)
graph export "$output/z_sentiment_dist.pdf", replace	 











