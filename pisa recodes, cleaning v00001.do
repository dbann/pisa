///////   Syntax to clean/derive variables for Bann et al. (paper using physical activity data from PISA 2015)
///////   Created XX/XX/2018
///////   recodes/cleaning etc



///////   Run this do-file before running the analysis do file 

///////   Make sure to change directory to your own machine
********************************************************************************
global data ""
********************************************************************************

///////   Open data and install packages
***Data obtained from the following url in mid 2017: http://www.oecd.org/pisa/data/2015database/
use "$data/CY6_MS_CMB_STU_QQQ.DTA", clear

***Set variables to lowercase (necessary to use 'repest' package)
foreach v of varlist _all {
capture ren `v' `=lower("`v'")'
}	

///////   Remove countries with no relevant physical activity outcome data, or regions since not comparable with countries 
***Done early on in do file to save time when re-running
***Check
tabstat st031q01na st032q01na st032q02na, by(cntryid)
foreach x in QUE QUC QES QCH ALB VNM TTO ROU  QUD QAR MLT MKD MDA LBN KSV JOR ITA GEO DZA IDN  MAC VNM {
drop if cnt == "`x'" 
}

///////   Generate control variables and keep existing control variables necessary for analysis
***These will be the SES / demographic variables for analysis
desc pared st007q01ta st005q01ta wealth escs

***Wealth
desc st011* st012*  wealth //which of the following are in your home... [desk to study, room of your own...]; 12: //how many of these are in your home [cars, televisions...]
sum st011* st012*  wealth //

*generate quintiles
cap drop wealthq*
cap drop escsq*

gen wealthq =. 
gen escsq =. 


levelsof cnt, local(countryl)
foreach var of varlist escs wealth {
    foreach cnt of local countryl  {                                    /* looping over the global macro */
        xtile `var'q`cnt' = ///                                        /* spilt into quintiles using xtile command */
            `var' ///                                                                /* create new variables. quintiles of escs */
            [aw = w_fstuwt] ///                                                        /* apply the weight */
            if `var' != . ///                                                        /* only if data is non-missing */
            & cnt == "`cnt'" ///                                                    /* only for the country within this loop */                                    
            , nq(5)                                                                    /* create 5 groups (quintiles) */    

        replace `var'q  =  `var'q`cnt' ///                    /* replace national quintile with results for the country */
            if `var'q  == .  ///
            & `var'q`cnt'  !=. 
               
        drop `var'q`cnt'                                                 /* drop variable for the country just created */
            }                                                                        /* close the loop */
			}

		
tab wealthq

***Age
desc st003d03t st003d02t
tab st003d03t //all born 1999 or 2000


***Sex
tab st004d01t
tab st004d01t, nolab
recode st004d01t (1=0 "female") (2=1 "male"), gen(sex)
tab sex st004d01t 

***Country
clonevar country = cnt

***Variables to note which could affect prevelance - mode
tab adminmode
tab adminmode country //no overlap thus can't 'adjust' for mode, but can descriptively examine


///////   Generate physical activity outcome variables
desc ec001q07na st031q01na st032q01na st032q02na //binary yes/no variables also st076q11na st078q11na

clonevar sportsin = ec001q07na //In this school year, approximately how many hours per week do you attend additional instruction in the following domains in addition to mandatory school lessons?
							   //thus unclear if total sports hours or only additional to paclasses 
clonevar paclass = st031q01na
clonevar modd =st032q01na
clonevar vigd =st032q02na

tab vigd, nolab //Physical activity variables are not coded in terms of days (OECD coding 1 = 0 days, 8 = 7 days)
tab modd, nolab //Physical activity variables are not coded in terms of days (OECD coding 1 = 0 days, 8 = 7 days)

replace vigd = vigd - 1
replace modd = modd - 1
replace paclass = paclass - 1

lab val vigd vigd //clear value labels otherwise mislabeled from previous
lab val modd modd
lab val paclass paclass

tab modd
tab vigd
tab paclass

sum  paclass modd vigd sportsin
sum  paclass modd vigd sportsin if !missing(paclass, modd, vigd) //15/350 =  

***Generate missing indicator variable
gen allpa=. 
replace allpa=1 if !missing(paclass, modd, vigd)
replace allpa=0 if missing(paclass, modd, vigd)
tab allpa

***Generate paclass variable which accounts for average minutes in class
***This assumes 1 day of paclass = 1 class [this may or may not be true - so unclear which is most 'correct' variable]
***First check minutes variable
desc st061q01na // "How many minutes, on average, are there in a <classperiod>?" 
sum st061q01na 

cap drop paclass_madj 
gen paclass_madj = paclass * st061q01na if !missing(paclass, st061q01na)
sum paclass paclass_madj 

***Generate paclass variable which accounts for average hours of classes per week 
recode paclass_madj (0=0 "0") (1/60 = 1 "0-1hr") (60.000001/120 = 2 "1-2hrs") ///
	(120.000001/180 = 3 "2-3hrs") (180.000001/240= 4 "3-4hrs") ///
	(240.000001/max= 5 ">4hrs") , gen(paclass_hours)


///////   Save a version as the recode process takes a long time 
***Remove variables unlikely useful for this paper to save space/cpu 
keep sex cntryid-bookid paclass-vigd allpa ver_dat senwt pared-wvarstrr  homepos hisei homepos	///
		wealth wealthq	paclass_madj paclass_hours st061q01na

save "$data/pisa2015_recoded_clean_v001.dta", replace

///////   End of cleaning do file
