///////   Syntax to conduct analyses to reproduce Bann et al. (paper using physical activity data from PISA 2015)
///////   Last updated: 30/10/2019

///////   Before starting, first run cleaning/derivation do file 
///////   Download auxiliary data sets from https://github.com/dbann/pisa
///////   These datasets are: "lookup_code_abbcountry.dta", "wbank_selected_variables.dta", "pisa_unesco1.dta", "whoob.dta" and "whopa.dta"			
///////   These should be placed in the 'data' folder/pathway listed below

this line of code prevents one from accidentally running from the begining


///////   Make sure to change directories to your own machine
********************************************************************************
global data "YOUR FILE PATH FOR SOURCE DATA HERE"
global output "YOUR FILE PATH FOR OUTPUT HERE"
********************************************************************************



/////// Install 'repest', the user written package for analysing large scale assessment data
/////// Avvisati F, Keslair F. REPEST: Stata module to run estimations with weighted replicate samples and plausible values. 2017

ssc install repest

/////// Install 'labutil', the user written package for managing value and variable labels
/////// Cox, N. 'LABUTIL': modules for managing value and variable labels. 2013

ssc install labutil

/////// Install 'sdecode', the user written package for decoding string variable 
/////// Newson, R. 'SDECODE'. 2013

ssc install sdecode


///////   Output datafiles for descriptive comparisons of physical activity outcomes

*** Set a global macro for outcomes
global outcomes ///
	paclass paclass_madj paclass_hours modd vigd paclass_3plus modd_5plus vigd_5plus // This will loop over all outcomes.

*Both genders combined 
use "$data/pisa2015_recoded_clean_v001.dta", clear
foreach var of global outcomes {                                                
repest PISA , estimate(summarize `var' if allpa==1, stats(mean p50 sd  N )) by(cntryid) results(add (N)) outfile("$output/`var'_bothgenders.dta")
}

*Gender differences
foreach var of global outcomes {                                                
repest PISA , estimate(summarize `var' if allpa==1, stats(mean p50 sd  N )) over(sex)  by(cntryid) results(add (N)) outfile("$output/`var'_bysex.dta")
}

*SES differences - output files by diff SES groups, both genders and seperately by gender
foreach ses of varlist wealthq {

	***Both genders combined
	foreach var of global outcomes {                                                
	repest PISA , estimate(summarize `var'  if allpa==1, stats(mean p50 sd  N )) over(`ses')  by(cntryid) results(add (N)) outfile("$output/`var'_`ses'_bothgenders.dta")
	}

	***SES in women
	foreach var of global outcomes {                                                
	repest PISA , estimate(summarize `var'  if allpa==1 & sex==0, stats(mean p50 sd  N )) over(`ses')  by(cntryid) results(add (N)) outfile("$output/`var'_`ses'_female.dta")
	}

	***SES in men
	foreach var of global outcomes {                                                
	repest PISA , estimate(summarize `var' if allpa==1 & sex==1, stats(mean p50 sd  N )) over(`ses')  by(cntryid) results(add (N)) outfile("$output/`var'_`ses'_male.dta")
	}
	}

	
***Output Ns
***PA data
use "$output/paclass_bothgenders.dta", clear
sum  paclass_N_b
sum  paclass_N_b, detail

***PA + SES data:
use "$output/paclass_wealthq_bothgenders.dta", clear
gen  n = _1_paclass_N_b + _2_paclass_N_b + _3_paclass_N_b + _4_paclass_N_b + _5_paclass_N_b
sum n, detail





///////   Output frequency counts to show distribution of PA variables for histograms

*both genders combined
use "$data/pisa2015_recoded_clean_v001.dta", clear
foreach var of global outcomes {                                                
repest PISA , estimate(freq  `var' if allpa==1) by(cntryid) outfile("$output/freq_`var'_bothgenders.dta")
}

*by genders
foreach var of global outcomes {                                                
repest PISA , estimate(freq  `var' if allpa==1) by(cntryid) over(sex) results(add (N)) outfile("$output/freq_`var'_bysex.dta")
}

*by ses
foreach var of global outcomes {                                                
repest PISA , estimate(freq  `var' if allpa==1) by(cntryid) over(wealthq) results(add (N)) outfile("$output/freq_`var'_bywealth.dta")
}



///////  Analyse correlation between PISA 2015 physical activity data and WHO physical inactivity estimates among adolescents 
**source WHO data obtained here, and converted to stata format for below analyses http://apps.who.int/gho/data/node.main.A893ADO?lang=en

**Use summary PISA data for both genders
use "$output/vigd_bothgenders.dta", clear

merge 1:1 cntryid using "$output/modd_bothgenders.dta"
cap drop _merge
merge 1:1 cntryid using "$output/paclass_bothgenders.dta"
cap drop _merge

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

*create identifier to merge with WHO PA data
cap drop id
cap drop _merge

decode country, generate(id)
desc id 

***Merge with data from WHO
****This data is available at: https://github.com/dbann/pisa
cap drop _merge
merge m:m id using "$data/whopa.dta", force //need force as 
clonevar whopa = insufficientlyactive1117yin
destring whopa, replace

***check correlation
corr whopa **_mean_b  
spearman whopa **_mean_b  



///////   Results for paper

///////   Figures 1, 2, and 3
///////   Gender
	local outcomes_days "paclass modd vigd"
	foreach var of local outcomes_days {
	use "$output/`var'_bysex.dta", clear  
	
	
	*make generalisable graph names
	clonevar q0_b = _0_`var'_mean_b
	clonevar q1_b = _1_`var'_mean_b

	clonevar q0_se = _0_`var'_mean_se
	clonevar q1_se = _1_`var'_mean_se

	*gen 95% CI
	gen q0_lci = q0_b - (_0_`var'_mean_se *1.99)
	gen q0_uci = q0_b + (_0_`var'_mean_se *1.99)
	sum   q0_lci q0_b q0_uci

	**gen 95CI CI

	gen q1_lci = q1_b - (_1_`var'_mean_se *1.99)
	gen q1_uci = q1_b + (_1_`var'_mean_se *1.99)
	sum   q1_lci q1_b q1_uci
	

	** Label variables for graph axes
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
 807  "fyrom"    826  "United Kingdom"    827  "United Kingdom - excl. Scotland"    828  "Scotland"    840  "USA"  ///
 858  "Uruguay"    970  "B-S-J-G (China)"    971  "Spain (Regions)"    972  "USA (Massachusetts)"    973  "USA (North Carolina)"  ///
 974  "Argentina (Ciudad Autónoma de Buenos)"  , modify
  
cap drop country
generate country = real(cntryid) 
label  values  country  cntryid

****create indicators for particular groupings
generate region=.




***WHO European Region B/C (combined)
foreach x in 100 233 348 428 440 499 616 643 703 792{
replace region = 6 if country==`x' 
}

***WHO European Region A
foreach x in 40 56 191 203 208 246 250 276 300 352 372 376 442 528 578 620 ///
			705 724 752 756 826 {
replace region = 5 if country==`x' 
}

***WHO Region of the Americas AMR A
foreach x in 124 840{
replace region = 4 if country==`x' 
}

***WHO Region of the Americas AMR B/C
foreach x in 76 152 170 188 214 484 604 858{
replace region = 3 if country==`x' 
}

***WHO South-East Asian & Western Pacific Region Regions (combined)
foreach x in 36 158 344 392 410 554 702 764{
replace region = 2 if country==`x' 
}

***WHO Eastern Mediterranean Region
foreach x in 634 784 788  {
replace region = 1 if country==`x' 
}

*Gender diff plots
drop if missing(q0_b)

sort region q0_b

cap drop n
gen n = _n if !missing(q0_b)
decode country, generate(country_string)
labmask n, values(country_string)



*Color
twoway (scatter n q0_b , msize(.5) mcolor("red") msymbol(circle)) (rcap q0_lci q0_uci n , horizontal  lcolor("red")  msize(0)  ) ///
	   (scatter n q1_b , msize(.5) mcolor("black") msymbol(triangle)) (rcap q1_lci q1_uci n , horizontal  lcolor("black")  msize(0)) ///
	   , ylabel(1(1)52, ang(h) labsize(tiny) valuelabel noticks) legend(off)  ytitle("") xlabel(1(1)5.5) ///
	   graphregion(color(white)) xtitle("`: variable label q0_b'") ///
	   	   yline(3.5 11.5 19.5 21.5 42.5, lpattern(dash)  lcolor(gray)  )  aspectratio(1.5) 
		   graph export "$output/Fig1_`var'_bysex_color.eps",   replace	  
	}
	
	
	
						   
///////   SES
	global sex female male // Define macro for each sex

	foreach s of global sex{
	local outcomes_days "paclass modd vigd"
	foreach var of local outcomes_days {

	use "$output/`var'_wealthq_`s'.dta", clear 

	*make generalisable graph names
	clonevar q0_b = _1_`var'_mean_b
	clonevar q5_b = _5_`var'_mean_b

	clonevar q0_se = _1_`var'_mean_se
	clonevar q5_se = _5_`var'_mean_se

	*gen 95% CI
	gen q0_lci = q0_b - (_1_`var'_mean_se *1.99)
	gen q0_uci = q0_b + (_1_`var'_mean_se *1.99)
	sum   q0_lci q0_b q0_uci

	**gen 95CI CI

	gen q5_lci = q5_b - (_5_`var'_mean_se *1.99)
	gen q5_uci = q5_b + (_5_`var'_mean_se *1.99)
	sum   q5_lci q5_b q5_uci

	** Label variables for graph axes
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
 807  "fyrom"    826  "United Kingdom"    827  "United Kingdom - excl. Scotland"    828  "Scotland"    840  "USA"  ///
 858  "Uruguay"    970  "B-S-J-G (China)"    971  "Spain (Regions)"    972  "USA (Massachusetts)"    973  "USA (North Carolina)"  ///
 974  "Argentina (Ciudad Autónoma de Buenos)"  , modify
  
cap drop country
generate country = real(cntryid) 
label  values  country  cntryid

****create indicators for particular groupings
generate region=.


***WHO European Region B/C (combined)
foreach x in 100 233 348 428 440 499 616 643 703 792{
replace region = 6 if country==`x' 
}

***WHO European Region A
foreach x in 40 56 191 203 208 246 250 276 300 352 372 376 442 528 578 620 ///
			705 724 752 756 826 {
replace region = 5 if country==`x' 
}

***WHO Region of the Americas AMR A
foreach x in 124 840{
replace region = 4 if country==`x' 
}

***WHO Region of the Americas AMR B/C
foreach x in 76 152 170 188 214 484 604 858{
replace region = 3 if country==`x' 
}

***WHO South-East Asian & Western Pacific Region Regions (combined)
foreach x in 36 158 344 392 410 554 702 764{
replace region = 2 if country==`x' 
}

***WHO Eastern Mediterranean Region
foreach x in 634 784 788  {
replace region = 1 if country==`x' 
}

*SES diff plots
drop if missing(q5_b)

sort region q5_b
list region cntryid country if !missing(q5_b)
cap drop n
gen n = _n if !missing(q5_b)
decode country, generate(country_string)
labmask n, values(country_string)


*Plots
*Color
twoway (scatter n q0_b , msize(.5) mcolor("red") msymbol(circle))  (rcap q0_lci q0_uci n , horizontal  lcolor("red")  msize(0)  ) ///
	   (scatter n q5_b , msize(.5) mcolor("black") msymbol(triangle))  (rcap q5_lci q5_uci n , horizontal  lcolor("black")  msize(0)) ///
	   , ylabel(1(1)52, ang(h) labsize(tiny) valuelabel noticks) legend(off)  ytitle("") xlabel(1(1)5.5) ///
	   graphregion(color(white)) xtitle("`: variable label q0_b', `s'") ///
	   	   yline(3.5 11.5 19.5 21.5 42.5, lpattern(dash)  lcolor(gray)  )  aspectratio(1.5) 
		   graph export "$output/Figs3_4_`var'_wealth_`s'_color.eps", replace	   
		   }
			}
			
  			

///////Figures 1,3,4 with binary prevalence measures (5+ days a week)

///Gender graphs	
local prevalence "paclass_3plus modd_5plus vigd_5plus"		
foreach var of local prevalence {
use "$output/`var'_bysex.dta",clear
*make generalisable graph names
	clonevar q0_b = _0_`var'_mean_b
	clonevar q1_b = _1_`var'_mean_b
	

	clonevar q0_se = _0_`var'_mean_se
	clonevar q1_se = _1_`var'_mean_se

	*gen 95% CI
	gen q0_lci = q0_b - (_0_`var'_mean_se *1.99)
	gen q0_uci = q0_b + (_0_`var'_mean_se *1.99)
	sum   q0_lci q0_b q0_uci

	**gen 95CI CI

	gen q1_lci = q1_b - (_1_`var'_mean_se *1.99)
	gen q1_uci = q1_b + (_1_`var'_mean_se *1.99)
	sum   q1_lci q1_b q1_uci
	

	** Label variables for graph axes
	gen category = "`var'"
	if category == "paclass_3plus" {
		label var q0_b "Prevalence of in school physical education classes, 5+ days/week"
		}
		
	else if category ==  "modd_5plus" {
	label var q0_b "Prevalence of out of school moderate activity (60mins+), 5+ days/week"
	}
	
	else if category ==  "vigd_5plus" {
	label var q0_b "Prevalence of out of school vigorous activity (20mins+), 5+ days/week"
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
 807  "fyrom"    826  "United Kingdom"    827  "United Kingdom - excl. Scotland"    828  "Scotland"    840  "USA"  ///
 858  "Uruguay"    970  "B-S-J-G (China)"    971  "Spain (Regions)"    972  "USA (Massachusetts)"    973  "USA (North Carolina)"  ///
 974  "Argentina (Ciudad Autónoma de Buenos)"  , modify
  
cap drop country
generate country = real(cntryid) 
label  values  country  cntryid

****create indicators for particular groupings
generate region=.


***WHO European Region B/C (combined)
foreach x in 100 233 348 428 440 499 616 643 703 792{
replace region = 6 if country==`x' 
}

***WHO European Region A
foreach x in 40 56 191 203 208 246 250 276 300 352 372 376 442 528 578 620 ///
			705 724 752 756 826 {
replace region = 5 if country==`x' 
}

***WHO Region of the Americas AMR A
foreach x in 124 840{
replace region = 4 if country==`x' 
}

***WHO Region of the Americas AMR B/C
foreach x in 76 152 170 188 214 484 604 858{
replace region = 3 if country==`x' 
}

***WHO South-East Asian & Western Pacific Region Regions (combined)
foreach x in 36 158 344 392 410 554 702 764{
replace region = 2 if country==`x' 
}

***WHO Eastern Mediterranean Region
foreach x in 634 784 788  {
replace region = 1 if country==`x' 
}

*Gender diff plots
drop if missing(q0_b)

sort region q0_b

cap drop n
gen n = _n if !missing(q0_b)
decode country, generate(country_string)
labmask n, values(country_string)

   
		   
*Color
twoway (scatter n q0_b , msize(.5) mcolor("red") msymbol(circle)) (rcap q0_lci q0_uci n , horizontal  lcolor("red")  msize(0)  ) ///
	   (scatter n q1_b , msize(.5) mcolor("black") msymbol(triangle)) (rcap q1_lci q1_uci n , horizontal  lcolor("black")  msize(0)) ///
	   , ylabel(1(1)52, ang(h) labsize(tiny) valuelabel noticks) legend(off)  ytitle("") xlabel(0(.1).8) ///
	   graphregion(color(white)) xtitle("`: variable label q0_b'") ///
	   	   yline(3.5 11.5 19.5 21.5 42.5, lpattern(dash)  lcolor(gray)  )  aspectratio(1.5) 
		   graph export "$output/`var'_bysex_color.tif", replace	  		   
	}


///////   SES
	global prevalence paclass_3plus modd_5plus vigd_5plus		
	
	foreach var of global prevalence {
	local sex "female male" // Define macro for each sex
	foreach s of local sex{
	
	use "$output/`var'_wealthq_`s'.dta", clear 

	*make generalisable graph names
	clonevar q0_b = _1_`var'_mean_b
	clonevar q5_b = _5_`var'_mean_b

	clonevar q0_se = _1_`var'_mean_se
	clonevar q5_se = _5_`var'_mean_se

	*gen 95% CI
	gen q0_lci = q0_b - (_1_`var'_mean_se *1.99)
	gen q0_uci = q0_b + (_1_`var'_mean_se *1.99)
	sum   q0_lci q0_b q0_uci

	**gen 95CI CI

	gen q5_lci = q5_b - (_5_`var'_mean_se *1.99)
	gen q5_uci = q5_b + (_5_`var'_mean_se *1.99)
	sum   q5_lci q5_b q5_uci

	** Label variables for graph axes
	** Label variables for graph axes
	gen category = "`var'"
	if category == "paclass_3plus" {
		label var q0_b "Prevalence of in school physical education classes, 5+ days/week"
		}
		
	else if category ==  "modd_5plus" {
	label var q0_b "Prevalence of out of school moderate activity (60mins+), 5+ days/week"
	}
	
	else if category ==  "vigd_5plus" {
	label var q0_b "Prevalence of out of school vigorous activity (20mins+), 5+ days/week"
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
 807  "fyrom"    826  "United Kingdom"    827  "United Kingdom - excl. Scotland"    828  "Scotland"    840  "USA"  ///
 858  "Uruguay"    970  "B-S-J-G (China)"    971  "Spain (Regions)"    972  "USA (Massachusetts)"    973  "USA (North Carolina)"  ///
 974  "Argentina (Ciudad Autónoma de Buenos)"  , modify
  
cap drop country
generate country = real(cntryid) 
label  values  country  cntryid

****create indicators for particular groupings
generate region=.


***WHO European Region B/C (combined)
foreach x in 100 233 348 428 440 499 616 643 703 792{
replace region = 6 if country==`x' 
}

***WHO European Region A
foreach x in 40 56 191 203 208 246 250 276 300 352 372 376 442 528 578 620 ///
			705 724 752 756 826 {
replace region = 5 if country==`x' 
}

***WHO Region of the Americas AMR A
foreach x in 124 840{
replace region = 4 if country==`x' 
}

***WHO Region of the Americas AMR B/C
foreach x in 76 152 170 188 214 484 604 858{
replace region = 3 if country==`x' 
}

***WHO South-East Asian & Western Pacific Region Regions (combined)
foreach x in 36 158 344 392 410 554 702 764{
replace region = 2 if country==`x' 
}

***WHO Eastern Mediterranean Region
foreach x in 634 784 788  {
replace region = 1 if country==`x' 
}

*SES diff plots
drop if missing(q5_b)

sort region q5_b

cap drop n
gen n = _n if !missing(q5_b)
decode country, generate(country_string)
labmask n, values(country_string)


*Plots
*Color
twoway (scatter n q0_b , msize(.5) mcolor("red") msymbol(circle))  (rcap q0_lci q0_uci n , horizontal  lcolor("red")  msize(0)  ) ///
	   (scatter n q5_b , msize(.5) mcolor("black") msymbol(triangle))  (rcap q5_lci q5_uci n , horizontal  lcolor("black")  msize(0)) ///
	   , ylabel(1(1)52, ang(h) labsize(tiny) valuelabel noticks) legend(off)  ytitle("") xlabel(0(.1).8) ///
	   graphregion(color(white)) xtitle("`: variable label q0_b', `s'") ///
	   	   yline(3.5 11.5 19.5 21.5 42.5, lpattern(dash)  lcolor(gray)  )  aspectratio(1.5) 
		   graph export "$output/`var'_wealth_`s'_color.tif", replace	   
		   }
			}

			
	
			
			
///////   Figure 2: Plot specific distributions for certain countries for physical activity in school
///////   First by number of classes per week and then by hours of classes per week

use "$output/freq_paclass_bothgenders.dta", clear

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
decode country, generate(id)

*Cannot have spaces in country names for the loop below
replace id = "UK" if id == "United Kingdom"
replace id = "USA" if id == "United States"

*rename vars to enable plotting
clonevar d0 = paclass_0_b 
clonevar d1 = paclass_1_b 
clonevar d2 = paclass_2_b 
clonevar d3 = paclass_3_b 
clonevar d4 = paclass_4_b 
clonevar d5 = paclass_5_b 

*Change labels of frequency variables
label var d0 "0 days"
label var d1 "1 day"
label var d2 "2 days"
label var d3 "3 days"
label var d4 "4 days"
label var d5 "5 days"


*Use this loop to create histogram (frequency plots)
tab id ///This will show values of countries for macro below. Can change countries as desired in local macro below.	
	
local histograms `" "USA" "UK" "Poland" "Colombia" "Sweden" "'	
foreach cnt of local histograms{		
graph bar (first) d* if id=="`cnt'" ///
		, graphregion(color(white)) ascategory  nolabel  yvar(relabel(1 "`: var label d0'" 2 "`: var label d1'" 3 "`: var label d2'" 4 "`: var label d3'" ///
		5 "`: var label d4'" 6 "`: var label d5'")) title("Avg. in school physical education classes, days/week in `cnt'", size(medium)) ///
		ytitle(" Percent of pupils in who say...")
		graph export "$output/`cnt'_histogram_paclass.tif", replace
		}
		

*** Make histograms for PA class time
use "$output/freq_paclass_hours_bothgenders.dta",clear 

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
decode country, generate(id)

*Cannot have spaces in country names for the loop below
replace id = "UK" if id == "United Kingdom"
replace id = "USA" if id == "United States"

*rename vars to enable plotting
clonevar d0 = paclass_hours_0_b 
clonevar d1 = paclass_hours_1_b 
clonevar d2 = paclass_hours_2_b 
clonevar d3 = paclass_hours_3_b 
clonevar d4 = paclass_hours_4_b 
clonevar d5 = paclass_hours_5_b 

*Change labels of frequency variables
label var d0 "0 hours"
label var d1 "0-1 hours"
label var d2 "1-2 hours"
label var d3 "2-3 hours"
label var d4 "3-4 hours"
label var d5 "> 4 hours"



*Use this loop to create histogram (frequency plots)
tab id ///This will show values of countries for macro below. Can change countries as desired		
	
local histograms `" "USA" "UK" "Poland" "Colombia" "Sweden" "'	
foreach cnt of local histograms{		
graph bar (first) d* if id=="`cnt'" ///
		, graphregion(color(white)) ascategory  nolabel  yvar(relabel(1 "`: var label d0'" 2 "`: var label d1'" 3 "`: var label d2'" 4 "`: var label d3'" ///
		5 "`: var label d4'" 6 "`: var label d5'")) title("Avg. in school physical education classes, hours/week in `cnt'", size(medium)) ///
		ytitle(" Percent of pupils in who say...")
		graph export "$output/`cnt'_histogram_paclasshours.tif", replace
		}
		


		

		 

///////   Supplementary Figures	 
///////   Ecological analyses

///////   Supplementary Figure 1: Correlation between in-school activity and UNESCO school guidelines 

use "$output/paclass_bothgenders.dta", clear

cap drop _merge
merge 1:1 cntryid using "$output/paclass_madj_bothgenders.dta"

sum paclass_mean_b paclass_madj_mean_b 

***Merge with UNESCO dataset. 
***The UNESCO data has been extracted from : UNESCO. World-wide survey of school physical education: UNESCO Publishing 2014.
****This data is available at: https://github.com/dbann/pisa 

cap drop _merge
merge 1:1 cntryid using "$data/pisa_unesco1.dta"


*label countries for use in plots
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

generate country = real(cntryid) 
label  values  country  cntryid

*correlation between school activity - individual level [PISA] + country guideline [UNESCO]
corr legal_pa_classmean paclass_mean_b paclass_madj_mean_b 
spearman legal_pa_classmean paclass_mean_b paclass_madj_mean_b 


reg paclass_madj_mean_b legal_pa_classmean 


*****produce plot 
twoway (line paclass_madj_mean_b paclass_madj_mean_b, sort legend(off) lwidth(thin) lpattern(dash) lcolor(black) ) /// This adds the 45 degree line
		(scatter paclass_madj_mean_b legal_pa_classmean, ///
		mcolor(black%60) msize(vsmall) msymbol(circle) mlabel(cnt) mlabsize(tiny) mlabcolor(black%70) jitter(5)), ///
		ytitle(PISA: average PE class minutes/week) ytitle(, color(black)) yscale(range(40 210)) ylabel(40 (50) 210) ///
		ymtick(40(10)210) xtitle(UNESCO physical activity requirements minutes/week) xscale(range(40 210)) ///
		xlabel(40(40)210) xmtick(40(10)210) title("") scheme(s2color)  graphregion(color(white)) 
		graph export "$output/unesco_paclass_madj_mean_b.tif", replace	   


		   
		   
///////   Supplementary Figure 2: GINI + GDP ecological analyses
		   
***Merge different data exported from Stata and data available at: https://github.com/dbann/pisa 

use "$output/vigd_bothgenders.dta", clear

merge 1:1 cntryid using "$output/modd_bothgenders.dta"
cap drop _merge
merge 1:1 cntryid using "$output/paclass_bothgenders.dta"
cap drop _merge
merge 1:1 cntryid using "$output/paclass_3plus_bothgenders.dta"
cap drop _merge
merge 1:1 cntryid using "$output/modd_5plus_bothgenders.dta"
cap drop _merge
merge 1:1 cntryid using "$output/vigd_5plus_bothgenders.dta"
cap drop _merge


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
 generate country = real(cntryid) 
label  values  country  cntryid
 
***Merge world bank data - gdp, gini, urban
***This data is available at: https://github.com/dbann/pisa 
cap drop _merge
destring cntryid, replace 
merge 1:1 cntryid using "$data/lookup_code_abbcountry.dta"
drop if _merge ==2 //remove only who data

cap drop _merge
merge m:1 cnt using "$data/wbank_selected_variables.dta"
tab _merge, nolab
drop if _merge==2

***NB: 5 countries have missing data in World Bank dataset // Hong Kong, Japan, New Zealand, Qatar, Singapore, UAE. thus many high inequal countries! and some low!
tab countryname if missing(gini2010_2015) //note actually from 2007 

sum gini*

***Ecological analyses GINI , GDP + outcomes
corr  gini2010_2015 gdp2015  vigd_mean_b modd_mean_b paclass_mean_b ///
			vigd_5plus_mean_b modd_5plus_mean_b paclass_3plus_mean_b 

twoway 		(scatter paclass_mean_b gini2010_2015 	  , mlabel(cnt) ///
			xtitle("Income inequality (Gini)") ytitle("Average PE classes, days/week")  ///
			graphregion(color(white)) 		mcolor(black%60) msize(vsmall) msymbol(circle) mlabel(cnt) mlabsize(tiny)  scheme(s2color) jitter(7)) ///
			(lfit paclass_mean_b gini2010_2015, legend(off) lwidth(thin) lpattern(dash) lcolor(black))

		   graph export "$output/paclass_gini_scatter.tif", replace	   


twoway 		(scatter modd_mean_b gini2010_2015 	  , mlabel(cnt) ///
			xtitle("Income inequality (Gini)") ytitle("Average moderate activity, days/week")  ///
			graphregion(color(white)) 		mcolor(black%60) msize(vsmall) msymbol(circle) mlabel(cnt) mlabsize(tiny) scheme(s2color) jitter(7)) ///
			(lfit modd_mean_b gini2010_2015, legend(off) lwidth(thin) lpattern(dash) lcolor(black))

			graph export "$output/modd_gini_scatter.tif", replace	   

			
twoway		(scatter vigd_mean_b gini2010_2015 	  , mlabel(cnt) ///
			xtitle("Income inequality (Gini)") ytitle("Average vigorous activity, days/week")  ///
			graphregion(color(white)) 		mcolor(black%60) msize(vsmall) msymbol(circle) mlabel(cnt) mlabsize(tiny)  scheme(s2color) jitter(7)) ///
			(lfit vigd_mean_b gini2010_2015, legend(off) lwidth(thin) lpattern(dash) lcolor(black))
			
			graph export "$output/vigd_gini_scatter.tif", replace	   

			
			
			
			
			
			
			
twoway 		(scatter paclass_3plus_mean_b gini2010_2015 	  , mlabel(cnt) ///
			xtitle("Income inequality (Gini)") ytitle("PISA: school activity classes," "prevalence 5+ days/week")  ///
			graphregion(color(white)) 		mcolor(black%60) msize(vsmall) msymbol(circle) mlabel(cnt) mlabsize(tiny) scheme(s2color) jitter(7)) ///
			(lfit paclass_3plus_mean_b gini2010_2015, legend(off) lwidth(thin) lpattern(dash) lcolor(black))

		   graph export "$output/paclass_3plus_gini_scatter.tif", replace	   


twoway 		(scatter modd_5plus_mean_b gini2010_2015 	  , mlabel(cnt) ///
			xtitle("Income inequality (Gini)") ytitle("PISA: moderate activity out of school," "prevalence 5+ days/week")  ///
			graphregion(color(white)) 		mcolor(black%60) msize(vsmall) msymbol(circle) mlabel(cnt) mlabsize(tiny) scheme(s2color) jitter(7)) ///
			(lfit modd_5plus_mean_b gini2010_2015, legend(off) lwidth(thin) lpattern(dash) lcolor(black))

			graph export "$output/modd_5plus_gini_scatter.tif", replace	   

			
twoway		(scatter vigd_5plus_mean_b gini2010_2015 	  , mlabel(cnt) ///
			xtitle("Income inequality (Gini)") ytitle("PISA: vigorous activity out of school," "prevalence 5+ days/week")  ///
			graphregion(color(white)) 		mcolor(black%60) msize(vsmall) msymbol(circle) mlabel(cnt) mlabsize(tiny) scheme(s2color) jitter(7)) ///
			(lfit vigd_5plus_mean_b gini2010_2015, legend(off) lwidth(thin) lpattern(dash) lcolor(black))
			
			graph export "$output/vigd_5plus_gini_scatter.tif", replace	   			

///////   Supplementary Tables

***Supplementary Table 1

use "$output/vigd_bothgenders.dta", clear

merge 1:1 cntryid using "$output/modd_bothgenders.dta"
cap drop _merge
merge 1:1 cntryid using "$output/paclass_bothgenders.dta"
cap drop _merge


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
 generate country = real(cntryid) 
label  values  country  cntryid
 
***Merge world bank data - gdp, gini, urban
***Merge in WHO data on obesity and physical inactivity
***This data is available at: https://github.com/dbann/pisa 
cap drop _merge
destring cntryid, replace 
merge 1:1 cntryid using "$data/lookup_code_abbcountry.dta"
drop if _merge ==2 //remove only who data

cap drop _merge
merge m:1 cnt using "$data/wbank_selected_variables.dta"
tab _merge, nolab
drop if _merge==2

*create identifier to merge with WHO PA data
cap drop id
cap drop _merge

decode country, generate(id)
desc id 


cap drop _merge
merge m:m id using "$data/whopa.dta", force   
clonevar whopa = insufficientlyactive1117yin
destring whopa, replace


cap drop _merge
merge m:m id using "$data/whoob.dta", force
tab _merge, nolab
drop if _merge==2


*Keep only variables for Spplementary Table 1
keep country gdp2015 vigd_N_b urban2015 gini2010_2015 whopa obesity_both_sexes
rename vigd_N_b N

order country N gdp2015 gini2010_2015 urban2015 obesity_both_sexes whopa

export excel using "$output/SupplementaryTables", sheet("Table 1") sheetreplace ///															
		firstrow(variables)	

			
***Supplementary Table 2
***Summary statistics of outcomes for both genders
foreach var of global outcomes {                                                
	use "$output/`var'_bothgenders.dta", clear
	
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
	
	gen cnt = real(cntryid)
	label  values  cnt  cntryid
	decode cnt, gen(country)
	
	capture drop e_*
	capture keep country *_b*
	
	sort country
	order country
	
	capture rename `var'_mean_b Mean_`var'
	capture rename `var'_p50_b Median_`var'
	capture rename `var'_sd_b SD_`var'
	capture rename `var'_N_b N_`var'
	
	
	export excel using "$output/SupplementaryTables", sheet("Table 2 Overall `var'") sheetreplace ///															
		firstrow(variables)	
	}			

***Summary statistics of outcomes for each gender separately
foreach var of global outcomes {                                                
	use "$output/`var'_bysex.dta", clear
	
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
	
	gen cnt = real(cntryid)
	label  values  cnt  cntryid
	sdecode cnt, gen(country)
	
	capture drop *e_*
	capture keep country *_b*
	
	sort country
	order country
	
	   
	
	forval i=0(1)1{
		if `i' == 0 {
		capture rename _`i'_`var'_mean_b Mean_`var'_Female
		capture rename _`i'_`var'_p50_b Median_`var'_Female
		capture rename _`i'_`var'_sd_b SD_`var'_Female
		capture rename _`i'_`var'_N_b N_`var'_Female
	}
	
		else if `i' == 1 { 
		capture rename _`i'_`var'_mean_b Mean_`var'_Male
		capture rename _`i'_`var'_p50_b Median_`var'_Male
		capture rename _`i'_`var'_sd_b SD_`var'_Male
		capture rename _`i'_`var'_N_b N_`var'_Male
	}
	}
	
	
	export excel using "$output/SupplementaryTables", sheet("Table 2 Gender `var'") sheetreplace ///															
		firstrow(variables)	
	}			
	
***Summary statistics of outcomes for wealth quintiles by gender separately
local gender `"female male"'
foreach gen of local gender{
foreach var of global outcomes {                                                
	use "$output/`var'_wealthq_`gen'.dta", clear
	
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
	
	gen cnt = real(cntryid)
	label  values  cnt  cntryid
	sdecode cnt, gen(country)
	
	capture drop *e_* *_2* *_3* *_4*
	capture keep *_1* *_5* country *_b*
	
	sort country
	order country
	
	 foreach i of numlist 1 5{
		if `i' == 1 {
		capture rename _`i'_`var'_mean_b Mean_Q1_`var'_`gen'
		capture rename _`i'_`var'_p50_b Median_Q1_`var'_`gen'
		capture rename _`i'_`var'_sd_se SD_Q1_`var'_`gen'
		capture rename _`i'_`var'_N_b N_Q1_`var'_`gen'
	}
	
		else if `i' == 5 { 
		capture rename _`i'_`var'_mean_b Mean_Q5_`var'_`gen'
		capture rename _`i'_`var'_p50_b Median_Q5_`var'_`gen'
		capture rename _`i'_`var'_sd_se SD_Q5_`var'_`gen'
		capture rename _`i'_`var'_N_b N_Q5_`var'_`gen'
	}
	
	

	}
	
	
	export excel using "$output/SupplementaryTables", sheet("Table 2 `Gender' Wealth `var'") sheetreplace ///															
		firstrow(variables)	
	}
	}
	
	
	
***Supplementary Table 3
***Tabulation of outcomes
foreach var of global outcomes {                                                
	use "$output/freq_`var'_bothgenders.dta", clear
	
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
	
	gen cnt = real(cntryid)
	label  values  cnt  cntryid
	sdecode cnt, gen(country)
	
	keep country *_b*
	capture drop e_*
	
	sort country
	order country
	
	forval i=0(1)7{
	capture rename `var'_`i'_b Freq_`i'
	}

	
	export excel using "$output/SupplementaryTables", sheet("Table 3 `var'") sheetreplace ///															
		firstrow(variables)	
	}
	
	
***Supplementary Table 4
***Tabulation of outcomes by gender
foreach var of global outcomes {                                                
	use "$output/freq_`var'_bysex.dta", clear
	
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
	
	gen cnt = real(cntryid)
	label  values  cnt  cntryid
	sdecode cnt, gen(country)
	
	keep country *_b*
	drop *_e_*
	
	sort country
	order country
	
	forval i=0(1)7{
	capture rename _0_`var'_`i'_b Female_`i'
	}

	forval i=0(1)7{
	capture rename _1_`var'_`i'_b Male_`i'
	}
	
	export excel using "$output/SupplementaryTables", sheet("Table 4 `var'") sheetreplace ///															
		firstrow(variables)	
	}

	
***Supplementary Table 5
***Tabulation of outcomes by SES
foreach var of global outcomes {                                                
	use "$output/freq_`var'_bywealth.dta", clear
	
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
	
	gen cnt = real(cntryid)
	label  values  cnt  cntryid
	sdecode cnt, gen(country)
	
	keep country *_b*
	keep country _1* _5*
	drop *_e_*
	
	sort country
	order country
	
	forval i=0(1)7{
	capture rename _1_`var'_`i'_b Q1_`i'
	}

	forval i=0(1)7{
	capture rename _5_`var'_`i'_b Q5_`i'
	}
	
	export excel using "$output/SupplementaryTables", sheet("Table 5 `var'") sheetreplace ///															
		firstrow(variables)	
	
	}	
			
			
			
///////   End of do file
