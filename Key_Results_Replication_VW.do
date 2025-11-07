*** ECO 726: Policy and Program Evaluation 
*** Replicating Key Results 

set more off
cap log close
clear 

cd "~/Documents/ECO 726 Final Project"

use "Public_FAFSA_finalwithGrad_2021_labeled.dta"

log using "Replication_Project_VW", replace

** Controls used by author 
encode sitecode, gen(id)
local controls per_white per_black per_hisp per_asian total totalsq act

** Table 2: Difference - in - Difference Estimates

generate treat = (1 - averc) * post
label var treat "Average Completion x Post"

areg rate_comp treat y_* [aw=wt], absorb(id) vce(cluster id)
eststo fafno

areg rate_comp treat `controls' y_* [aw=wt], absorb(id) vce(cluster id)
eststo fafcon

areg penroll treat y_* [aw=wt], absorb(id) vce(cluster id)
eststo enrollno

areg penroll treat `controls' y_* [aw=wt], absorb(id) vce(cluster id)
eststo enrollcon

esttab fafno fafcon enrollno enrollcon // table in Stata

** Table 3: Instrumental Variables Estimates  

regress per_enroll y_2016-y_2019 i.id `controls' rate_comp [aw=wt], vce(cluster id) // OLS
eststo ols_perenroll

regress penroll   y_2016-y_2019 i.id `controls' rate_comp [aw=wt], vce(cluster id) // OLS 
eststo ols_penenroll

ivregress 2sls per_enroll y_2016-y_2019 i.id `controls' (rate_comp = treat) [aw=wt], vce(cluster id) // IV
eststo iv_perenroll

ivregress 2sls penroll   y_2016-y_2019 i.id `controls' (rate_comp = treat) [aw=wt], vce(cluster id) // IV 
eststo iv_penenroll

esttab ols_perenroll ols_penenroll iv_perenroll iv_penenroll // table in Stata

** Generating Tables with Latex 

esttab fafno fafcon enrollno enrollcon using "Results_Table2.tex", replace ///
nodepvars nostar noomitted booktabs ///
mgroups("Completion Rate" "\% Enrolled in College", pattern(1 1 1 1) span) /// 
title("Effect of Mandatory FAFSA on Completion and Enrollment (Table 2 Replication)") ///

esttab ols_perenroll ols_penenroll iv_perenroll iv_penenroll using "Results_Table3.tex", replace ///
nodepvars nostar noomitted booktabs ///
title("IV Estimates using FAFSA Mandate as an IV (Table 3 Replication)") ///


log close 
