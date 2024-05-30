clear
use "$data/final datasets/surveydata_reshaped.dta"

gen assigned_to_region_HET = nationalisticregion*assigned_to_region
gen assigned_to_region_HET2 = regionalidentity*assigned_to_region
gen assigned_to_region_HET3 = nationalisticregion2*assigned_to_region
gen assigned_to_region_HET4 = predictedregionalism*assigned_to_region

label variable z_sentiments "Sentiment (z)"
label variable z_trust "Trustworthiness (z)"
label variable z_index_regionsp "Index (z)"

loc experiments "z_sentiments z_trust z_index_regionsp"

local Years `""" " if militaryservice_mult1!=1" " if year_enter_lottery > 1969 & militaryservice_mult1!=1" " if militaryservice_mult1!=1 & (year_enter_lottery < 1970 | year_enter_lottery > 1974)" " if militaryservice_mult1!=1 & (year_enter_lottery < 1975 | year_enter_lottery > 1979)" " if militaryservice_mult1!=1 & (year_enter_lottery < 1980 | year_enter_lottery > 1984)" " if militaryservice_mult1!=1 & (year_enter_lottery < 1985 | year_enter_lottery > 1989)" "'
local Years_lab  "\shortstack{Original}" "\shortstack{Corrected}" "\shortstack{Exc. lotteries\\before 1970}" "\shortstack{Exc. lotteries\\1970-1974}" "\shortstack{Exc. lotteries\\1975-1979}" "\shortstack{Exc. lotteries\\1980-1984}" "\shortstack{Exc. lotteries\\1985-1989}"
local Years_pat "1 1 1 1 1 1 1"

local Periods `""" " if militaryservice_mult1!=1" " if militaryservice_mult1!=1 & year_enter_lottery > 1939 & year_enter_lottery <1976" " if militaryservice_mult1!=1 & year_enter_lottery > 1978 & year_enter_lottery < 1988" " if militaryservice_mult1!=1 & year_enter_lottery > 1939 & year_enter_lottery <1988" " if militaryservice_mult1!=1 & year_enter_lottery > 1987 & year_enter_lottery < 1992" "'
local Periods_lab "\shortstack{Original}" "\shortstack{Corrected}" "\shortstack{Franco regime\\1940-1975}" "\shortstack{Transition\\1979-1988}" "\shortstack{Lottery years\\1940-1987}" "\shortstack{Lottery years\\1988-1991}"
local Periods_pat "1 1 1 1 1 1"


local tests Years Periods

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


		***OLS
		foreach y of local `test' {

		xi: areg `choice' assigned_to_region i.group_region_region_17 `y', absorb(id_number) cluster(id_number)
			sigstar assigned_to_region, prec(3)
			estadd loc thisstat2 = "`r(bstar)'": col`colnum'
			estadd loc thisstat3 = "`r(sestar)'": col`colnum'
			

		xi: areg `choice' assigned_to_region assigned_to_region_HET3 i.group_region_region_17 `y',absorb(id_number) cluster(id_number)
			sigstar assigned_to_region, prec(3)
			estadd loc thisstat6 = "`r(bstar)'": col`colnum'
			estadd loc thisstat7 = "`r(sestar)'": col`colnum'
			
			 sigstar assigned_to_region_HET3, prec(3)
			estadd loc thisstat9 = "`r(bstar)'": col`colnum'
			estadd loc thisstat10 = "`r(sestar)'": col`colnum'
		test 	assigned_to_region_HET3 + assigned_to_region = 0
			
			estadd loc thisstat12 = string(r(p), "%9.3f"):col`colnum'	
			
			
		xi: areg `choice' assigned_to_region assigned_to_region_HET4 i.group_region_region_17 `y',absorb(id_number) cluster(id_number)
			sigstar assigned_to_region, prec(3)
			estadd loc thisstat15 = "`r(bstar)'": col`colnum'
			estadd loc thisstat16 = "`r(sestar)'": col`colnum'
			
			 sigstar assigned_to_region_HET4, prec(3)
			estadd loc thisstat18 = "`r(bstar)'": col`colnum'
			estadd loc thisstat19 = "`r(sestar)'": col`colnum'
			

			estadd loc thisstat21 = `e(N)': col`colnum'
			estadd loc thisstat22 = "Y": col`colnum'
			estadd loc thisstat23 = "Y": col`colnum'

			
					
			loc ++colnum
			loc colnames "`colnames' `"`: var la `choice''"'"

		}
			
		loc rowlabels " "{\bf Panel A: Main}" "Assigned to region" " " " " "{\bf Panel B: Binary}" "Assigned to region (a)" " " " " "Assigned to region $\times$ (b)" "Peripheral Nationalism" " " "P-value (a+b)" " " "{\bf Panel C: Continuous}" "Assigned to region (a)" " " " " "Assigned to region $\times$ (b)" "Low identification with Spain" " " "Observations" "Individual FE" "Region $\times$ Question Region FE" "  
		loc rowstats ""

		forval i = 1/23 {
			loc rowstats "`rowstats' thisstat`i'"
		}

	esttab * using "$output/table_3_`choice'_`test'.tex", replace cells(none) booktabs nonotes nofloat nomtitles compress alignment(c) nogap noobs nobaselevels label stats(`rowstats', labels(`rowlabels')) title("`test'"\label{tab3_`choice'_`test'})  addnote("Dependent variable: `: var la `choice''") ///
	mgroups("``test'_lab'", pattern("``test'_pat'") prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) substitute(\_ _)	

	eststo clear		
	}
} 
 