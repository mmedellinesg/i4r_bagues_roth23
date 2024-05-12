
***Table A21


clear
use "$data/census/census with lottery info.dta"

keep if year==2011

tab year female
*148,125 male

*we focus on men who were not exempted from serving

keep if female==0 & excedente==0 & year==2011

count if away==0
count if away==1
count if away>0 & away<1

sum away excedente if female==0

egen group=group(year year_birth province_code_birth)

egen cluster=group(year_birth province_code_birth)



*************************Table A21
*column 1
capture xi: areg migrated_other_region away  [pweight=factor], absorb(group)  cluster(cluster)
est store migration_other_region
estadd ysumm

*column 2
capture xi: reghdfe migrated_other_region i.nationalistic_region*away if female==0 & excedente==0  & year==2011 [pweight=factor], absorb(group /*month*/)  cluster(cluster)
est store migration_nationalistic
estadd ysumm

*column 5
capture xi: areg partner_other_region away  if female==0 & excedente==0 & year==2011 [pweight=factor], absorb(group)  cluster(cluster)
est store partner_other_region
estadd ysumm


*column 6
capture xi: reghdfe partner_other_region i.nationalistic_region*away if female==0 & excedente==0 [pweight=factor], absorb(group /*month*/ )  cluster(cluster)
est store partner_nationalistic
estadd ysumm


estout migration_other_region	 migration_nationalistic partner_other_region partner_nationalistic ,/*
*/ keep(away _InatXaway_1) /*
*/ cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) stats(ymean r2 N, fmt(%9.2f %9.3f %9.0f)/*
*/ labels("Mean Y" "Adj. R-squared" N)) legend label collabels(, none) /*
*/ varlabels(_cons Constant) posthead("") prefoot("") postfoot("") /*
*/ varwidth(9) modelwidth(9) delimiter("") style(fixed) starlevels(* 0.10 ** 0.05 *** 0.01) 

*****************************************************************************************************
*************We conduct a similar exercise using the survey data with the same sample****************
*****************************************************************************************************

clear

use "$data/final datasets/surveydata_merged.dta", clear
 
  gen other_region_residence_17 = same_region_residence_17==0

  sum other_region_residence_17 if other_region_17_mili==0
    sum other_region_residence_17 if other_region_17_mili==1

   gen inlaborforce = notinlaborforce == 0 
  
global controls i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv mis_sizemunicipality mis_fath_notinlaborforce mis_fath_ind_agr mis_fath_ind_industr mis_fath_ind_constr mis_fath_ind_serv mis_moth_notinlaborforce mis_moth_ind_agr mis_moth_ind_constr mis_moth_ind_serv
 
loc experiments "other_region_residence_17 years_outside emancipation z_openness  z_exposure_socioec z_experience_military lninc inlaborforce"

keep if yearofbirth>=1968 & yearofbirth<=1973

**using all sample

*column 3
capture xi: areg other_region_residence_17 other_region_17_mili $controls, cl(cluster) a(cluster)
est store s_other_region
estadd ysumm
*column 4
capture xi: areg other_region_residence_17 i.other_region_17_mili*nationalisticregion $controls, cl(cluster) a(cluster)
capture est store s_other_region_nat
estadd ysumm


  
  estout s_other_region s_other_region_nat ,/*
  */ keep(other_region_17_mili _Iother_reg_1 _IothX*) /*
*/ cells(b(star fmt(%9.3f)) se(par fmt(%9.4f))) stats(ymean r2 N, fmt(%9.2f %9.3f %9.0f)/*
*/ labels("Mean Y" "Adj. R-squared" N)) legend label collabels(, none) /*
*/ varlabels(_cons Constant) posthead("") prefoot("") postfoot("") /*
*/ varwidth(9) modelwidth(9) delimiter("") style(fixed) starlevels(* 0.10 ** 0.05 *** 0.01) 

