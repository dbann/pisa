
***meta analysis of gender differences  in physical activity

	local outcomes_days "paclass modd vigd"
	foreach var of local outcomes_days {
	use "$output/`var'_bysex.dta", clear  

	clonevar q0_b = _0_`var'_mean_b

	gen category = "`var'"
	if category == "paclass" {
		label var q0_b "In school physical education classes, days/week"
		}
		
	else if category ==  "modd" {
	label var q0_b "Out of school moderate activity (60mins+), days/week"
	}
	
	else if category ==  "vigd" {
	label var q0_b "Out of school vigorous activity (20mins+), days/week"
	}
	
	else if category ==  "paclass_hours" {
	label var q0_b "In school physical education classes, hours/week"
	}
	
	else if category ==  "paclass_madj" {
	label var q0_b "In school physical education classes, minutes/week"
	}
	


label define  cntryid  8  "Albania"    12  "Algeria"    32  "Argentina"    36  "Australia"    40  "Austria"    ///
56  "Belgium"    76  "Brazil"    100  "Bulgaria"    124  "Canada"    152  "Chile"    158  "Chinese Taipei"    ///
170  "Colombia"    188  "Costa Rica"    191  "Croatia"    196  "Cyprus"    203  "Czech Republic"    208  "Denmark"    ///
214  "Dominican Republic"    233  "Estonia"    246  "Finland"    250  "France"    268  "Georgia"    276  "Germany"    /// 
300  "Greece"    344  "Hong Kong"    348  "Hungary"    352  "Iceland"    360  "Indonesia"    372  "Ireland"    ///
376  "Israel"    380  "Italy"    392  "Japan"    398  "Kazakhstan"    400  "Jordan"    410  "Korea"    ///
411  "Kosovo"    422  "Lebanon"    428  "Latvia"    440  "Lithuania"    442  "Luxembourg"    446  "Macao"    ///
458  "Malaysia"    470  "Malta"    484  "Mexico"    498  "Moldova"    499  "Montenegro"    528  "Netherlands"    ///
554  "New Zealand"    578  "Norway"    604  "Peru"    616  "Poland"    620  "Portugal"    630  "Puerto Rico (USA)"   ///
 634  "Qatar"    642  "Romania"    643  "Russian Federation"    702  "Singapore"    703  "Slovakia"   ///
 704  "Vietnam"    705  "Slovenia"    724  "Spain"    725  "Spain (Regions)"    752  "Sweden"    756  "Switzerland"  ///
 764  "Thailand"    780  "Trinidad and Tobago"    784  "United Arab Emirates"    788  "Tunisia"    792  "Turkey"   ///
 807  "fyrom"    826  "United Kingdom"    827  "United Kingdom - excl. Scotland"    828  "Scotland"    840  "United States"  ///
 858  "Uruguay"    970  "B-S-J-G (China)"    971  "Spain (Regions)"    972  "USA (Massachusetts)"    973  "USA (North Carolina)"  ///
 974  "Argentina (Ciudad Autónoma de Buenos)"  , modify
cap drop country
generate country = real(cntryid) 
label  values  country  cntryid

****create indicators for particular groupings
generate region=.

***WHO European Region B/C (combined)
foreach x in 100 233 348 428 440 499 616 643 703 792{
replace region = 1 if country==`x' 
}

***WHO European Region A
foreach x in 40 56 191 203 208 246 250 276 300 352 372 376 442 528 578 620 ///
			705 724 752 756 826 {
replace region = 2 if country==`x' 
}

***WHO Region of the Americas AMR A
foreach x in 124 840{
replace region = 3 if country==`x' 
}

***WHO Region of the Americas AMR B/C
foreach x in 76 152 170 188 214 484 604 858{
replace region = 4 if country==`x' 
}

***WHO South-East Asian & Western Pacific Region Regions (combined)
foreach x in 36 158 344 392 410 554 702 764{
replace region = 5 if country==`x' 
}

***WHO Eastern Mediterranean Region
foreach x in 634 784 788  {
replace region = 6 if country==`x' 
}

tab region

label define region2lbl 6 "Eastern Mediterranean " 5 "SE Asian + Pacific" 4 "Americas B/C" 3 "Americas A" 2 "Europe A" 1 "Europe B/C"
label values region region2lbl

**conduct meta analyses and export plot
cap drop gap 
generate gap = _0_`var'_mean_b - _1_`var'_mean_b

sort region gap

metan _1_`var'_N_b _1_`var'_mean_b _1_`var'_sd_b _0_`var'_N_b _0_`var'_mean_b _0_`var'_sd_b , ///
		by(region) label(namevar=country) graphregion(color(white))  nowt ///
		xlabel(-2,-1, 0, 1, 2) texts(250) ///
		favours( Females more active # Males more active) effect(Mean difference) ///
		subtitle("`: variable label q0_b'", position(6) size(vsmall)) nostandard

graph export "$output/`var'_forrest_genderdiff.tif", width(2700) height(2100) replace
}





***meta analysis of WEALTH differences in physical activity
	global sex female male // Define macro for each sex

	foreach s of global sex{
	local outcomes_days "paclass modd vigd"
	foreach var of local outcomes_days {
	use "$output/`var'_wealthq_`s'.dta", clear 

	clonevar q0_b = _1_`var'_mean_b

	gen category = "`var'"
	if category == "paclass" {
		label var q0_b "In school physical education classes, days/week"
		}
		
	else if category ==  "modd" {
	label var q0_b "Out of school moderate activity (60mins+), days/week"
	}
	
	else if category ==  "vigd" {
	label var q0_b "Out of school vigorous activity (20mins+), days/week"
	}
	
	else if category ==  "paclass_hours" {
	label var q0_b "In school physical education classes, hours/week"
	}
	
	else if category ==  "paclass_madj" {
	label var q0_b "In school physical education classes, minutes/week"
	}
	


label define  cntryid  8  "Albania"    12  "Algeria"    32  "Argentina"    36  "Australia"    40  "Austria"    ///
56  "Belgium"    76  "Brazil"    100  "Bulgaria"    124  "Canada"    152  "Chile"    158  "Chinese Taipei"    ///
170  "Colombia"    188  "Costa Rica"    191  "Croatia"    196  "Cyprus"    203  "Czech Republic"    208  "Denmark"    ///
214  "Dominican Republic"    233  "Estonia"    246  "Finland"    250  "France"    268  "Georgia"    276  "Germany"    /// 
300  "Greece"    344  "Hong Kong"    348  "Hungary"    352  "Iceland"    360  "Indonesia"    372  "Ireland"    ///
376  "Israel"    380  "Italy"    392  "Japan"    398  "Kazakhstan"    400  "Jordan"    410  "Korea"    ///
411  "Kosovo"    422  "Lebanon"    428  "Latvia"    440  "Lithuania"    442  "Luxembourg"    446  "Macao"    ///
458  "Malaysia"    470  "Malta"    484  "Mexico"    498  "Moldova"    499  "Montenegro"    528  "Netherlands"    ///
554  "New Zealand"    578  "Norway"    604  "Peru"    616  "Poland"    620  "Portugal"    630  "Puerto Rico (USA)"   ///
 634  "Qatar"    642  "Romania"    643  "Russian Federation"    702  "Singapore"    703  "Slovakia"   ///
 704  "Vietnam"    705  "Slovenia"    724  "Spain"    725  "Spain (Regions)"    752  "Sweden"    756  "Switzerland"  ///
 764  "Thailand"    780  "Trinidad and Tobago"    784  "United Arab Emirates"    788  "Tunisia"    792  "Turkey"   ///
 807  "fyrom"    826  "United Kingdom"    827  "United Kingdom - excl. Scotland"    828  "Scotland"    840  "United States"  ///
 858  "Uruguay"    970  "B-S-J-G (China)"    971  "Spain (Regions)"    972  "USA (Massachusetts)"    973  "USA (North Carolina)"  ///
 974  "Argentina (Ciudad Autónoma de Buenos)"  , modify
cap drop country
generate country = real(cntryid) 
label  values  country  cntryid

****create indicators for particular groupings
generate region=.

***WHO European Region B/C (combined)
foreach x in 100 233 348 428 440 499 616 643 703 792{
replace region = 1 if country==`x' 
}

***WHO European Region A
foreach x in 40 56 191 203 208 246 250 276 300 352 372 376 442 528 578 620 ///
			705 724 752 756 826 {
replace region = 2 if country==`x' 
}

***WHO Region of the Americas AMR A
foreach x in 124 840{
replace region = 3 if country==`x' 
}

***WHO Region of the Americas AMR B/C
foreach x in 76 152 170 188 214 484 604 858{
replace region = 4 if country==`x' 
}

***WHO South-East Asian & Western Pacific Region Regions (combined)
foreach x in 36 158 344 392 410 554 702 764{
replace region = 5 if country==`x' 
}

***WHO Eastern Mediterranean Region
foreach x in 634 784 788  {
replace region = 6 if country==`x' 
}

tab region

label define region2lbl 6 "Eastern Mediterranean " 5 "SE Asian + Pacific" 4 "Americas B/C" 3 "Americas A" 2 "Europe A" 1 "Europe B/C"
label values region region2lbl

**conduct meta analyses and export plot
cap drop gap 
generate gap = _1_`var'_mean_b - _5_`var'_mean_b

sort region gap

metan _5_`var'_N_b _5_`var'_mean_b _5_`var'_sd_b _1_`var'_N_b _1_`var'_mean_b _1_`var'_sd_b , ///
		by(region) label(namevar=country) graphregion(color(white))  nowt ///
		xlabel(-2,-1, 0, 1, 2) texts(250) ///
		favours( low SES more active # High SES more active) effect(Mean difference) ///
		subtitle("`: variable label q0_b', `s'", position(6) size(vsmall)) nostandard

graph export "$output/`var'_wealth_`s'_forrest.tif", width(2700) height(2100) replace
}
}

