

clear

use "$data/final datasets/surveydata_merged_withmissings.dta", clear

gen cis =0

append using "$data/final datasets/cis data for table A1.dta"

version 15

*foreach var of varlist nation_sentiment proud_spanish sentiment_flag leftright{

distplot nation_sentiment, over(cis) name(nation_sentiment_cis, replace) legend(label(1 "Our Sample") label(2 "Representative Sample (CIS)") position(6))   title("") ytitle("") xtitle("Attachment with Spain") xsize(10) ysize(10)
graph save "$output/ciscomparisonnation_sentiment.gph", replace	 


distplot proud_spanish, over(cis) name(proud_spanish_cis, replace) legend(label(1 "Our Sample") label(2 "Representative Sample (CIS)") position(6))   title("") ytitle("") xtitle("Proud to be Spanish") xsize(10) ysize(10)
graph save "$output/ciscomparisonproud_spanish.gph", replace	 

distplot sentiment_flag, over(cis) name(sentiment_flag_cis, replace) legend(label(1 "Our Sample") label(2 "Representative Sample (CIS)") position(6))   title("") ytitle("") xtitle("Positive Emotions towards the flag") xsize(10) ysize(10)
graph save "$output/ciscomparisonflag.gph", replace	 


distplot leftright, over(cis) name(leftright_cis, replace) legend(label(1 "Our Sample") label(2 "Representative Sample (CIS)") position(6))   title("") ytitle("") xtitle("Ideology Scale: From left to right") xsize(10) ysize(10)
graph save "$output/ciscomparisonideology.gph", replace


graph combine "$output/ciscomparisonnation_sentiment.gph" "$output/ciscomparisonproud_spanish.gph" "$output/ciscomparisonflag.gph" "$output/ciscomparisonideology.gph", col(2)
graph export "$output/ciscomparison.pdf", replace	 
* 













