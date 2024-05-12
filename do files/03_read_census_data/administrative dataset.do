

**We use census data to estimate the impact on mobility

***1 - we read the census data for 1991, 2001 and 2011

do "$do/03_read_census_data/1.reading census data spain.do"

* creates file "data/census/census.dta"

***1.2 - Generates descriptive statistic mentioned in footnote 36 


do "$do/DataPaper/section 3.2 administrative data.do"



***2 - we read the lottery data

do "$do/03_read_census_data/2.reading lottery military service.do"

*creates "data/sorteos/mili_wide.dta"

***3 - we add to census information on the lottery (census.dta + mili_wide.dta)

do "$do/03_read_census_data/3.merge lottery with census.do"

* creates files "data/census/census with lottery info.dta"





