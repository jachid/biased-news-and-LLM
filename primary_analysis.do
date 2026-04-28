********************************************************************************
* Primary Analysis: AI Interventions and Perceived Bias in News Coverage
* Pooled US + UK + Canada (N=1,017)
* Static = baseline throughout
* Date: 2026-04-28
********************************************************************************

clear all
set more off
set scheme s2color
cd "C:\Users\Administrator\Desktop\bias_news_llm"
capture mkdir "output"

********************************************************************************
* 1. DATA CONSTRUCTION
********************************************************************************

use "news_check_us_uk_ca_pooled.dta", clear

* --- Treatment (Static=1 baseline, Comment=2, Chatbot=3) ---
encode survey1playertreatment, gen(treat_raw)
recode treat_raw (3=1) (2=2) (1=3), gen(treatment)
label define treat_lbl 1 "Static" 2 "Comment" 3 "Chatbot"
label values treatment treat_lbl

* --- Nation ---
label define nation_lbl 1 "US" 2 "UK" 3 "Canada"
label values nation nation_lbl

* --- Change scores ---
gen change_trust = survey1playernews_final_trustwor - survey1playernews_trustworthy
gen change_share = survey1playernews_final_share_li - survey1playernews_share_likeliho
gen change_oneside = survey1playernews_final_one_side - survey1playernews_one_sided
gen change_bias = survey1playernews_final_biased_c - survey1playernews_biased_china

label var change_trust    "Change in trustworthiness"
label var change_share    "Change in share likelihood"
label var change_oneside  "Change in one-sidedness"
label var change_bias     "Change in perceived bias (China)"

* --- Shorthand ---
gen age = survey1playerage
gen gender = survey1playergender
gen education = survey1playereducation
gen income = survey1playerperceived_income
gen liberal = survey1playerliberal
gen trust_ai = survey1playertrust_ai
gen favorable = survey1playerfavorable
gen race = survey1playerrace

gen pre_trust   = survey1playernews_trustworthy
gen pre_share   = survey1playernews_share_likeliho
gen pre_oneside = survey1playernews_one_sided
gen pre_bias    = survey1playernews_biased_china

gen info_fair   = survey1playerinfo_fair
gen info_new    = survey1playerinfo_new
gen info_verify = survey1playerinfo_verify

gen female = (gender == 2)

label define gender_lbl 1 "Male" 2 "Female" 3 "Other"
label values gender gender_lbl
label define race_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Mixed" 6 "Other"
label values race race_lbl

label var age "Age"
label var female "Female"
label var education "Education"
label var income "Income (1--10)"
label var liberal "Pol.\ orientation (1--7)"
label var trust_ai "Trust in AI (1--7)"
label var favorable "Favorable to China (1--5)"

di _N " observations loaded"
tab treatment nation


********************************************************************************
* 2. TABLE 1: SUMMARY STATISTICS (hand-built QJE style)
********************************************************************************

* Means/SDs by treatment
forvalues t = 1/3 {
	foreach var in age female income education liberal trust_ai favorable {
		quietly sum `var' if treatment == `t'
		local m_`var'_`t' : di %5.2f r(mean)
		local s_`var'_`t' : di %5.2f r(sd)
	}
}
foreach var in age female income education liberal trust_ai favorable {
	quietly sum `var'
	local m_`var'_0 : di %5.2f r(mean)
	local s_`var'_0 : di %5.2f r(sd)
}
foreach var in age female income education liberal trust_ai favorable {
	quietly reg `var' i.treatment, robust
	local p_`var' : di %5.3f Ftail(e(df_m), e(df_r), e(F))
}

* Race
forvalues t = 1/3 {
	quietly count if treatment == `t'
	local n_`t' = r(N)
	foreach r in 1 2 3 4 5 6 {
		quietly count if race == `r' & treatment == `t'
		local rp_`r'_`t' : di %4.1f 100*r(N)/`n_`t''
	}
}
quietly count
local n_0 = r(N)
foreach r in 1 2 3 4 5 6 {
	quietly count if race == `r'
	local rp_`r'_0 : di %4.1f 100*r(N)/`n_0'
}

capture file close fh
file open fh using "output/tab1_summary.tex", write replace
file write fh "\begin{table}[htbp]" _n
file write fh "\centering" _n
file write fh "\caption{Summary Statistics}" _n
file write fh "\label{tab:summary}" _n
file write fh "\small" _n
file write fh "\begin{tabular}{l*{4}{c}c}" _n
file write fh "\toprule" _n
file write fh " & Static & Comment & Chatbot & Total & \$p\$-value \\" _n
file write fh " & (1) & (2) & (3) & (4) & (5) \\" _n
file write fh "\midrule" _n
file write fh "\addlinespace" _n
file write fh "\multicolumn{6}{l}{\textit{Panel A: Demographics}} \\" _n
file write fh "\addlinespace" _n
file write fh "Age & `m_age_1' & `m_age_2' & `m_age_3' & `m_age_0' & `p_age' \\" _n
file write fh "    & (`s_age_1') & (`s_age_2') & (`s_age_3') & (`s_age_0') & \\" _n
file write fh "\addlinespace" _n
file write fh "Female (\%) & `m_female_1' & `m_female_2' & `m_female_3' & `m_female_0' & `p_female' \\" _n
file write fh "\addlinespace" _n
file write fh "Income (1--10) & `m_income_1' & `m_income_2' & `m_income_3' & `m_income_0' & `p_income' \\" _n
file write fh "    & (`s_income_1') & (`s_income_2') & (`s_income_3') & (`s_income_0') & \\" _n
file write fh "\addlinespace" _n
file write fh "Education & `m_education_1' & `m_education_2' & `m_education_3' & `m_education_0' & `p_education' \\" _n
file write fh "    & (`s_education_1') & (`s_education_2') & (`s_education_3') & (`s_education_0') & \\" _n
file write fh "\addlinespace" _n
file write fh "Pol.\ orientation (1--7) & `m_liberal_1' & `m_liberal_2' & `m_liberal_3' & `m_liberal_0' & `p_liberal' \\" _n
file write fh "    & (`s_liberal_1') & (`s_liberal_2') & (`s_liberal_3') & (`s_liberal_0') & \\" _n
file write fh "\addlinespace" _n
file write fh "Trust in AI (1--7) & `m_trust_ai_1' & `m_trust_ai_2' & `m_trust_ai_3' & `m_trust_ai_0' & `p_trust_ai' \\" _n
file write fh "    & (`s_trust_ai_1') & (`s_trust_ai_2') & (`s_trust_ai_3') & (`s_trust_ai_0') & \\" _n
file write fh "\addlinespace" _n
file write fh "Favorable to China (1--5) & `m_favorable_1' & `m_favorable_2' & `m_favorable_3' & `m_favorable_0' & `p_favorable' \\" _n
file write fh "    & (`s_favorable_1') & (`s_favorable_2') & (`s_favorable_3') & (`s_favorable_0') & \\" _n
file write fh "\addlinespace" _n
file write fh "\multicolumn{6}{l}{\textit{Panel B: Race/Ethnicity (\%)}} \\" _n
file write fh "\addlinespace" _n
file write fh "White    & `rp_1_1' & `rp_1_2' & `rp_1_3' & `rp_1_0' & \\" _n
file write fh "Black    & `rp_2_1' & `rp_2_2' & `rp_2_3' & `rp_2_0' & \\" _n
file write fh "Hispanic & `rp_3_1' & `rp_3_2' & `rp_3_3' & `rp_3_0' & \\" _n
file write fh "Asian    & `rp_4_1' & `rp_4_2' & `rp_4_3' & `rp_4_0' & \\" _n
local mo_1 : di %4.1f `rp_5_1' + `rp_6_1'
local mo_2 : di %4.1f `rp_5_2' + `rp_6_2'
local mo_3 : di %4.1f `rp_5_3' + `rp_6_3'
local mo_0 : di %4.1f `rp_5_0' + `rp_6_0'
file write fh "Mixed/Other & `mo_1' & `mo_2' & `mo_3' & `mo_0' & \\" _n
file write fh "\midrule" _n
file write fh "Observations & `n_1' & `n_2' & `n_3' & `n_0' & \\" _n
file write fh "\bottomrule" _n
file write fh "\end{tabular}" _n
file write fh "\par\vspace{4pt}" _n
file write fh "\begin{minipage}{\textwidth}" _n
file write fh "\footnotesize \textit{Notes:} Standard deviations in parentheses. Column (5) reports \$p\$-values from OLS regressions of each covariate on treatment indicators with robust standard errors." _n
file write fh "\end{minipage}" _n
file write fh "\end{table}" _n
file close fh


********************************************************************************
* 3. TREATMENT EFFECTS
********************************************************************************

* --- Primary: Bias (3 specs) ---
reg change_bias ib1.treatment, robust
estimates store raw_bias
reg change_bias ib1.treatment pre_bias, robust
estimates store main_bias
reg change_bias ib1.treatment pre_bias age female education income liberal trust_ai favorable i.nation, robust
estimates store full_bias

esttab raw_bias main_bias full_bias ///
	using "output/tab2_bias.tex", replace ///
	keep(3.treatment 2.treatment pre_bias age female education income liberal trust_ai favorable 2.nation 3.nation) ///
	order(3.treatment 2.treatment pre_bias age female education income liberal trust_ai favorable 2.nation 3.nation) ///
	coeflabels(3.treatment "Chatbot" 2.treatment "Comment" ///
		pre_bias "Pre-treatment bias" age "Age" female "Female" ///
		education "Education" income "Income" liberal "Pol.\ orientation" ///
		trust_ai "Trust in AI" favorable "Favorable to China" 2.nation "UK" 3.nation "Canada") ///
	nomtitles nonumber se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("r2 \$R^2\$" "N Obs.") sfmt(%9.3f %9.0f) ///
	label booktabs fragment ///
	prehead("\begin{table}[htbp]" ///
		"\centering" ///
		"\caption{Treatment Effects on Perceived Bias Against China}" ///
		"\label{tab:bias}" ///
		"\begin{tabular}{l*{3}{c}}" ///
		"\toprule" ///
		" & \multicolumn{3}{c}{Change in Perceived Bias (0--100)} \\" ///
		"\cmidrule(lr){2-4}" ///
		" & (1) & (2) & (3) \\") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" ///
		"\end{tabular}" ///
		"\par\vspace{4pt}" ///
		"\begin{minipage}{\textwidth}" ///
		"\footnotesize \textit{Notes:} OLS estimates. Dependent variable: change in perceived bias against China (post $-$ pre, 0--100 scale). Baseline: Static. Robust standard errors in parentheses. Column (1): unadjusted. Column (2): pre-treatment bias control. Column (3): demographic controls and country fixed effects. \sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
		"\end{minipage}" ///
		"\end{table}")

* --- All four outcomes ---
reg change_trust ib1.treatment pre_trust, robust
estimates store main_trust
reg change_oneside ib1.treatment pre_oneside, robust
estimates store main_oneside
reg change_share ib1.treatment pre_share, robust
estimates store main_share

esttab main_trust main_oneside main_bias main_share ///
	using "output/tab2_all.tex", replace ///
	keep(2.treatment 3.treatment) ///
	order(3.treatment 2.treatment) ///
	coeflabels(3.treatment "Chatbot" 2.treatment "Comment") ///
	mtitles("Trust" "One-sided" "Bias" "Share") ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("r2 \$R^2\$" "N Obs.") sfmt(%9.3f %9.0f) ///
	label booktabs fragment ///
	prehead("\begin{table}[htbp]" ///
		"\centering" ///
		"\caption{Treatment Effects on All Outcomes}" ///
		"\label{tab:all}" ///
		"\begin{tabular}{l*{4}{c}}" ///
		"\toprule" ///
		" & \multicolumn{4}{c}{Change Score (Post $-$ Pre)} \\" ///
		"\cmidrule(lr){2-5}") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" ///
		"\end{tabular}" ///
		"\par\vspace{4pt}" ///
		"\begin{minipage}{\textwidth}" ///
		"\footnotesize \textit{Notes:} OLS estimates. Each column reports a separate regression of the change score on treatment indicators and the pre-treatment level of the outcome. Baseline: Static. Robust standard errors in parentheses. Primary outcome: perceived bias (column 3). \sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
		"\end{minipage}" ///
		"\end{table}")


********************************************************************************
* 4. PERMUTATION TESTS
********************************************************************************

foreach outcome in bias trust oneside share {
	di as txt _n ">> change_`outcome'"
	di "  Chatbot vs Static:"
	permtest2 change_`outcome' if treatment != 2, by(treatment)
	di "  Comment vs Static:"
	permtest2 change_`outcome' if treatment != 3, by(treatment)
	di "  Chatbot vs Comment:"
	permtest2 change_`outcome' if treatment != 1, by(treatment)
}


********************************************************************************
* 5. MULTIPLE HYPOTHESIS TESTING (3 pairwise on Bias)
********************************************************************************

* Bonferroni-Holm
reg change_bias ib1.treatment pre_bias, robust
local p1 = 2*ttail(e(df_r), abs(_b[3.treatment]/_se[3.treatment]))
local p2 = 2*ttail(e(df_r), abs(_b[2.treatment]/_se[2.treatment]))
reg change_bias ib2.treatment pre_bias if treatment != 1, robust
local p3 = 2*ttail(e(df_r), abs(_b[3.treatment]/_se[3.treatment]))

matrix P = (`p1', 1 \ `p2', 2 \ `p3', 3)
mata: st_matrix("Ps", sort(st_matrix("P"), 1))
di as txt _n "Bonferroni-Holm (K=3, Bias pairwise):"
forvalues i = 1/3 {
	local pv = Ps[`i', 1]
	local ix = Ps[`i', 2]
	if `ix'==1 local nm "Chatbot vs Static"
	if `ix'==2 local nm "Comment vs Static"
	if `ix'==3 local nm "Chatbot vs Comment"
	local hp = min(1, `pv' * (3 - `i' + 1))
	if `i' > 1 local hp = max(`hp', `prev')
	local prev = `hp'
	di as txt "  `nm'  raw=" %8.5f `pv' "  Holm=" %8.4f `hp'
}

* Westfall-Young
capture drop chatbot comment_d chat_vs_comm
gen chatbot = (treatment == 3)
gen comment_d = (treatment == 2)
gen chat_vs_comm = (treatment == 3) if treatment != 1

wyoung, cmd( ///
	"reg change_bias chatbot pre_bias if treatment != 2, robust" ///
	"reg change_bias comment_d pre_bias if treatment != 3, robust" ///
	"reg change_bias chat_vs_comm pre_bias if treatment != 1, robust" ///
	) familyp(chatbot comment_d chat_vs_comm) ///
	bootstraps(5000) seed(12345)


********************************************************************************
* 6. COUNTRY HETEROGENEITY
********************************************************************************

reg change_bias ib1.treatment##i.nation pre_bias, robust
estimates store het_nation
testparm i.treatment#i.nation

esttab het_nation ///
	using "output/tab5_nation.tex", replace ///
	keep(3.treatment 2.treatment 2.nation 3.nation ///
		3.treatment#2.nation 2.treatment#2.nation ///
		3.treatment#3.nation 2.treatment#3.nation) ///
	order(3.treatment 2.treatment 2.nation 3.nation ///
		3.treatment#2.nation 2.treatment#2.nation ///
		3.treatment#3.nation 2.treatment#3.nation) ///
	coeflabels(3.treatment "Chatbot" 2.treatment "Comment" ///
		2.nation "UK" 3.nation "Canada" ///
		3.treatment#2.nation "Chatbot $\times$ UK" ///
		2.treatment#2.nation "Comment $\times$ UK" ///
		3.treatment#3.nation "Chatbot $\times$ Canada" ///
		2.treatment#3.nation "Comment $\times$ Canada") ///
	nomtitles nonumber ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("r2 \$R^2\$" "N Obs.") sfmt(%9.3f %9.0f) ///
	label booktabs fragment ///
	prehead("\begin{table}[htbp]" ///
		"\centering" ///
		"\caption{Treatment Effects on Perceived Bias by Country}" ///
		"\label{tab:nation}" ///
		"\begin{tabular}{lc}" ///
		"\toprule" ///
		" & Change in Perceived Bias \\") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" ///
		"\end{tabular}" ///
		"\par\vspace{4pt}" ///
		"\begin{minipage}{\textwidth}" ///
		"\footnotesize \textit{Notes:} OLS estimates. Dependent variable: change in perceived bias against China (0--100). Controls for pre-treatment bias. Baseline: Static in the US. Robust standard errors in parentheses. \sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
		"\end{minipage}" ///
		"\end{table}")


********************************************************************************
* 7. WITHIN-TREATMENT EXPLORATORY ANALYSIS
********************************************************************************

foreach t in 1 2 3 {
	reg change_bias info_fair info_new info_verify pre_bias if treatment == `t', robust
	estimates store wb_`t'
}

esttab wb_1 wb_2 wb_3 ///
	using "output/tab_within_bias.tex", replace ///
	keep(info_fair info_new info_verify) ///
	order(info_fair info_new info_verify) ///
	coeflabels(info_fair "Fairness evaluation" ///
		info_new "Information novelty" ///
		info_verify "Verification motive") ///
	mtitles("Static" "Comment" "Chatbot") ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("r2 \$R^2\$" "N Obs.") sfmt(%9.3f %9.0f) ///
	label booktabs fragment ///
	prehead("\begin{table}[htbp]" ///
		"\centering" ///
		"\caption{Information Processing and Bias Perception Change by Treatment}" ///
		"\label{tab:withinbias}" ///
		"\begin{tabular}{l*{3}{c}}" ///
		"\toprule" ///
		" & \multicolumn{3}{c}{Change in Perceived Bias (0--100)} \\" ///
		"\cmidrule(lr){2-4}") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" ///
		"\end{tabular}" ///
		"\par\vspace{4pt}" ///
		"\begin{minipage}{\textwidth}" ///
		"\footnotesize \textit{Notes:} OLS estimates within each treatment arm. Dependent variable: change in perceived bias against China (0--100). All regressions control for pre-treatment bias. All information-processing measures are on a 1--7 Likert scale. Robust standard errors in parentheses. \sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
		"\end{minipage}" ///
		"\end{table}")


********************************************************************************
* 8. FIGURES
********************************************************************************

* 8.1 Panel: change scores by treatment
foreach outcome in trust oneside bias share {
	if "`outcome'" == "trust"   local ytitle "Trustworthiness"
	if "`outcome'" == "oneside" local ytitle "One-sidedness"
	if "`outcome'" == "bias"    local ytitle "Perceived Bias (China)"
	if "`outcome'" == "share"   local ytitle "Share Likelihood"

	cibar change_`outcome', over(treatment) bargap(10) ///
		graphopts(title("Change in `ytitle'", size(medlarge)) ///
		ytitle("Change score (0--100)", size(small)) ///
		ylabel(, angle(0) labsize(small)) ///
		yline(0, lcolor(black) lpattern(dash)) ///
		legend(order(1 "Static" 2 "Comment" 3 "Chatbot") rows(1) size(small) position(6)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		name(bar_`outcome', replace))
}
graph combine bar_trust bar_oneside bar_bias bar_share, ///
	rows(2) cols(2) graphregion(color(white)) imargin(small)
graph export "output/fig1_panel.pdf", replace
graph export "output/fig1_panel.png", replace width(1600) height(1200)

* 8.2 Coefficient plot
coefplot main_trust main_oneside main_bias main_share, ///
	keep(2.treatment 3.treatment) ///
	coeflabels(2.treatment = "Comment" 3.treatment = "Chatbot") ///
	xline(0, lcolor(black) lpattern(dash)) ///
	title("Treatment Effects Relative to Static", size(medlarge)) ///
	subtitle("OLS with pre-treatment control", size(small)) ///
	legend(order(2 "Trust" 4 "One-sided" 6 "Bias" 8 "Share") rows(1) size(small) position(6)) ///
	graphregion(color(white)) plotregion(color(white)) ///
	msymbol(diamond) msize(medium) grid(none)
graph export "output/fig2_coefplot.pdf", replace

* 8.3 Box plots
foreach outcome in trust oneside bias share {
	if "`outcome'" == "trust"   local ytitle "Trustworthiness"
	if "`outcome'" == "oneside" local ytitle "One-sidedness"
	if "`outcome'" == "bias"    local ytitle "Perceived Bias (China)"
	if "`outcome'" == "share"   local ytitle "Share Likelihood"
	graph box change_`outcome', over(treatment, label(labsize(small))) ///
		title("Change in `ytitle'", size(medlarge)) ///
		ytitle("Change score", size(small)) ///
		yline(0, lcolor(red) lpattern(dash)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		medline(lcolor(white) lwidth(medium)) ///
		name(box_`outcome', replace)
}
graph combine box_trust box_oneside box_bias box_share, ///
	rows(2) cols(2) graphregion(color(white)) imargin(small)
graph export "output/fig3_boxplots.pdf", replace

* 8.4 Mechanism figure
cibar info_fair, over(treatment) bargap(10) ///
	graphopts(title("Fairness Evaluation", size(medlarge)) ///
	ytitle("Mean (1--7)", size(small)) ylabel(1(1)7, angle(0)) ///
	legend(order(1 "Static" 2 "Comment" 3 "Chatbot") rows(1) size(small) position(6)) ///
	graphregion(color(white)) plotregion(color(white)) name(m_fair, replace))
cibar info_new, over(treatment) bargap(10) ///
	graphopts(title("Information Novelty", size(medlarge)) ///
	ytitle("Mean (1--7)", size(small)) ylabel(1(1)7, angle(0)) ///
	legend(order(1 "Static" 2 "Comment" 3 "Chatbot") rows(1) size(small) position(6)) ///
	graphregion(color(white)) plotregion(color(white)) name(m_new, replace))
cibar info_verify, over(treatment) bargap(10) ///
	graphopts(title("Verification Motive", size(medlarge)) ///
	ytitle("Mean (1--7)", size(small)) ylabel(1(1)7, angle(0)) ///
	legend(order(1 "Static" 2 "Comment" 3 "Chatbot") rows(1) size(small) position(6)) ///
	graphregion(color(white)) plotregion(color(white)) name(m_verify, replace))
graph combine m_fair m_new m_verify, ///
	rows(1) cols(3) graphregion(color(white)) imargin(small)
graph export "output/fig5_mechanisms.pdf", replace


********************************************************************************
* 9. SAVE
********************************************************************************

drop treat_raw chatbot comment_d chat_vs_comm
save "news_check_analysis.dta", replace

di _n "ANALYSIS COMPLETE — N=" _N
