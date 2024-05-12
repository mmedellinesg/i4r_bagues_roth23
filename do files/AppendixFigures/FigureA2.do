

***We calculate the share of conscripts from the same region if you serve at home
clear
use "$data/final datasets/surveydata_merged.dta"
 

tab yearofbirth

histogram  yearofbirth, frac xtitle("Year of Birth") title("Panel A") width(1)
 graph export "$output/yearofbirth.pdf", as(pdf) replace
graph save "$output/yearofbirth.gph", replace	 
	   
 
histogram year_enter_lottery, frac xtitle("Year Entered the Lottery") title("Panel B") width(1)
	   graph export "$output/year_enter_lottery.pdf", as(pdf) replace
graph save "$output/year_enter_lottery.gph", replace	 
	   
graph combine "$output/yearofbirth.gph" "$output/year_enter_lottery.gph", ycommon	   
	   	   graph export "$output/yearlottery_yearbirth.pdf", as(pdf) replace
graph save "$output/yearlottery_yearbirth.gph", replace	 
	   
	  
