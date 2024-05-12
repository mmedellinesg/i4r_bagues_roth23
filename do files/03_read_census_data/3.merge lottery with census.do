****PROGRAMA PARA HACER EL MERGE DE LOS DATOS DEL SORTEO CON LOS DATOS DE LA MILI****


clear
use "$data/census/census.dta"
erase "$data/census/census.dta"
keep if year==2011
merge n:1 year_birth province_code_birth using "$data/lottery military service/mili_wide.dta"
erase "$data/lottery military service/mili_wide.dta"
keep if _==3
*Quito tambien los de antes de septiembre de 1968, que en realidad no entraron en el sorteo
drop if year_birth==1968 & month_birth<=8
drop _


*es necesario poner la fecha de nacimiento en formato numerico
forvalues i=1(1)31 {
gen fecha_nacimiento`i' = mdy(month_birth, `i', year_birth)
}


forvalues i=1(1)31 {
gen destino`i'=""
replace destino`i'="E.A. Primera Zona Aerea" if ((inicio_primera_aerea<=final_primera_aerea & fecha_nacimiento`i'>=inicio_primera_aerea & fecha_nacimiento`i'<=final_primera_aerea) | /*
*/ (inicio_primera_aerea>final_primera_aerea & (fecha_nacimiento`i'>=inicio_primera_aerea | fecha_nacimiento`i'<=final_primera_aerea))) & fecha_nacimiento`i'!=. 
replace destino`i'="E.A. Segunda Zona Aerea" if ((inicio_segunda_aerea<=final_segunda_aerea & fecha_nacimiento`i'>=inicio_segunda_aerea & fecha_nacimiento`i'<=final_segunda_aerea) | /*
*/ (inicio_segunda_aerea>final_segunda_aerea & (fecha_nacimiento`i'>=inicio_segunda_aerea | fecha_nacimiento`i'<=final_segunda_aerea))) & fecha_nacimiento`i'!=.
replace destino`i'="E.A. Tercera Zona Aerea" if ((inicio_tercera_aerea<=final_tercera_aerea & fecha_nacimiento`i'>=inicio_tercera_aerea & fecha_nacimiento`i'<=final_tercera_aerea) | /*
*/ (inicio_tercera_aerea>final_tercera_aerea & (fecha_nacimiento`i'>=inicio_tercera_aerea | fecha_nacimiento`i'<=final_tercera_aerea))) & fecha_nacimiento`i'!=.
replace destino`i'="E.A. Canarias" if ((inicio_canarias_aerea<=final_canarias_aerea & fecha_nacimiento`i'>=inicio_canarias_aerea & fecha_nacimiento`i'<=final_canarias_aerea) | /*
*/ (inicio_canarias_aerea>final_canarias_aerea & (fecha_nacimiento`i'>=inicio_canarias_aerea | fecha_nacimiento`i'<=final_canarias_aerea))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Region Central" if ((inicio_central_tierra<=final_central_tierra & fecha_nacimiento`i'>=inicio_central_tierra & fecha_nacimiento`i'<=final_central_tierra) | /*
*/ (inicio_central_tierra>final_central_tierra & (fecha_nacimiento`i'>=inicio_central_tierra | fecha_nacimiento`i'<=final_central_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Region Levante" if ((inicio_levante_tierra<=final_levante_tierra & fecha_nacimiento`i'>=inicio_levante_tierra & fecha_nacimiento`i'<=final_levante_tierra) | /*
*/ (inicio_levante_tierra>final_levante_tierra & (fecha_nacimiento`i'>=inicio_levante_tierra | fecha_nacimiento`i'<=final_levante_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Region Noroeste" if ((inicio_noroeste_tierra<=final_noroeste_tierra & fecha_nacimiento`i'>=inicio_noroeste_tierra & fecha_nacimiento`i'<=final_noroeste_tierra) | /*
*/ (inicio_noroeste_tierra>final_noroeste_tierra & (fecha_nacimiento`i'>=inicio_noroeste_tierra | fecha_nacimiento`i'<=final_noroeste_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Region P. Occidental" if ((inicio_occidental_tierra<=final_occidental_tierra & fecha_nacimiento`i'>=inicio_occidental_tierra & fecha_nacimiento`i'<=final_occidental_tierra) | /*
*/ (inicio_occidental_tierra>final_occidental_tierra & (fecha_nacimiento`i'>=inicio_occidental_tierra | fecha_nacimiento`i'<=final_occidental_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Region P. Oriental" if ((inicio_oriental_tierra<=final_oriental_tierra & fecha_nacimiento`i'>=inicio_oriental_tierra & fecha_nacimiento`i'<=final_oriental_tierra) | /*
*/ (inicio_oriental_tierra>final_oriental_tierra & (fecha_nacimiento`i'>=inicio_oriental_tierra | fecha_nacimiento`i'<=final_oriental_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Region Sur" if ((inicio_sur_tierra<=final_sur_tierra & fecha_nacimiento`i'>=inicio_sur_tierra & fecha_nacimiento`i'<=final_sur_tierra) | /*
*/ (inicio_sur_tierra>final_sur_tierra & (fecha_nacimiento`i'>=inicio_sur_tierra | fecha_nacimiento`i'<=final_sur_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Region Sur (Ceuta)" if ((inicio_ceuta_tierra<=final_ceuta_tierra & fecha_nacimiento`i'>=inicio_ceuta_tierra & fecha_nacimiento`i'<=final_ceuta_tierra) | /*
*/ (inicio_ceuta_tierra>final_ceuta_tierra & (fecha_nacimiento`i'>=inicio_ceuta_tierra | fecha_nacimiento`i'<=final_ceuta_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Region Sur (Melilla)" if ((inicio_melilla_tierra<=final_melilla_tierra & fecha_nacimiento`i'>=inicio_melilla_tierra & fecha_nacimiento`i'<=final_melilla_tierra) | /*
*/ (inicio_melilla_tierra>final_melilla_tierra & (fecha_nacimiento`i'>=inicio_melilla_tierra | fecha_nacimiento`i'<=final_melilla_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Zona Baleares" if ((inicio_baleares_tierra<=final_baleares_tierra & fecha_nacimiento`i'>=inicio_baleares_tierra & fecha_nacimiento`i'<=final_baleares_tierra) | /*
*/ (inicio_baleares_tierra>final_baleares_tierra & (fecha_nacimiento`i'>=inicio_baleares_tierra | fecha_nacimiento`i'<=final_baleares_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="E.T. Zona Canarias" if ((inicio_canarias_tierra<=final_canarias_tierra & fecha_nacimiento`i'>=inicio_canarias_tierra & fecha_nacimiento`i'<=final_canarias_tierra) | /*
*/ (inicio_canarias_tierra>final_canarias_tierra & (fecha_nacimiento`i'>=inicio_canarias_tierra | fecha_nacimiento`i'<=final_canarias_tierra))) & fecha_nacimiento`i'!=.
replace destino`i'="F.N. Jurisdiccion Central" if ((inicio_central_naval<=final_central_naval & fecha_nacimiento`i'>=inicio_central_naval & fecha_nacimiento`i'<=final_central_naval) | /*
*/ (inicio_central_naval>final_central_naval & (fecha_nacimiento`i'>=inicio_central_naval | fecha_nacimiento`i'<=final_central_naval))) & fecha_nacimiento`i'!=.
replace destino`i'="F.N.-Z.M. Canarias" if ((inicio_canarias_naval<=final_canarias_naval & fecha_nacimiento`i'>=inicio_canarias_naval & fecha_nacimiento`i'<=final_canarias_naval) | /*
*/ (inicio_canarias_naval>final_canarias_naval & (fecha_nacimiento`i'>=inicio_canarias_naval | fecha_nacimiento`i'<=final_canarias_naval))) & fecha_nacimiento`i'!=.
replace destino`i'="F.N.-Z.M. Cantabrico" if ((inicio_cantabrico_naval<=final_cantabrico_naval & fecha_nacimiento`i'>=inicio_cantabrico_naval & fecha_nacimiento`i'<=final_cantabrico_naval) | /*
*/ (inicio_cantabrico_naval>final_cantabrico_naval & (fecha_nacimiento`i'>=inicio_cantabrico_naval | fecha_nacimiento`i'<=final_cantabrico_naval))) & fecha_nacimiento`i'!=.
replace destino`i'="F.N.-Z.M. Estrecho" if ((inicio_estrecho_naval<=final_estrecho_naval & fecha_nacimiento`i'>=inicio_estrecho_naval & fecha_nacimiento`i'<=final_estrecho_naval) | /*
*/ (inicio_estrecho_naval>final_estrecho_naval & (fecha_nacimiento`i'>=inicio_estrecho_naval | fecha_nacimiento`i'<=final_estrecho_naval))) & fecha_nacimiento`i'!=.
replace destino`i'="F.N.-Z.M. Mediterraneo" if ((inicio_mediterraneo_naval<=final_mediterraneo_naval & fecha_nacimiento`i'>=inicio_mediterraneo_naval & fecha_nacimiento`i'<=final_mediterraneo_naval) | /*
*/ (inicio_mediterraneo_naval>final_mediterraneo_naval & (fecha_nacimiento`i'>=inicio_mediterraneo_naval | fecha_nacimiento`i'<=final_mediterraneo_naval))) & fecha_nacimiento`i'!=.
replace destino`i'="Excedentes" if ((inicio_excedentes<=final_excedentes & fecha_nacimiento`i'>=inicio_excedentes & fecha_nacimiento`i'<=final_excedentes) | /*
*/ (inicio_excedentes>final_excedentes & (fecha_nacimiento`i'>=inicio_excedentes | fecha_nacimiento`i'<=final_excedentes))) & fecha_nacimiento`i'!=.



gen cuerpo`i'=""
replace cuerpo`i'="Excedente" if destino`i'=="Excedentes"
replace cuerpo`i'="Tierra" if index(destino`i',"E.T.")!=0
replace cuerpo`i'="Mar" if index(destino`i',"F.N.")!=0
replace cuerpo`i'="Aire" if index(destino`i',"E.A.")!=0

*AHORA ASIGNO EL tratamiento: encasa, fuera o excedente

gen tratamiento`i'=""
replace tratamiento`i'="encasa" if destino`i'!=""
replace tratamiento`i'="fuera" if /*
*/ ((province_birth=="Alava" & destino`i'!="E.T. Region P. Occidental" & destino`i'!="E.A. Tercera Zona Aerea") | /*
*/ (province_birth=="Albacete" & destino`i'!="E.T. Region Levante" & destino`i'!="E.A. Segunda Zona Aerea") | /*
*/ (province_birth=="Asturias" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea" & destino`i'!="F.N.-Z.M. Cantabrico") | /*
*/ (province_birth=="Alicante" & destino`i'!="E.T. Region Levante" & destino`i'!="E.A. Segunda Zona Aerea" & destino`i'!="F.N.-Z.M. Mediterraneo") | /*
*/ (province_birth=="Almeria" & destino`i'!="E.T. Region Sur" & destino`i'!="E.A. Segunda Zona Aerea" & destino`i'!="F.N.-Z.M. Estrecho") | /*
*/ (province_birth=="Avila" & destino`i'!="E.T. Region Central" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Badajoz" & destino`i'!="E.T. Region Central" & destino`i'!="E.A. Segunda Zona Aerea") | /*
*/ (province_birth=="Baleares" & destino`i'!="E.T. Zona Baleares" & destino`i'!="E.A. Tercera Zona Aerea" & destino`i'!="F.N.-Z.M. Mediterraneo") | /*
*/ (province_birth=="Barcelona" & destino`i'!="E.T. Region P. Oriental" & destino`i'!="E.A. Tercera Zona Aerea" & destino`i'!="F.N.-Z.M. Mediterraneo") | /*
*/ (province_birth=="Burgos" & destino`i'!="E.T. Region P. Occidental" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Caceres" & destino`i'!="E.T. Region Central" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Cadiz" & destino`i'!="E.T. Region Sur" & destino`i'!="E.A. Segunda Zona Aerea" & destino`i'!="F.N.-Z.M. Estrecho") | /*
*/ (province_birth=="Cantabria" & destino`i'!="E.T. Region P. Occidental" & destino`i'!="E.A. Primera Zona Aerea" & destino`i'!="F.N.-Z.M. Cantabrico")) & destino`i'!=""
replace tratamiento`i'="fuera" if /*
*/ ((province_birth=="Castellon" & destino`i'!="E.T. Region Levante" & destino`i'!="E.A. Tercera Zona Aerea" & destino`i'!="F.N.-Z.M. Mediterraneo") | /*
*/ (province_birth=="Ceuta" & destino`i'!="E.T. Region Sur (Ceuta)" & destino`i'!="E.A. Segunda Zona Aerea" & destino`i'!="F.N.-Z.M. Estrecho") | /*
*/ (province_birth=="Ciudad Real" & destino`i'!="E.T. Region Central" & destino`i'!="E.A. Segunda Zona Aerea") | /*
*/ (province_birth=="Cordoba" & destino`i'!="E.T. Region Sur" & destino`i'!="E.A. Segunda Zona Aerea") | /*
*/ (province_birth=="Coruña" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea" & destino`i'!="F.N.-Z.M. Cantabrico") | /*
*/ (province_birth=="Cuenca" & destino`i'!="E.T. Region Central" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Girona" & destino`i'!="E.T. Region P. Oriental" & destino`i'!="E.A. Tercera Zona Aerea" & destino`i'!="F.N.-Z.M. Mediterraneo") | /*
*/ (province_birth=="Granada" & destino`i'!="E.T. Region Sur" & destino`i'!="E.A. Segunda Zona Aerea" & destino`i'!="F.N.-Z.M. Estrecho") | /*
*/ (province_birth=="Guadalajara" & destino`i'!="E.T. Region Central" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Guipuzcoa" & destino`i'!="E.T. Region P. Occidental" & destino`i'!="E.A. Tercera Zona Aerea" & destino`i'!="F.N.-Z.M. Cantabrico") | /*
*/ (province_birth=="Huelva" & destino`i'!="E.T. Region Sur" & destino`i'!="E.A. Segunda Zona Aerea" & destino`i'!="F.N.-Z.M. Estrecho") | /*
*/ (province_birth=="Huesca" & destino`i'!="E.T. Region P. Oriental" & destino`i'!="E.A. Tercera Zona Aerea") | /*
*/ (province_birth=="Jaen" & destino`i'!="E.T. Region Sur" & destino`i'!="E.A. Segunda Zona Aerea")) & destino`i'!=""
replace tratamiento`i'="fuera" if /*
*/ ((province_birth=="Leon" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Lugo" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea" & destino`i'!="F.N.-Z.M. Cantabrico") | /*
*/ (province_birth=="Lleida" & destino`i'!="E.T. Region P. Oriental" & destino`i'!="E.A. Tercera Zona Aerea" & destino`i'!="F.N.-Z.M. Mediterraneo") | /*
*/ (province_birth=="Madrid" & destino`i'!="E.T. Region Central" & destino`i'!="E.A. Primera Zona Aerea" & destino`i'!="F.N. Jurisdiccion Central") | /*
*/ (province_birth=="Malaga" & destino`i'!="E.T. Region Sur" & destino`i'!="E.A. Segunda Zona Aerea" & destino`i'!="F.N.-Z.M. Estrecho") | /*
*/ (province_birth=="Melilla" & destino`i'!="E.T. Region Sur (Melilla)" & destino`i'!="E.A. Segunda Zona Aerea" & destino`i'!="F.N.-Z.M. Estrecho") | /*
*/ (province_birth=="Murcia" & destino`i'!="E.T. Region Levante" & destino`i'!="E.A. Segunda Zona Aerea" & destino`i'!="F.N.-Z.M. Mediterraneo") | /*
*/ (province_birth=="Navarra" & destino`i'!="E.T. Region P. Occidental" & destino`i'!="E.A. Tercera Zona Aerea") | /*
*/ (province_birth=="Ourense" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Palencia" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Palmas" & destino`i'!="E.T. Zona Canarias" & destino`i'!="F.N.-Z.M. Canarias" & destino`i'!= "E.A. Canarias") | /*
*/ (province_birth=="Pontevedra" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea" & destino`i'!="F.N.-Z.M. Cantabrico") | /*
*/ (province_birth=="Rioja" & destino`i'!="E.T. Region P. Occidental" & destino`i'!="E.A. Tercera Zona Aerea") | /*
*/ (province_birth=="Salamanca" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea")) & destino`i'!=""
replace tratamiento`i'="fuera" if /*
*/ ((province_birth=="Segovia" & destino`i'!="E.T. Region Central" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Sevilla" & destino`i'!="E.T. Region Sur" & destino`i'!="E.A. Segunda Zona Aerea") | /*
*/ (province_birth=="Soria" & destino`i'!="E.T. Region P. Occidental" & destino`i'!="E.A. Tercera Zona Aerea") | /*
*/ (province_birth=="Tarragona" & destino`i'!="E.T. Region P. Oriental" & destino`i'!="E.A. Tercera Zona Aerea" & destino`i'!="F.N.-Z.M. Mediterraneo") | /*
*/ (province_birth=="Tenerife" & destino`i'!="E.T. Zona Canarias" & destino`i'!="F.N.-Z.M. Canarias" & destino`i'!= "E.A. Canarias") | /*
*/ (province_birth=="Teruel" & destino`i'!="E.T. Region P. Oriental" & destino`i'!="E.A. Tercera Zona Aerea") | /*
*/ (province_birth=="Toledo" & destino`i'!="E.T. Region Central" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Valencia" & destino`i'!="E.T. Region Levante" & destino`i'!="E.A. Tercera Zona Aerea" & destino`i'!="F.N.-Z.M. Mediterraneo") | /*
*/ (province_birth=="Valladolid" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Vizcaya" & destino`i'!="E.T. Region P. Occidental" & destino`i'!="E.A. Tercera Zona Aerea" & destino`i'!="F.N.-Z.M. Cantabrico") | /*
*/ (province_birth=="Zamora" & destino`i'!="E.T. Region Noroeste" & destino`i'!="E.A. Primera Zona Aerea") | /*
*/ (province_birth=="Zaragoza" & destino`i'!="E.T. Region P. Oriental" & destino`i'!="E.A. Tercera Zona Aerea")) & destino`i'!=""
replace tratamiento`i'="excedente" if destino`i'=="Excedentes"



gen away`i'=.
replace away`i'=0 if tratamiento`i'=="encasa" | tratamiento`i'=="excedente"
replace away`i'=1 if tratamiento`i'=="fuera"
gen excedente`i'=.
replace excedente`i'=0 if tratamiento`i'!=""
replace excedente`i'=1 if tratamiento`i'=="excedente"
}


foreach i in away excedente {
egen `i' = rowmean(`i'1 `i'2 `i'3 `i'4 `i'5 `i'6 `i'7 `i'8 `i'9 `i'10 `i'11 `i'12 `i'13 `i'14 `i'15 `i'16 `i'17 `i'18 `i'19 `i'20 /*
*/ `i'21 `i'22 `i'23 `i'24 `i'25 `i'26 `i'27 `i'28 `i'29 `i'30 `i'31)
}
*egen tag=tag(IDENTPERS)
forvalues i=1(1)31 {
drop fecha_nacimiento`i' destino`i' cuerpo`i' tratamiento`i' away`i' excedente`i'
}
save "$data/census/census with lottery info.dta", replace




