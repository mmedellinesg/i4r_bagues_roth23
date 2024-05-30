***********************************************************************************
// Replication Files
**********************************************************************************
/*
Interregional Contact and the Formation of a Shared Identity
Manuel Bagues and Christopher Roth 
AEJ: Policy
*/
**********************************************************************************

***********************************************************************************
**** Master File
***********************************************************************************


version 14

** Adjust the following path to your own directory in which you store the folder "ReplicationFiles"

global path `c(pwd)'


cap log close
log using "$path/log/All.log", replace	

	global data	 = 	"$path/data"
	global do = 	"$path/do files"
	global output = "$path/output"
	adopath + "$path/ado-files"

	
********************************************************************************
********************************************************************************
**************************GENERATE DATA FILES***********************************
********************************************************************************
********************************************************************************


do "$do/01_Generate survey data/generate survey dataset.do"

do "$do/02_generate_population_characteristics/cis data for table A1.do"

do "$do/03_read_census_data/administrative dataset.do"



********************************************************************************
********************************************************************************
*********************************main Figures******************************* 
********************************************************************************
********************************************************************************

do "$do/MainFigures/Figure1.do"
do "$do/MainFigures/Figure2.do"
do "$do/MainFigures/Figure3.do"

********************************************************************************
********************************************************************************
*********************************appendix Figures******************************* 
********************************************************************************
********************************************************************************


do "$do/AppendixFigures/FigureA2.do"
do "$do/AppendixFigures/FigureA3.do"
do "$do/AppendixFigures/FigureA4.do"
do "$do/AppendixFigures/FigureA5.do"
do "$do/AppendixFigures/FigureA6.do"
do "$do/AppendixFigures/FigureA7.do"

********************************************************************************
********************************************************************************
*********************************main tables******************************* 
********************************************************************************
********************************************************************************

do "$do/MainTables/Table1.do"
do "$do/MainTables/Table2.do"
do "$do/MainTables/Table2_robustness.do"
do "$do/MainTables/Table3.do"
do "$do/MainTables/Table3_robustness.do"
do "$do/MainTables/Table4.do"
do "$do/MainTables/Table4_robustness.do"

********************************************************************************
********************************************************************************
**************************Appendix Tables***************************************
********************************************************************************
********************************************************************************

do "$do/AppendixTables/TableA1.do"
version 14
do "$do/AppendixTables/TableA2.do"
do "$do/AppendixTables/TableA3A4.do"
do "$do/AppendixTables/TableA5.do"
do "$do/AppendixTables/TableA6.do"
do "$do/AppendixTables/TableA7.do"
do "$do/AppendixTables/TableA8.do"
do "$do/AppendixTables/TableA9.do"
do "$do/AppendixTables/TableA10.do"
do "$do/AppendixTables/TableA11.do"
do "$do/AppendixTables/TableA12.do" 
do "$do/AppendixTables/TableA13.do" 
do "$do/AppendixTables/TableA14.do" 
do "$do/AppendixTables/TableA15.do" 
do "$do/AppendixTables/TableA16.do" 
do "$do/AppendixTables/TableA17.do" 
do "$do/AppendixTables/TableA18.do" 
do "$do/AppendixTables/TableA19.do" 
do "$do/AppendixTables/TableA20.do" 
do "$do/AppendixTables/TableA21.do"

