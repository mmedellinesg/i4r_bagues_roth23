version 14

clear

use "$data/final datasets/surveydata_merged.dta", clear
 
gen pilot = (sample == "pilot")
label variable z_exposure_regions  `"`: var la exposure_regions' (z)"'

foreach var of varlist ever_outside number_friends_other_provinces number_friends_exclprovmili {
summ `var', d
gen z_`var'=(`var'-r(mean))/r(sd)
label variable z_`var'  `"`: var la `var'' (z)"'
}

gen firststageindex = (z_ever_outside + z_number_friends_other_provinces + z_number_friends_exclprovmili + z_exposure_regions )/4
 
foreach var of varlist firststageindex{
summ `var', d
gen z_`var'=(`var'-r(mean))/r(sd)
label variable z_`var'  "First stage index (z)"
}
 
global controls i.sample i.education same_region_birth_17 same_region_father same_region_mother  high_education_father high_education_mother i.sizemunicipality fath_notinlaborforce fath_ind_agr fath_ind_industr fath_ind_constr fath_ind_serv moth_notinlaborforce moth_ind_agr moth_ind_constr moth_ind_serv

local experiments "conscripts_other_regions z_number_friends_other_provinces z_number_friends_exclprovmili z_exposure_regions ever_outside z_firststageindex"

local Controls `""$controls" "$controls if militaryservice_mult1!=1" "if militaryservice_mult1!=1" "$controls if pilot != 1 & militaryservice_mult1!=1" "$controls age_military if militaryservice_mult1!=1""'
local Controls_lab "\shortstack{Original}" "\shortstack{Corrected}" "\shortstack{Drop\\controls}" "\shortstack{Exclude\\pilot}" "\shortstack{Control for\\age at service}"
local Controls_pat "1 1 1 1 1"

local Years `""$controls" "$controls if militaryservice_mult1!=1" "$controls if year_enter_lottery > 1969 & militaryservice_mult1!=1" "$controls if militaryservice_mult1!=1 & (year_enter_lottery < 1970 | year_enter_lottery > 1974)" "$controls if militaryservice_mult1!=1 & (year_enter_lottery < 1975 | year_enter_lottery > 1979)" "$controls if militaryservice_mult1!=1 & (year_enter_lottery < 1980 | year_enter_lottery > 1984)" "$controls if militaryservice_mult1!=1 & (year_enter_lottery < 1985 | year_enter_lottery > 1989)" "'
local Years_lab  "\shortstack{Original}"  "\shortstack{Corrected}" "\shortstack{Exc. lotteries\\before 1970}" "\shortstack{Exc. lotteries\\1970-1974}" "\shortstack{Exc. lotteries\\1975-1979}" "\shortstack{Exc. lotteries\\1980-1984}" "\shortstack{Exc. lotteries\\1985-1989}"
local Years_pat "1 1 1 1 1 1 1"

local Periods `""$controls" "$controls if militaryservice_mult1!=1" "$controls if militaryservice_mult1!=1 & year_enter_lottery > 1939 & year_enter_lottery <1976" "$controls if militaryservice_mult1!=1 & year_enter_lottery > 1978 & year_enter_lottery < 1988" "$controls if militaryservice_mult1!=1 & year_enter_lottery > 1939 & year_enter_lottery <1988" "$controls if militaryservice_mult1!=1 & year_enter_lottery > 1987 & year_enter_lottery < 1992" "'
local Periods_lab "\shortstack{Original}" "\shortstack{Corrected}" "\shortstack{Franco regime\\1940-1975}" "\shortstack{Transition\\1979-1987}" "\shortstack{Lottery years\\1940-1987}" "\shortstack{Lottery years\\1988-1991}"
local Periods_pat "1 1 1 1 1 1"

local tests Controls Years Periods

foreach choice in `experiments' {
	foreach test of local tests {
		preserve

		clear all
		eststo clear
		estimates drop _all

		set obs 10
		qui gen x = 1
		qui gen y = 1

		loc columns = 0

		foreach rob of local `test' {
			di "`rob'"
			loc ++columns
			qui eststo col`columns': reg x y
		}
		restore

		loc colnum = 1
		loc colnames ""
		
		foreach rob of local `test' {
			 xi:   qui areg `choice' other_region_17_mili `rob', cl(cluster) a(cluster)
				sigstar other_region_17_mili, prec(3)
				estadd loc thisstat2 = "`r(bstar)'": col`colnum'
				estadd loc thisstat3 = "`r(sestar)'": col`colnum'

			 xi:   areg `choice' other_region_17_mili_HET3 other_region_17_mili nationalisticregion2 `rob', cl(cluster) a(cluster)
				sigstar other_region_17_mili, prec(3)
				estadd loc thisstat6 = "`r(bstar)'": col`colnum'
				estadd loc thisstat7 = "`r(sestar)'": col`colnum'
				
			 sigstar other_region_17_mili_HET3, prec(3)
				estadd loc thisstat9 = "`r(bstar)'": col`colnum'
				estadd loc thisstat10 = "`r(sestar)'": col`colnum'
					
			test 	other_region_17_mili + other_region_17_mili_HET3 = 0
				estadd loc thisstat12 = string(r(p), "%9.3f"):col`colnum'			
				

			 xi:   areg `choice' other_region_17_mili_HET4 other_region_17_mili predictedregionalism `rob', cl(cluster)  a(cluster)
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
			}

			loc rowlabels " "{\bf Panel A: Main}" "Other region" " " " " "{\bf Panel B: Binary}" "Other region (a)" " " " " "Other region $\times$ (b)" "Peripheral Nationalism" " " "P-value (a+b)" " " "{\bf Panel C: Continuous}" "Other region (a)" " " " " "Other region $\times$ (b)" "Low identification with Spain" " " "Observations" "Year Lottery FE $\times$ Province FE" "Controls" "  	
			loc rowstats ""

			forval i = 1/23 {
				loc rowstats "`rowstats' thisstat`i'"
			}

	esttab * using "$output/table_2_`choice'_`test'.tex", replace cells(none) booktabs nofloat nonotes nomtitles compress alignment(c) nogap noobs nobaselevels label stats(`rowstats', labels(`rowlabels')) title("`test' \label{tab2_`choice'_`test'}") substitute(\_ _) ///
	addnote("Dependent variable: `: var la `choice''") mgroups("``test'_lab'", pattern("``test'_pat'") prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))	
	eststo clear	
	}
}
	
