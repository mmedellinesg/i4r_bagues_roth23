
********************************************************************************
**********We read data on the military service lottery, years 1987-1991*********
********************************************************************************


**Note: I need to add data for individuals born in September-December 1968
*who were assigned according to the lottery of 1987, together with individuals born in 1969
*I create another file with the dates for this cohort and I add it to the main file

clear
insheet using "$data/lottery military service/fechas.txt"
drop if fechas==""
replace anyo=anyo[_n-1] if anyo==.
keep if anyo==1987
recode anyo (1987=1986)
save "$data/lottery military service/fechas 1968.dta", replace

clear
insheet using "$data/lottery military service/fechas.txt"
append using "$data/lottery military service/fechas 1968.dta"
erase "$data/lottery military service/fechas 1968.dta"

rename anyo anyo_sorteo
drop if fechas==""
replace anyo=anyo[_n-1] if anyo==.
replace provincia=provincia[_n-1] if provincia==""
drop if word(fechas,1)=="Cubierto"
drop if provincia=="C.R. Extranjero"


gen provi=word(fechas,1)
gen provi_real=real(provi)

gen format=""
replace format="day month - day month" if provi_real!=.
replace format="month day - month day" if provi_real==.

drop provi provi_real

gen dia_inicio_string=""
gen mes_inicio_string=""
gen dia_final_string=""
gen mes_final_string=""

replace dia_inicio_string=word(fechas,1) if format=="day month - day month"
replace mes_inicio_string=word(fechas,2) if format=="day month - day month"
replace dia_final_string=word(fechas,4) if format=="day month - day month"
replace mes_final_string=word(fechas,5) if format=="day month - day month"

replace dia_inicio_string=word(fechas,2) if format=="month day - month day" 
replace mes_inicio_string=word(fechas,1) if format=="month day - month day"
replace dia_final_string=word(fechas,5) if format=="month day - month day"
replace mes_final_string=word(fechas,4) if format=="month day - month day"

gen dia_inicio=real(dia_inicio_string)
gen mes_inicio=real(mes_inicio_string)
replace mes_inicio_string=lower(mes_inicio_string)
replace mes_inicio=1 if index(mes_inicio_string,"ene")!=0
replace mes_inicio=2 if index(mes_inicio_string,"feb")!=0
replace mes_inicio=3 if index(mes_inicio_string,"mar")!=0
replace mes_inicio=4 if index(mes_inicio_string,"abr")!=0
replace mes_inicio=5 if index(mes_inicio_string,"may")!=0
replace mes_inicio=6 if index(mes_inicio_string,"jun")!=0
replace mes_inicio=7 if index(mes_inicio_string,"jul")!=0
replace mes_inicio=8 if index(mes_inicio_string,"ago")!=0
replace mes_inicio=9 if index(mes_inicio_string,"sep")!=0
replace mes_inicio=10 if index(mes_inicio_string,"oct")!=0
replace mes_inicio=11 if index(mes_inicio_string,"nov")!=0
replace mes_inicio=12 if index(mes_inicio_string,"dic")!=0

gen dia_final=real(dia_final_string)
gen mes_final=real(mes_final_string)
replace mes_final_string=lower(mes_final_string)
replace mes_final=1 if index(mes_final_string,"ene")!=0
replace mes_final=2 if index(mes_final_string,"feb")!=0
replace mes_final=3 if index(mes_final_string,"mar")!=0
replace mes_final=4 if index(mes_final_string,"abr")!=0
replace mes_final=5 if index(mes_final_string,"may")!=0
replace mes_final=6 if index(mes_final_string,"jun")!=0
replace mes_final=7 if index(mes_final_string,"jul")!=0
replace mes_final=8 if index(mes_final_string,"ago")!=0
replace mes_final=9 if index(mes_final_string,"sep")!=0
replace mes_final=10 if index(mes_final_string,"oct")!=0
replace mes_final=11 if index(mes_final_string,"nov")!=0
replace mes_final=12 if index(mes_final_string,"dic")!=0

drop  dia_inicio_string-mes_final_string
gen anyo_nacimiento=anyo_sorteo-18


gen fecha_inicio=mdy(mes_inicio,dia_inicio,anyo_nacimiento)
gen fecha_final=mdy(mes_final,dia_final,anyo_nacimiento)

format fecha_inicio %d
format fecha_final %d

*we need to avoid that the initial and final dates coincide

gen orden=_n


sort orden
replace fecha_inicio=fecha_inicio+1 if mes_inicio==mes_final[_n-1] & dia_inicio==dia_final[_n-1] & provincia==provincia[_n-1]
replace fecha_final=fecha_final-1 if mes_final==mes_inicio[_n+1] & dia_final==dia_inicio[_n+1] & provincia==provincia[_n+1]
gen borrar=0
replace borrar=1 if  fecha_final<fecha_inicio & fecha_final+2>=fecha_inicio
replace fecha_final=. if borrar==1
replace fecha_inicio=. if borrar==1
drop borrar

replace mes_inicio=month(fecha_inicio)
replace dia_inicio=day(fecha_inicio)
replace mes_final=month(fecha_final)
replace dia_final=day(fecha_final)

************************************************************************
*****************CLASIFICAMOS EL DESTINO********************************
************************************************************************

gen cuerpo=""
replace cuerpo="Exento" if destino=="Excedentes"
replace cuerpo="Tierra" if index(destino,"E.T.")!=0
replace cuerpo="Mar" if index(destino,"F.N.")!=0
replace cuerpo="Aire" if index(destino,"E.A.")!=0

gen tratamiento="encasa"
replace tratamiento="fuera" if /*
*/ (provincia=="Alava" & destino!="E.T. Region P. Occidental" & destino!="E.A. Tercera Zona Aerea") | /*
*/ (provincia=="Albacete" & destino!="E.T. Region Levante" & destino!="E.A. Segunda Zona Aerea") | /*
*/ (provincia=="Asturias" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea" & destino!="F.N.-Z.M. Cantabrico") | /*
*/ (provincia=="Alicante" & destino!="E.T. Region Levante" & destino!="E.A. Segunda Zona Aerea" & destino!="F.N.-Z.M. Mediterraneo") | /*
*/ (provincia=="Almeria" & destino!="E.T. Region Sur" & destino!="E.A. Segunda Zona Aerea" & destino!="F.N.-Z.M. Estrecho") | /*
*/ (provincia=="Avila" & destino!="E.T. Region Central" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Badajoz" & destino!="E.T. Region Central" & destino!="E.A. Segunda Zona Aerea") | /*
*/ (provincia=="Baleares" & destino!="E.T. Zona Baleares" & destino!="E.A. Tercera Zona Aerea" & destino!="F.N.-Z.M. Mediterraneo") | /*
*/ (provincia=="Barcelona" & destino!="E.T. Region P. Oriental" & destino!="E.A. Tercera Zona Aerea" & destino!="F.N.-Z.M. Mediterraneo") | /*
*/ (provincia=="Burgos" & destino!="E.T. Region P. Occidental" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Caceres" & destino!="E.T. Region Central" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Cadiz" & destino!="E.T. Region Sur" & destino!="E.A. Segunda Zona Aerea" & destino!="F.N.-Z.M. Estrecho") | /*
*/ (provincia=="Cantabria" & destino!="E.T. Region P. Occidental" & destino!="E.A. Primera Zona Aerea" & destino!="F.N.-Z.M. Cantabrico")
replace tratamiento="fuera" if /*
*/ (provincia=="Castellon" & destino!="E.T. Region Levante" & destino!="E.A. Tercera Zona Aerea" & destino!="F.N.-Z.M. Mediterraneo") | /*
*/ (provincia=="Ceuta" & destino!="E.T. Region Sur (Ceuta)" & destino!="E.A. Segunda Zona Aerea" & destino!="F.N.-Z.M. Estrecho") | /*
*/ (provincia=="Ciudad Real" & destino!="E.T. Region Central" & destino!="E.A. Segunda Zona Aerea") | /*
*/ (provincia=="Cordoba" & destino!="E.T. Region Sur" & destino!="E.A. Segunda Zona Aerea") | /*
*/ (provincia=="Coruña" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea" & destino!="F.N.-Z.M. Cantabrico") | /*
*/ (provincia=="Cuenca" & destino!="E.T. Region Central" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Girona" & destino!="E.T. Region P. Oriental" & destino!="E.A. Tercera Zona Aerea" & destino!="F.N.-Z.M. Mediterraneo") | /*
*/ (provincia=="Granada" & destino!="E.T. Region Sur" & destino!="E.A. Segunda Zona Aerea" & destino!="F.N.-Z.M. Estrecho") | /*
*/ (provincia=="Guadalajara" & destino!="E.T. Region Central" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Guipuzcoa" & destino!="E.T. Region P. Occidental" & destino!="E.A. Tercera Zona Aerea" & destino!="F.N.-Z.M. Cantabrico") | /*
*/ (provincia=="Huelva" & destino!="E.T. Region Sur" & destino!="E.A. Segunda Zona Aerea" & destino!="F.N.-Z.M. Estrecho") | /*
*/ (provincia=="Huesca" & destino!="E.T. Region P. Oriental" & destino!="E.A. Tercera Zona Aerea") | /*
*/ (provincia=="Jaen" & destino!="E.T. Region Sur" & destino!="E.A. Segunda Zona Aerea")
replace tratamiento="fuera" if /*
*/ (provincia=="Leon" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Lugo" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea" & destino!="F.N.-Z.M. Cantabrico") | /*
*/ (provincia=="Lleida" & destino!="E.T. Region P. Oriental" & destino!="E.A. Tercera Zona Aerea" & destino!="F.N.-Z.M. Mediterraneo") | /*
*/ (provincia=="Madrid" & destino!="E.T. Region Central" & destino!="E.A. Primera Zona Aerea" & destino!="F.N. Jurisdiccion Central") | /*
*/ (provincia=="Malaga" & destino!="E.T. Region Sur" & destino!="E.A. Segunda Zona Aerea" & destino!="F.N.-Z.M. Estrecho") | /*
*/ (provincia=="Melilla" & destino!="E.T. Region Sur (Melilla)" & destino!="E.A. Segunda Zona Aerea" & destino!="F.N.-Z.M. Estrecho") | /*
*/ (provincia=="Murcia" & destino!="E.T. Region Levante" & destino!="E.A. Segunda Zona Aerea" & destino!="F.N.-Z.M. Mediterraneo") | /*
*/ (provincia=="Navarra" & destino!="E.T. Region P. Occidental" & destino!="E.A. Tercera Zona Aerea") | /*
*/ (provincia=="Ourense" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Palencia" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Palmas" & destino!="E.T. Zona Canarias" & destino!="E.A. Zona Aerea Canarias" & destino!="F.N.-Z.M. Canarias") | /*
*/ (provincia=="Pontevedra" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea" & destino!="F.N.-Z.M. Cantabrico") | /*
*/ (provincia=="Rioja" & destino!="E.T. Region P. Occidental" & destino!="E.A. Tercera Zona Aerea") | /*
*/ (provincia=="Salamanca" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea")
replace tratamiento="fuera" if /*
*/ (provincia=="Segovia" & destino!="E.T. Region Central" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Sevilla" & destino!="E.T. Region Sur" & destino!="E.A. Segunda Zona Aerea") | /*
*/ (provincia=="Soria" & destino!="E.T. Region P. Occidental" & destino!="E.A. Tercera Zona Aerea") | /*
*/ (provincia=="Tarragona" & destino!="E.T. Region P. Oriental" & destino!="E.A. Tercera Zona Aerea" & destino!="F.N.-Z.M. Mediterraneo") | /*
*/ (provincia=="Tenerife" & destino!="E.T. Zona Canarias" & destino!="E.A. Zona Aerea Canarias" & destino!="F.N.-Z.M. Canarias") | /*
*/ (provincia=="Teruel" & destino!="E.T. Region P. Oriental" & destino!="E.A. Tercera Zona Aerea") | /*
*/ (provincia=="Toledo" & destino!="E.T. Region Central" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Valencia" & destino!="E.T. Region Levante" & destino!="E.A. Tercera Zona Aerea" & destino!="F.N.-Z.M. Mediterraneo") | /*
*/ (provincia=="Valladolid" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Vizcaya" & destino!="E.T. Region P. Occidental" & destino!="E.A. Tercera Zona Aerea" & destino!="F.N.-Z.M. Cantabrico") | /*
*/ (provincia=="Zamora" & destino!="E.T. Region Noroeste" & destino!="E.A. Primera Zona Aerea") | /*
*/ (provincia=="Zaragoza" & destino!="E.T. Region P. Oriental" & destino!="E.A. Tercera Zona Aerea")
replace tratamiento="excedente" if destino=="Excedentes"


save "$data/lottery military service/mili.dta", replace


**metemos codigos provincias
clear
insheet using "$data/lottery military service/provincia-codigo_provincia.txt"
drop provincia
rename nombre provincia
sort provincia
save "$data/lottery military service/provincia-codigo_provincia.dta", replace

clear
use "$data/lottery military service/mili.dta"
sort provincia
merge provincia using "$data/lottery military service/provincia-codigo_provincia.dta"
erase "$data/lottery military service/provincia-codigo_provincia.dta"
drop _
save "$data/lottery military service/mili.dta", replace

clear
use "$data/lottery military service/mili.dta"
erase "$data/lottery military service/mili.dta"
keep  anyo_nacimiento codigo_provincia provincia destino fecha_inicio fecha_final
rename fecha_inicio inicio_
rename fecha_final final_

replace destino="primera_aerea" if destino=="E.A. Primera Zona Aerea"
replace destino="segunda_aerea" if destino=="E.A. Segunda Zona Aerea"
replace destino="tercera_aerea" if destino=="E.A. Tercera Zona Aerea"
replace destino="canarias_aerea" if destino=="E.A. Zona Aerea Canarias"
replace destino="central_tierra" if destino=="E.T. Region Central"
replace destino="levante_tierra" if destino=="E.T. Region Levante"
replace destino="noroeste_tierra" if destino=="E.T. Region Noroeste"
replace destino="occidental_tierra" if destino=="E.T. Region P. Occidental"
replace destino="oriental_tierra" if destino=="E.T. Region P. Oriental"
replace destino="sur_tierra" if destino=="E.T. Region Sur"
replace destino="ceuta_tierra" if destino=="E.T. Region Sur (Ceuta)"
replace destino="melilla_tierra" if destino=="E.T. Region Sur (Melilla)"
replace destino="baleares_tierra" if destino=="E.T. Zona Baleares"
replace destino="canarias_tierra" if destino=="E.T. Zona Canarias"
replace destino="excedentes" if destino=="Excedentes"
replace destino="central_naval" if destino=="F.N. Jurisdiccion Central"
replace destino="canarias_naval" if destino=="F.N. Z.M. Canarias"
replace destino="cantabrico_naval" if destino=="F.N. Z.M. Cantabrico"
replace destino="estrecho_naval" if destino=="F.N. Z.M. Estrecho"
replace destino="mediterraneo_naval" if destino=="F.N. Z.M. Mediterraneo"
reshape wide inicio final, i(provincia anyo_nacimiento) j(destino) string
rename anyo_nacimiento year_birth
rename provincia province_birth
rename codigo_provincia province_code_birth
save "$data/lottery military service/mili_wide.dta", replace
