
clear

use "$data/final datasets/surveydata_merged.dta", clear

drop if region_age17=="ceuta" | region_age17=="melilla"

tab region_age17 region_lottery

tab same_region_17_lottery, m

  collapse (mean) same_region_17_lottery, by(region_age17)

 egen id = group(region_age17)
 
 gen zero =0
 
 gen nationalisticregion2 = (region_age17=="baleares" | region_age17=="catalunya" | region_age17=="galicia" | region_age17=="navarra" | region_age17=="pais vasco")

    twoway    (rbar same_region_17_lottery zero id if nationalisticregion2==1, fcolor(gs1))  (rbar same_region_17_lottery zero id if nationalisticregion2!=1)  , ///	
	ytitle("Fraction staying in home region") ///	
	xtitle("") ///
	ylabel(0(0.2)0.6) ///
	legend(off) ///
	xlabel( 1 "Andalucia" 2 "Aragon" 3 "Asturias" 4 "Balearics"  5 "Canaries"  6 "Cantabria" 7 "Castile-La Mancha" 8 "Castile and Leon" 9 "Catalonia" 10 "Valencia" 11 "Extremadura" 12 "Galicia"  13 "Madrid"  14 "Murcia"  15 "Navarre" 16 "Basque Country" 17 "Rioja" , labsize(3.5) angle(45) noticks) ///
 	name(fractionhomebyregion, replace)	
	graph display fractionhomebyregion, xsize(15) ysize(10) 	 
 	   graph export "$output/fractionhomebyregion.pdf", as(pdf) replace
	   


	   
