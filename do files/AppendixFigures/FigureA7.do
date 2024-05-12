
clear

use "$data/final datasets/surveydata_merged.dta", clear
 


version 15

global controls i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv


 xi: areg  z_exposure_regions , a(cluster)
predict z_exposure_regions_resid, resid



xi: areg  z_identity , a(cluster)
predict z_identity_resid, resid

xi: areg  z_predictedsimilarity , a(cluster)
predict predictedsimilarity_resid, resid

   xi: areg  z_similarity , a(cluster)
predict z_similarity_resid, resid


xi: reg z_exposure_regions_resid predictedsimilarity_resid other_region_17_mili $controls  , cl(cluster)
xi: reg z_similarity_resid predictedsimilarity_resid other_region_17_mili $controls, cl(cluster)
xi: reg z_identity_resid predictedsimilarity_resid other_region_17_mili $controls, cl(cluster)
   

graph twoway (qfitci z_similarity_resid predictedsimilarity_resid,lpattern(shortdash) fintensity(inten100) ) (scatter z_similarity_resid predictedsimilarity_resid ,color(red%30)symbol(circle_hollow) msize(vsmall) jitter(5) ) , ///
                 scheme(plotplainblind) xtitle("Pre-determined Cultural Similarity",size(medsmall)) ytitle("Perceived Similarity",size(medsmall)) ///
				 legend(pos(6) size(mediumsmall) row(3)) ///
				 legend(order(1 "95 CI"))  
graph export "$output/similarity_cultdistance.pdf", replace	 
graph save "$output/similarity_cultdistance.gph", replace	 


graph twoway (qfitci z_identity_resid predictedsimilarity_resid ,lpattern(shortdash) fintensity(inten100) ) (scatter z_identity_resid predictedsimilarity_resid ,color(red%30)symbol(circle_hollow) msize(vsmall) jitter(5) ) , ///
                 scheme(plotplainblind) xtitle("Pre-determined Cultural Similarity",size(medsmall)) ytitle("Identification with Spain Index",size(medsmall)) ///
				 legend(pos(6) size(mediumsmall) row(3)) ///
				 legend(order("95 CI"))  
graph export "$output/identity_cultdistance.pdf", replace	 
graph save "$output/identity_cultdistance.gph", replace	 


   


graph twoway (qfitci z_exposure_regions_resid predictedsimilarity_resid,lpattern(shortdash) fintensity(inten100) ) (scatter z_exposure_regions_resid predictedsimilarity_resid ,color(red%30)symbol(circle_hollow) msize(vsmall) jitter(5) ) , ///
                 scheme(plotplainblind) xtitle("Pre-determined Cultural Similarity",size(medsmall)) ytitle("Exposure to People from Other Regions",size(medsmall)) ///
				 legend(pos(6) size(mediumsmall) row(3)) ///
				 legend(order(1 "95 CI"))  
graph export "$output/exposures_cultdistance.pdf", replace	
graph save "$output/exposures_cultdistance.gph", replace	 


graph combine  "$output/exposures_cultdistance.gph" "$output/similarity_cultdistance.gph" "$output/identity_cultdistance.gph", row(3) xsize(11) ysize(20)
graph export "$output/heterogeneitybyculturaldistance.pdf", replace	
