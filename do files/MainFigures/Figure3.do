
clear



use "$data/final datasets/surveydata_merged.dta"
 
 
version 15

global controls i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv
gen constant = 1

xi: areg  z_identity , a(cluster)
predict z_identity_resid, resid

xi: areg  predictedregionalism , a(cluster)
predict predictedregionalism_resid, resid

sum predictedregionalism_resid, d
sum z_identity_resid, d


graph twoway (qfitci z_identity_resid predictedregionalism_resid if other_region_17_mili==0,lpattern(shortdash) fintensity(inten100) ) (scatter z_identity_resid predictedregionalism_resid if other_region_17_mili==0,color(red%30)symbol(circle_hollow) msize(vsmall) jitter(5) ) || (qfitci z_identity_resid predictedregionalism_resid if other_region_17_mili==1,lpattern(shortdash_dot) fintensity(inten100)) (scatter z_identity_resid predictedregionalism_resid if other_region_17_mili==1, symbol(triangle_hollow) msize(vsmall) color(green%30) jitter(5)  ) , ///
                 scheme(plotplainblind) xtitle("Predicted weak identification with Spain",size(medsmall)) ytitle("Identification with Spain Index (z)",size(medsmall)) ///
				 legend(pos(6) size(mediumsmall) row(3)) ///
				 legend(order(3 "Home Region" 6 "Out of Home Region" 2 "Home Region" 5 "Out of Home Region" 1 "95 CI"))  
graph export "$output/figure_3.pdf", replace	 

