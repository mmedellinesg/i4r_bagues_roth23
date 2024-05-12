





***We calculate the share of conscripts from the same region if you serve at home
clear
use "$data/final datasets/surveydata_merged.dta"

 
global controls  i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv


gen nonnat = nationalisticregion2==0
gen tr_nonnat = other_region_17_mili*nonnat

 foreach var of varlist z_nation_sentiment z_proud_spanish z_sentiment_flag z_identity{
 gen TE_`var'=. 
gen SE_`var'=.
 xi:   areg `var' other_region_17_mili_HET3 other_region_17_mili nationalisticregion2 $controls, cl(cluster) a(cluster)
 replace TE_`var'=_b[other_region_17_mili] if nationalisticregion2!=1
replace SE_`var'=_se[other_region_17_mili] if nationalisticregion2!=1
xi: areg `var' tr_nonnat other_region_17_mili nonnat $controls, cl(cluster) a(cluster)
replace TE_`var'=_b[other_region_17_mili]  if `var'!=. & nationalisticregion2==1
replace SE_`var'=_se[other_region_17_mili] if `var'!=. & nationalisticregion2==1
}
 


collapse (mean) TE_* SE_*, by(nationalisticregion2)

reshape long TE_ SE_, i(nationalisticregion2) j(outcome) string

 
gen id2=-0.5 if outcome=="z_nation_sentiment" & nationalisticregion2==1
replace id2=.5 if outcome=="z_nation_sentiment" & nationalisticregion2!=1
 
replace id2=2.5 if outcome=="z_proud_spanish" & nationalisticregion2==1
replace id2=3.5 if outcome=="z_proud_spanish" & nationalisticregion2!=1

replace id2=5.5 if outcome=="z_sentiment_flag" & nationalisticregion2==1
replace id2=6.5 if outcome=="z_sentiment_flag" & nationalisticregion2!=1

replace id2=8.5 if outcome=="z_identity" & nationalisticregion2==1
replace id2=9.5 if outcome=="z_identity" & nationalisticregion2!=1

  

 set scheme lean2


generate hiz_avg = TE_ + 1.96*(SE_)
generate lowz_avg = TE_ - 1.96*(SE_)
 

 
 
 gen zero = 0
 
 
 
 
 
 
   twoway    (rbar TE_ zero id2 if nationalisticregion2) (rbar TE_ zero id2 if !nationalisticregion2)    (rcap hiz_avg lowz_avg id2 ) , ///	
	ytitle("Treatment effect (z-scored)") ///	
	xtitle("") ///
	ylabel(-0.2(0.1)0.5) ///
	legend(order(1 "From Region with Peripheral Nationalism" 2 "From Region without Peripheral Nationalism") ring(1) position(1)) ///
	xlabel( 0 "Attachment to Spain" 3 "Proud to be Spanish" 6 "Emotions: Spanish Flag"  9 "Identity Index" , labsize(3) noticks) ///
 	name(z_totaldemandstrongweak, replace)	
	graph display z_totaldemandstrongweak, xsize(15) ysize(10) 	 
	 graph export "$output/TreatmenteffectsbyPN.eps", as(eps) replace
 	   graph export "$output/figure_1.pdf", as(pdf) replace
	   
	
	
	
