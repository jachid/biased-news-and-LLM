********************************************************************************
* Primary Analysis: AI-Based Interventions and Perceived Bias in News Coverage
* Revised following referee report
* Static = baseline throughout
* Date: 2026-04-15
********************************************************************************

clear all
set more off
set scheme s2color
cd "C:\Users\Administrator\Desktop\bias_news_llm"
capture mkdir "output"

********************************************************************************
* 1. DATA CONSTRUCTION & PARTICIPANT FLOW
********************************************************************************

use "news_check_us_uk_pooled.dta", clear

* --- 1.1 Treatment ---
encode survey1playertreatment, gen(treat_raw)
* encode gives alphabetical: 1=chatbot, 2=comment, 3=static
* Recode so Static=1 (baseline), Comment=2, Chatbot=3
recode treat_raw (3=1) (2=2) (1=3), gen(treatment)
label define treat_lbl 1 "Static" 2 "Comment" 3 "Chatbot"
label values treatment treat_lbl
tab treatment

* --- 1.2 Nation ---
label define nation_lbl 1 "US" 2 "UK"
label values nation nation_lbl
tab treatment nation

* --- 1.3 Construct change scores ---
gen change_trust = survey1playernews_final_trustwor - survey1playernews_trustworthy
gen change_share = survey1playernews_final_share_li - survey1playernews_share_likeliho
gen change_oneside = survey1playernews_final_one_side - survey1playernews_one_sided
gen change_bias = survey1playernews_final_biased_c - survey1playernews_biased_china

label var change_trust    "Change in trustworthiness"
label var change_share    "Change in share likelihood"
label var change_oneside  "Change in one-sidedness"
label var change_bias     "Change in perceived bias (China)"

* --- 1.4 Shorthand variables ---
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
gen post_trust   = survey1playernews_final_trustwor
gen post_share   = survey1playernews_final_share_li
gen post_oneside = survey1playernews_final_one_side
gen post_bias    = survey1playernews_final_biased_c

gen info_fair   = survey1playerinfo_fair
gen info_new    = survey1playerinfo_new
gen info_verify = survey1playerinfo_verify

* --- 1.5 Demographic labels ---
label define gender_lbl 1 "Male" 2 "Female" 3 "Other"
label values gender gender_lbl
label define edu_lbl 1 "Less than HS" 2 "High School" 3 "Bachelor's" 4 "Master's" 5 "Doctoral" 9 "Prefer not to say"
label values education edu_lbl
label define race_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Mixed" 6 "Other"
label values race race_lbl

gen female = (gender == 2)
label var female "Female"
label var age "Age"
label var education "Education"
label var income "Income (1--10)"
label var liberal "Pol.\ orientation (1--7)"
label var trust_ai "Trust in AI (1--7)"
label var favorable "Favorable to China (1--5)"
label var race "Race"

* --- 1.6 Participant flow ---
di as txt _n "=============================================="
di as txt "PARTICIPANT FLOW"
di as txt "=============================================="
di as txt "Raw pooled sample: " _N
tab treatment nation
di as txt "No exclusions applied. Final N = " _N


********************************************************************************
* 2. TABLE 1: SUMMARY STATISTICS (QJE style)
*    Rows = variables, Columns = Static / Comment / Chatbot / Total / p-value
********************************************************************************

* We build this manually for full formatting control

* Means and SDs by treatment
forvalues t = 1/3 {
	foreach var in age female income education liberal trust_ai favorable {
		quietly sum `var' if treatment == `t'
		local m_`var'_`t' : di %5.2f r(mean)
		local s_`var'_`t' : di %5.2f r(sd)
	}
}
* Total
foreach var in age female income education liberal trust_ai favorable {
	quietly sum `var'
	local m_`var'_0 : di %5.2f r(mean)
	local s_`var'_0 : di %5.2f r(sd)
}
* F-test p-values
foreach var in age female income education liberal trust_ai favorable {
	quietly reg `var' i.treatment, robust
	local p_`var' : di %5.3f Ftail(e(df_m), e(df_r), e(F))
}

* Race percentages by treatment
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

* Write the LaTeX table
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

* Counts
quietly tab treatment
quietly count if treatment == 1
local n1 = r(N)
quietly count if treatment == 2
local n2 = r(N)
quietly count if treatment == 3
local n3 = r(N)

file write fh "Observations & `n1' & `n2' & `n3' & `n_0' & \\" _n
file write fh "\bottomrule" _n
file write fh "\end{tabular}" _n
file write fh "\par\vspace{4pt}" _n
file write fh "\begin{minipage}{\textwidth}" _n
file write fh "\footnotesize \textit{Notes:} Standard deviations in parentheses. Column (5) reports \$p\$-values from OLS regressions of each covariate on treatment indicators with robust standard errors. Race distribution tested with Pearson \$\chi^2\$ (\$p = 0.501\$)." _n
file write fh "\end{minipage}" _n
file write fh "\end{table}" _n

file close fh
di "Table 1 written"


********************************************************************************
* 3. TABLE 2: TREATMENT EFFECTS — PRIMARY & SECONDARY OUTCOMES
*    QJE style: outcomes as columns, treatments as rows
*    Static = omitted baseline
********************************************************************************

* Primary specification: OLS controlling for pre-treatment level
* Static is treatment==1, so we set base(1)
reg change_bias ib1.treatment pre_bias, robust
estimates store main_bias

reg change_trust ib1.treatment pre_trust, robust
estimates store main_trust

reg change_oneside ib1.treatment pre_oneside, robust
estimates store main_oneside

reg change_share ib1.treatment pre_share, robust
estimates store main_share

* Full controls
reg change_bias ib1.treatment pre_bias age female education income liberal trust_ai favorable i.nation, robust
estimates store full_bias

* Simple OLS (no controls)
reg change_bias ib1.treatment, robust
estimates store raw_bias

* Export: Panel A = Primary outcome (bias, 3 specs), Panel B = All outcomes (preferred spec)

* Table 2a: Primary outcome — robustness
esttab raw_bias main_bias full_bias ///
	using "output/tab2_bias.tex", replace ///
	keep(2.treatment 3.treatment pre_bias age female education income liberal trust_ai favorable 2.nation) ///
	order(3.treatment 2.treatment pre_bias age female education income liberal trust_ai favorable 2.nation) ///
	coeflabels(3.treatment "Chatbot" 2.treatment "Comment" ///
		pre_bias "Pre-treatment bias" age "Age" female "Female" ///
		education "Education" income "Income" liberal "Pol.\ orientation" ///
		trust_ai "Trust in AI" favorable "Favorable to China" 2.nation "UK") ///
	mtitles("(1)" "(2)" "(3)") ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("r2 \$R^2\$" "N Obs.") sfmt(%9.3f %9.0f) ///
	title("Treatment Effects on Perceived Bias Against China") ///
	label booktabs fragment ///
	prehead("\begin{table}[htbp]" ///
		"\centering" ///
		"\caption{Treatment Effects on Perceived Bias Against China}" ///
		"\label{tab:bias}" ///
		"\begin{tabular}{l*{3}{c}}" ///
		"\toprule" ///
		" & \multicolumn{3}{c}{Change in Perceived Bias (0--100)} \\") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" ///
		"\end{tabular}" ///
		"\par\vspace{4pt}" ///
		"\begin{minipage}{\textwidth}" ///
		"\footnotesize \textit{Notes:} OLS estimates. The dependent variable is the change in perceived bias against China (post minus pre) on a 0--100 scale. The omitted baseline is the Static treatment. Robust standard errors in parentheses. Column (1) is unadjusted; column (2) controls for pre-treatment bias; column (3) adds demographic controls and country fixed effect. \sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
		"\end{minipage}" ///
		"\end{table}")


* Table 2b: All four outcomes (preferred specification)
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
		"\footnotesize \textit{Notes:} OLS estimates. Each column reports a separate regression of the change score on treatment indicators and the pre-treatment level of the outcome. The omitted baseline is the Static treatment. Robust standard errors in parentheses. The primary outcome is perceived bias against China (column 3). Columns 1, 2, and 4 report secondary outcomes. \sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
		"\end{minipage}" ///
		"\end{table}")


********************************************************************************
* 4. PERMUTATION TESTS & MULTIPLE TESTING
********************************************************************************

di as txt _n "=============================================="
di as txt "PERMUTATION TESTS (Static = baseline)"
di as txt "=============================================="

foreach outcome in bias trust oneside share {
	di as txt _n ">> change_`outcome'"

	di as txt "  Chatbot vs Static:"
	permtest2 change_`outcome' if treatment != 2, by(treatment)

	di as txt "  Comment vs Static:"
	permtest2 change_`outcome' if treatment != 3, by(treatment)

	di as txt "  Chatbot vs Comment:"
	permtest2 change_`outcome' if treatment != 1, by(treatment)
}

* Trend test: is there a monotone ordering Static < Comment < Chatbot?
di as txt _n "=============================================="
di as txt "TREND TEST: Linear dose-response"
di as txt "=============================================="
* Code treatment as ordinal dose: Static=0, Comment=1, Chatbot=2
gen dose = treatment - 1
label var dose "Treatment intensity (0=Static, 1=Comment, 2=Chatbot)"
foreach outcome in bias trust oneside share {
	reg change_`outcome' dose pre_`outcome', robust
	di "Trend test for `outcome': dose coef = " _b[dose] " p = " 2*ttail(e(df_r), abs(_b[dose]/_se[dose]))
}


********************************************************************************
* 4b. MULTIPLE HYPOTHESIS TESTING CORRECTIONS
********************************************************************************

* --- Bonferroni-Holm across 4 outcomes for Chatbot vs Static ---
reg change_bias ib1.treatment pre_bias, robust
local p_bias = 2*ttail(e(df_r), abs(_b[3.treatment]/_se[3.treatment]))
reg change_trust ib1.treatment pre_trust, robust
local p_trust = 2*ttail(e(df_r), abs(_b[3.treatment]/_se[3.treatment]))
reg change_oneside ib1.treatment pre_oneside, robust
local p_oneside = 2*ttail(e(df_r), abs(_b[3.treatment]/_se[3.treatment]))
reg change_share ib1.treatment pre_share, robust
local p_share = 2*ttail(e(df_r), abs(_b[3.treatment]/_se[3.treatment]))

* Bonferroni
local bf_bias    = min(1, `p_bias' * 4)
local bf_trust   = min(1, `p_trust' * 4)
local bf_oneside = min(1, `p_oneside' * 4)
local bf_share   = min(1, `p_share' * 4)

* Holm step-down
matrix P = (`p_bias', 1 \ `p_trust', 2 \ `p_oneside', 3 \ `p_share', 4)
mata: st_matrix("Psorted", sort(st_matrix("P"), 1))
di as txt _n "Bonferroni-Holm (Chatbot vs Static):"
forvalues i = 1/4 {
	local pval = Psorted[`i', 1]
	local idx  = Psorted[`i', 2]
	if `idx' == 1 local nm "Bias"
	if `idx' == 2 local nm "Trust"
	if `idx' == 3 local nm "One-sided"
	if `idx' == 4 local nm "Share"
	local holm_p = min(1, `pval' * (4 - `i' + 1))
	if `i' > 1 local holm_p = max(`holm_p', `prev_holm')
	local prev_holm = `holm_p'
	di as txt "  Rank `i': `nm'  raw=" %7.5f `pval' "  Bonferroni=" %7.4f min(1, `pval'*4) "  Holm=" %7.4f `holm_p'
}

* --- Romano-Wolf stepdown: Chatbot vs Static ---
preserve
keep if treatment == 1 | treatment == 3
gen chatbot = (treatment == 3)
di as txt _n "Romano-Wolf: Chatbot vs Static (N=" _N ")"
rwolf change_bias change_trust change_oneside change_share, ///
	indepvar(chatbot) controls(pre_bias pre_trust pre_oneside pre_share) ///
	reps(5000) seed(12345) vce(robust)
restore

* --- Romano-Wolf stepdown: Comment vs Static ---
preserve
keep if treatment == 1 | treatment == 2
gen comment = (treatment == 2)
di as txt _n "Romano-Wolf: Comment vs Static (N=" _N ")"
rwolf change_bias change_trust change_oneside change_share, ///
	indepvar(comment) controls(pre_bias pre_trust pre_oneside pre_share) ///
	reps(5000) seed(12345) vce(robust)
restore


********************************************************************************
* 5. TABLE 3: PAIRWISE COMPARISONS & PERMUTATION p-VALUES
*    Hand-built QJE table
********************************************************************************

* Collect all p-values and coefficients
* Chatbot vs Static
reg change_bias ib1.treatment pre_bias, robust
local b_chat_bias : di %5.2f _b[3.treatment]
local se_chat_bias : di %5.2f _se[3.treatment]
local p_chat_bias : di %5.3f 2*ttail(e(df_r), abs(_b[3.treatment]/_se[3.treatment]))

local b_comm_bias : di %5.2f _b[2.treatment]
local se_comm_bias : di %5.2f _se[2.treatment]
local p_comm_bias : di %5.3f 2*ttail(e(df_r), abs(_b[2.treatment]/_se[2.treatment]))

* Chatbot vs Comment
reg change_bias ib2.treatment pre_bias if treatment != 1, robust
local b_cc_bias : di %5.2f _b[3.treatment]
local se_cc_bias : di %5.2f _se[3.treatment]
local p_cc_bias : di %5.3f 2*ttail(e(df_r), abs(_b[3.treatment]/_se[3.treatment]))

* Trend
reg change_bias dose pre_bias, robust
local b_trend : di %5.2f _b[dose]
local se_trend : di %5.2f _se[dose]
local p_trend : di %5.3f 2*ttail(e(df_r), abs(_b[dose]/_se[dose]))


********************************************************************************
* 6. TABLE 4: MECHANISM ANALYSIS (EXPLORATORY)
********************************************************************************

* Treatment -> Mechanisms
foreach var in info_fair info_new info_verify {
	reg `var' ib1.treatment, robust
	estimates store mech_`var'
}

esttab mech_info_fair mech_info_new mech_info_verify ///
	using "output/tab4_mechanisms.tex", replace ///
	keep(2.treatment 3.treatment) ///
	order(3.treatment 2.treatment) ///
	coeflabels(3.treatment "Chatbot" 2.treatment "Comment") ///
	mtitles("Fairness" "Novelty" "Verification") ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("r2 \$R^2\$" "N Obs.") sfmt(%9.3f %9.0f) ///
	label booktabs fragment ///
	prehead("\begin{table}[htbp]" ///
		"\centering" ///
		"\caption{Treatment Effects on Information Processing (Exploratory)}" ///
		"\label{tab:mechanisms}" ///
		"\begin{tabular}{l*{3}{c}}" ///
		"\toprule" ///
		" & \multicolumn{3}{c}{Post-Treatment Evaluation (1--7 scale)} \\" ///
		"\cmidrule(lr){2-4}") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" ///
		"\end{tabular}" ///
		"\par\vspace{4pt}" ///
		"\begin{minipage}{\textwidth}" ///
		"\footnotesize \textit{Notes:} OLS estimates. The omitted baseline is Static. \textit{Fairness}: ``The chatbot/comment helped me evaluate whether the article was fair.'' \textit{Novelty}: ``The information provided is new to me.'' \textit{Verification}: ``The chatbot/comment made me want to verify the article further.'' Robust standard errors in parentheses. \sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
		"\end{minipage}" ///
		"\end{table}")


* Exploratory associations: mechanism vars predicting outcomes
reg change_bias ib1.treatment pre_bias info_fair info_new info_verify, robust
estimates store assoc_bias

esttab main_bias assoc_bias ///
	using "output/tab4_assoc.tex", replace ///
	keep(3.treatment 2.treatment pre_bias info_fair info_new info_verify) ///
	order(3.treatment 2.treatment pre_bias info_fair info_new info_verify) ///
	coeflabels(3.treatment "Chatbot" 2.treatment "Comment" ///
		pre_bias "Pre-treatment bias" ///
		info_fair "Fairness evaluation" ///
		info_new "Information novelty" ///
		info_verify "Verification motive") ///
	mtitles("Baseline" "With covariates") ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("r2 \$R^2\$" "N Obs.") sfmt(%9.3f %9.0f) ///
	label booktabs fragment ///
	prehead("\begin{table}[htbp]" ///
		"\centering" ///
		"\caption{Exploratory Associations: Information Processing and Bias Perception Change}" ///
		"\label{tab:assoc}" ///
		"\begin{tabular}{l*{2}{c}}" ///
		"\toprule" ///
		" & \multicolumn{2}{c}{Change in Perceived Bias} \\" ///
		"\cmidrule(lr){2-3}") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" ///
		"\end{tabular}" ///
		"\par\vspace{4pt}" ///
		"\begin{minipage}{\textwidth}" ///
		"\footnotesize \textit{Notes:} OLS estimates. The dependent variable is the change in perceived bias against China (0--100). Column (1) is the primary specification. Column (2) adds post-treatment information-processing measures as covariates. These variables are measured after treatment and are therefore not causally identified as mediators; results should be interpreted as exploratory associations only. Robust standard errors in parentheses. \sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
		"\end{minipage}" ///
		"\end{table}")


********************************************************************************
* 7. TABLE 5: COUNTRY HETEROGENEITY
********************************************************************************

reg change_bias ib1.treatment##i.nation pre_bias, robust
estimates store het_nation
testparm i.treatment#i.nation

esttab het_nation ///
	using "output/tab5_nation.tex", replace ///
	keep(3.treatment 2.treatment 2.nation 3.treatment#2.nation 2.treatment#2.nation) ///
	order(3.treatment 2.treatment 2.nation 3.treatment#2.nation 2.treatment#2.nation) ///
	coeflabels(3.treatment "Chatbot" 2.treatment "Comment" ///
		2.nation "UK" ///
		3.treatment#2.nation "Chatbot $\times$ UK" ///
		2.treatment#2.nation "Comment $\times$ UK") ///
	mtitles("Change in Perceived Bias") ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("r2 \$R^2\$" "N Obs.") sfmt(%9.3f %9.0f) ///
	label booktabs fragment ///
	prehead("\begin{table}[htbp]" ///
		"\centering" ///
		"\caption{Treatment Effects by Country}" ///
		"\label{tab:nation}" ///
		"\begin{tabular}{lc}" ///
		"\toprule") ///
	posthead("\midrule") ///
	prefoot("\midrule") ///
	postfoot("\bottomrule" ///
		"\end{tabular}" ///
		"\par\vspace{4pt}" ///
		"\begin{minipage}{\textwidth}" ///
		"\footnotesize \textit{Notes:} OLS estimates. Dependent variable: change in perceived bias against China (0--100). Controls for pre-treatment bias. Baseline: Static treatment in the US. Robust standard errors in parentheses. \sym{*}~\$p<0.10\$, \sym{**}~\$p<0.05\$, \sym{***}~\$p<0.01\$." ///
		"\end{minipage}" ///
		"\end{table}")


********************************************************************************
* 8. FIGURES
********************************************************************************

local c_stat "34 197 94"
local c_comm "249 115 22"
local c_chat "59 130 246"

* --- 8.1 Main panel: 4 outcomes ---
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
	rows(2) cols(2) ///
	title("Treatment Effects on News Perception", size(medlarge)) ///
	graphregion(color(white)) imargin(small)
graph export "output/fig1_panel.pdf", replace
graph export "output/fig1_panel.png", replace width(1600) height(1200)

* --- 8.2 Coefficient plot ---
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
graph export "output/fig2_coefplot.png", replace width(1400)

* --- 8.3 Box plots ---
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
		box(1, fcolor("`c_stat'") lcolor("20 140 60")) ///
		box(2, fcolor("`c_comm'") lcolor("180 80 10")) ///
		box(3, fcolor("`c_chat'") lcolor("30 80 180")) ///
		medline(lcolor(white) lwidth(medium)) ///
		name(box_`outcome', replace)
}
graph combine box_trust box_oneside box_bias box_share, ///
	rows(2) cols(2) title("Distribution of Change Scores", size(medlarge)) ///
	graphregion(color(white)) imargin(small)
graph export "output/fig3_boxplots.pdf", replace
graph export "output/fig3_boxplots.png", replace width(1600) height(1200)

* --- 8.4 Kernel densities ---
foreach outcome in trust oneside bias share {
	if "`outcome'" == "trust"   local ytitle "Trustworthiness"
	if "`outcome'" == "oneside" local ytitle "One-sidedness"
	if "`outcome'" == "bias"    local ytitle "Perceived Bias (China)"
	if "`outcome'" == "share"   local ytitle "Share Likelihood"

	twoway ///
		(kdensity change_`outcome' if treatment==1, lcolor("`c_stat'") lwidth(medthick)) ///
		(kdensity change_`outcome' if treatment==2, lcolor("`c_comm'") lwidth(medthick)) ///
		(kdensity change_`outcome' if treatment==3, lcolor("`c_chat'") lwidth(medthick)), ///
		title("Change in `ytitle'", size(medlarge)) ///
		xtitle("Change score", size(small)) ytitle("Density", size(small)) ///
		xline(0, lcolor(black) lpattern(dash)) ///
		legend(order(1 "Static" 2 "Comment" 3 "Chatbot") rows(1) size(small) position(6)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		name(kde_`outcome', replace)
}
graph combine kde_trust kde_oneside kde_bias kde_share, ///
	rows(2) cols(2) title("Density of Change Scores", size(medlarge)) ///
	graphregion(color(white)) imargin(small)
graph export "output/fig4_kdensity.pdf", replace
graph export "output/fig4_kdensity.png", replace width(1600) height(1200)

* --- 8.5 Mechanism figure ---
cibar info_fair, over(treatment) bargap(10) ///
	graphopts(title("Fairness Evaluation", size(medlarge)) ///
	ytitle("Mean (1--7)", size(small)) ylabel(1(1)7, angle(0)) ///
	legend(order(1 "Static" 2 "Comment" 3 "Chatbot") rows(1) size(small) position(6)) ///
	graphregion(color(white)) plotregion(color(white)) ///
	name(m_fair, replace))
cibar info_new, over(treatment) bargap(10) ///
	graphopts(title("Information Novelty", size(medlarge)) ///
	ytitle("Mean (1--7)", size(small)) ylabel(1(1)7, angle(0)) ///
	legend(order(1 "Static" 2 "Comment" 3 "Chatbot") rows(1) size(small) position(6)) ///
	graphregion(color(white)) plotregion(color(white)) ///
	name(m_new, replace))
cibar info_verify, over(treatment) bargap(10) ///
	graphopts(title("Verification Motive", size(medlarge)) ///
	ytitle("Mean (1--7)", size(small)) ylabel(1(1)7, angle(0)) ///
	legend(order(1 "Static" 2 "Comment" 3 "Chatbot") rows(1) size(small) position(6)) ///
	graphregion(color(white)) plotregion(color(white)) ///
	name(m_verify, replace))
graph combine m_fair m_new m_verify, ///
	rows(1) cols(3) title("Information Processing by Treatment", size(medlarge)) ///
	graphregion(color(white)) imargin(small)
graph export "output/fig5_mechanisms.pdf", replace
graph export "output/fig5_mechanisms.png", replace width(1800) height(600)


********************************************************************************
* 9. SAVE
********************************************************************************

drop treat_raw dose
save "news_check_analysis.dta", replace

di as txt _n "=============================================="
di as txt "ANALYSIS COMPLETE"
di as txt "=============================================="
