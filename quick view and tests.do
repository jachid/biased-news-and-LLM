//quick view of the news ratings and changes by treatment
gen change_trust = survey1playernews_final_trustwor - survey1playernews_trustworthy
gen change_share = survey1playernews_final_share_li - survey1playernews_share_likeliho
gen change_oneside = survey1playernews_final_one_side - survey1playernews_one_sided
gen change_bias = survey1playernews_final_biased_c - survey1playernews_biased_china

egen treatment = group( survey1playertreatment )
mean change_bias change_oneside change_share change_trust, over( treatment )

//t test for before and after changes
foreach i in trust share oneside bias{
	ttest change_`i'=0 if treatment==1
	ttest change_`i'=0 if treatment==2
	ttest change_`i'=0 if treatment==3
}
//permtest for between groups 
foreach i in trust share oneside bias{
	///between chat and tailored message
	permtest2 change_`i' if treatment!=3,by(treatment) 
	///between chat and generic messages
	permtest2 change_`i' if treatment!=2,by(treatment) 
	///between tailored and generic messages
	permtest2 change_`i' if treatment!=1,by(treatment) 
}


