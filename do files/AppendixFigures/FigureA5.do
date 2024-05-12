

***We calculate the share of conscripts from the same region if you serve at home
clear
use "$data/final datasets/surveydata_merged.dta"

drop if region_military=="ceuta" | region_military=="melilla"


collapse (mean) same_region_17_mili (count) count=same_region_17_mili,  by(region_military)


gen nationalisticregion2 = (region_military=="baleares" | region_military=="catalunya" | region_military=="galicia" | region_military=="navarra" | region_military=="pais vasco")





mean same_region_17_mili
mean same_region_17_mili [aweight=count]

egen id = group(region_military)
 
 gen zero =0
 
   twoway    (rbar same_region_17_mili zero id if nationalisticregion2==1, fcolor(gs1)) (rbar same_region_17_mili zero id if nationalisticregion2!=1) , ///	
	ytitle("Same Region: Fraction from home region") ///	
	title("Panel A") ///		
	xtitle("") ///
	ylabel(0(0.2)0.8) ///
	legend(off) ///
	xlabel( 1 "Andalucia" 2 "Aragon" 3 "Asturias" 4 "Balearics"  5 "Canaries"  6 "Cantabria" 7 "Castile-La Mancha" 8 "Castile and Leon" 9 "Catalonia" 10 "Valencia" 11 "Extremadura" 12 "Galicia"  13 "Madrid"  14 "Murcia"  15 "Navarre" 16 "Basque Country" 17 "Rioja" , labsize(3.5) angle(45) noticks) ///
 	name(fractionhomebyregion, replace)	
	graph display fractionhomebyregion, xsize(15) ysize(15) 	 
 	   graph export "$output/fractionhomeinhomeregion.pdf", as(pdf) replace
graph save "$output/fractionhomeinhomeregion.gph", replace	 
	   

***We calculate the share of conscripts from the same region if you serve away


clear
use "$data/final datasets/surveydata_merged.dta"

 
drop if region_military=="ceuta" | region_military=="melilla"


sort  region_military region_age17

bys region_military region_age17: egen count=count(_n)

bys region_military : egen conscripts_in_region=count(_n)

gen share=count/conscripts_in_region



egen tag_region_military=tag(region_military region_age17)
 


mean share if region_age17==region_military & tag_region_military & region_age17!=""
mean share if region_age17==region_military & tag_region_military & region_age17!="" [aweight=count]

mean share if region_age17!=region_military & tag_region_military & region_age17!=""
mean share if region_age17!=region_military & tag_region_military & region_age17!="" [aweight=count] 



keep if region_age17!=region_military & tag_region_military & region_age17!=""


collapse (mean) share (count) count=share ,  by(region_age17)

drop if region_age17=="ceuta" | region_age17=="melilla"


gen nationalisticregion2 = (region_age17=="baleares" | region_age17=="catalunya" | region_age17=="galicia" | region_age17=="navarra" | region_age17=="pais vasco")


egen id = group(region_age17)
 
 gen zero =0
 

 
   twoway    (rbar share zero id if nationalisticregion2==1, fcolor(gs1))  (rbar share zero id if nationalisticregion2!=1)  , ///	
	ytitle("Other Region: Fraction from home region") ///	
	title("Panel B") ///	
	xtitle("") ///
	ylabel(0(0.2)0.8) ///
	legend(off) ///
	xlabel( 1 "Andalucia" 2 "Aragon" 3 "Asturias" 4 "Balearics"  5 "Canaries"  6 "Cantabria" 7 "Castile-La Mancha" 8 "Castile and Leon" 9 "Catalonia" 10 "Valencia" 11 "Extremadura" 12 "Galicia"  13 "Madrid"  14 "Murcia"  15 "Navarre" 16 "Basque Country" 17 "Rioja" , labsize(3.5) angle(45) noticks) ///
 	name(fractionhomebyregion, replace)	
	graph display fractionhomebyregion, xsize(15) ysize(15) 	 
 	   graph export "$output/fractionoutsideregion.pdf", as(pdf) replace
graph save "$output/fractionoutsideregion.gph", replace	 
	   


graph combine "$output/fractionhomeinhomeregion.gph" "$output/fractionoutsideregion.gph", col(2) ycommon
graph export "$output/fractionfromhome.pdf", replace	
	   
	   
