# Primary Analysis: Effects of AI-Based Interventions on News Bias Perceptions

**Date**: 2026-04-15
**Data**: US (n=333) + UK (n=328) pooled online experiment, N=661
**Treatments**: Chatbot (interactive AI, n=268) / Comment (tailored static AI message, n=213) / Static (generic message, n=180)
**Outcomes**: Change in trustworthiness, one-sidedness, perceived bias against China, sharing likelihood (all 0-100 scales, post minus pre)

---

## 1. Randomization and Balance

The randomization is adequate but not pristine. Of eight baseline covariates tested, six show no significant imbalance. Two show marginal imbalance: **income** (F=4.31, p=0.014) and **trust in AI** (F=3.57, p=0.029). In both cases, the Static arm is the outlier — lower income (5.08 vs. 5.50-5.53) and lower AI trust (4.09 vs. 4.31-4.46). The joint F-test from the multinomial logit (chi2(16)=24.46, p=0.080) fails to reject balance at conventional levels but sits uncomfortably close.

More reassuringly, **all four pre-treatment outcomes are well-balanced** across arms (all p > 0.54). Since these are measured on the same scales as the post-treatment outcomes, this provides strong evidence that compositional differences are not confounding our estimates.

The AI trust imbalance deserves scrutiny since individuals who trust AI more may respond more strongly to AI-generated interventions — this cuts in the direction of inflating the Chatbot effect. However, the fact that ANCOVA and full-model results (controlling for AI trust) are essentially identical to the unadjusted OLS is reassuring.

---

## 2. Descriptive Patterns

The raw change scores reveal a clear pattern: **all three interventions reduced trust and increased perceived one-sidedness, but only the Chatbot meaningfully increased perceived bias against China.**

| Outcome | Chatbot | Comment | Static |
|---|---|---|---|
| Trust | -12.85*** | -12.27*** | -10.42*** |
| One-sidedness | +6.97*** | +5.55** | +3.61 (p=.097) |
| **Bias (China)** | **+8.81\*\*\*** | +3.36 (p=.063) | -0.93 (p=.666) |
| Sharing | -3.44*** | -3.86*** | -3.25* |

**Trust**: All arms decline by 10-13 points. This suggests the article itself, or simply the act of re-evaluation, drives the trust decline rather than any treatment-specific mechanism.

**One-sidedness**: Suggestive monotone gradient (more interactive = larger shift), but between-arm differences are not statistically significant.

**Bias against China**: The standout result. A steep, monotone dose-response: Chatbot (+8.81) > Comment (+3.36) > Static (-0.93). Only the Chatbot arm shows a clearly significant within-arm shift.

**Sharing**: All arms reduce sharing by 3-4 points, with no between-arm differences.

**On magnitudes**: The Chatbot effect on bias (~9 points on a 0-100 scale, d ~0.35-0.38 vs. Static) is meaningful for a light-touch online intervention — comparable to many published field experiments in information provision.

---

## 3. Main Treatment Effects

Results are presented across three specifications. Base category is Chatbot (Stata default), so coefficients represent deviations from the Chatbot mean.

### 3.1 Perceived Bias Against China (Primary Finding)

| Specification | Comment vs. Chatbot | Static vs. Chatbot | R-squared |
|---|---|---|---|
| OLS | -5.46 (p=0.018) | -9.75 (p<0.001) | 0.023 |
| ANCOVA | -5.43 (p=0.009) | -9.22 (p<0.001) | 0.202 |
| Full model (+demographics) | -5.48 (p=0.008) | -8.78 (p<0.001) | 0.215 |

The treatment coefficients are **remarkably stable** across specifications. The Static coefficient moves from -9.75 to -9.22 to -8.78; the Comment coefficient barely moves at all (-5.46 to -5.43 to -5.48). When an estimate barely changes as you layer on controls, it means observable confounders are not driving the result. Combined with randomization, this is about as clean as it gets.

The R-squared jump from 0.023 (OLS) to 0.202 (ANCOVA) comes from the pre-treatment bias control (coef = -0.43), reflecting strong mean reversion on bounded scales — a mechanical feature, not a substantive finding.

### 3.2 All Other Outcomes: Null

For trust, one-sidedness, and sharing, no pairwise comparison approaches significance across any specification (all p > 0.13). Treatment assignment has no detectable differential effect on these outcomes.

### 3.3 The Specificity Matters

The result is strikingly specific: the Chatbot affects perceived bias against China and essentially nothing else. This specificity is a **strength**. A treatment that moved everything in the same direction might suggest a demand effect or a "be more critical" heuristic. The fact that the Chatbot selectively moves anti-China bias perceptions — while leaving generic trust and one-sidedness unchanged — suggests a targeted mechanism: the chatbot is directing attention toward a specific dimension of the article's framing.

---

## 4. Robustness: Permutation Tests

The Fisher-Pitman permutation tests confirm the OLS results:

| Contrast | change_bias | change_trust | change_oneside | change_share |
|---|---|---|---|---|
| Chatbot vs. Static | **p < 0.001** | p=0.225 | p=0.205 | p=0.905 |
| Chatbot vs. Comment | **p = 0.016** | p=0.756 | p=0.562 | p=0.782 |
| Comment vs. Static | p = 0.125 | p=0.396 | p=0.489 | p=0.724 |

Permutation tests make no distributional assumptions and are exact under the sharp null. The concordance with parametric results means our findings are not artifacts of distributional assumptions or outliers.

**Assessment**: The main finding — Chatbot increases perceived anti-China bias relative to both other arms — is robust across every specification and inference method.

---

## 5. Cross-National Comparison

All treatment-by-nation interaction F-tests are insignificant (all p > 0.17). We **cannot reject homogeneous treatment effects across the US and UK**.

Descriptively, for change_bias:

| Arm | US | UK |
|---|---|---|
| Chatbot | +11.11 | +6.30 |
| Comment | +1.67 | +5.03 |
| Static | -0.09 | -1.72 |

The Chatbot effect appears larger in the US, but the interaction (p=0.581) is far from significant. With ~90-130 per cell, we are substantially underpowered for interaction effects — detecting interactions typically requires ~4x the sample needed for main effects.

The cross-national results are better used for **external validity** ("the effect replicates across two English-speaking countries") than for testing moderating hypotheses.

---

## 6. Overall Interpretation

**Central finding**: An interactive AI chatbot conversation about a news article significantly increases participants' perception that the article is biased against China, by approximately 9 points on a 0-100 scale relative to a passive control. A tailored static comment produces an intermediate but weaker effect (~4 points). Neither intervention differentially affects trust, one-sidedness, or sharing intentions.

**The dose-response pattern is important.** Chatbot > Comment > Static maps directly onto treatment interactivity. This ordering is more consistent with a causal story than with confounding or chance.

**What this does not tell us**: The experiment establishes that the chatbot changes *perceptions* of bias. It does not tell us whether those changed perceptions are **accurate** (debiasing — helping participants see genuine bias) or **inaccurate** (rebiasing — inducing a false perception). This distinction is critical for policy and requires independent content analysis of the article.

---

## 7. Caveats and Limitations

1. **Multiple comparisons.** Four outcomes tested. The main contrast (Chatbot vs. Static, p<0.001) survives Bonferroni correction easily (adjusted p<0.004). The Chatbot vs. Comment contrast (p~0.009-0.018) is more vulnerable (Bonferroni-adjusted: p=0.036-0.072). Whether change_bias was pre-specified as primary matters.

2. **AI trust imbalance.** The Chatbot arm has higher baseline AI trust. Controlled for in the full model with no change to results, but worth flagging.

3. **Demand effects.** If operating, we would expect all outcomes to move — not just bias. The specificity is inconsistent with a simple demand story.

4. **Content confounding.** We do not know what the chatbot actually said. If it systematically argued the article was anti-China, the effect is "exposure to a specific argument" rather than "interactive AI engagement." This is a first-order concern.

5. **External validity.** Single article, single topic (China), English-speaking online samples. Results may be topic-specific.

6. **No behavioral outcomes.** All outcomes are self-reported perceptions. No actual sharing or media consumption behavior observed.

---

## 8. Suggested Next Steps

### High Priority

- **Content analysis of chatbot messages** — code for directional content to separate interactivity mechanism from content mechanism
- **Dose-response within chatbot arm** — test whether more chat rounds produce larger effects
- **Heterogeneity by baseline AI trust and political orientation** — key moderators for interpretation
- **Romano-Wolf multiple testing correction** across the four outcomes

### Medium Priority

- Specification curve / multiverse analysis
- Complier analysis (LATE if engagement data available)
- Attrition analysis by arm

### Future Work

- Follow-up mechanism experiment: 2x2 crossing {chatbot, static text} x {anti-bias content, neutral content}
- Persistence measurement (1-week, 1-month re-survey)
- Behavioral outcomes (incentivized sharing decisions)
- Replication with multiple articles/topics

---

## Summary Table

| Contrast | Effect (pts) | OLS p | ANCOVA p | Full model p | Permutation p |
|---|---|---|---|---|---|
| Chatbot vs. Static (bias) | **+9.75** | **<0.001** | **<0.001** | **<0.001** | **<0.001** |
| Chatbot vs. Comment (bias) | **+5.46** | **0.018** | **0.009** | **0.008** | **0.016** |
| Comment vs. Static (bias) | +4.29 | ~0.06 | — | — | 0.125 |
| All other outcomes | — | Null | Null | Null | Null |

---

## Figures

All figures saved to `output/`:

| Figure | Description |
|---|---|
| `fig_panel_all_outcomes.png` | Core result — 4 outcomes by treatment with 95% CIs |
| `fig_panel_by_nation.png` | Treatment effects split by US vs UK |
| `fig_change_[outcome]_by_treatment.png` | Individual bar charts (4 files) |
| `fig_boxplots_all.png` | Full distributions by treatment |
| `fig_kdensity_all.png` | Kernel density overlays |
| `fig_scatter_prepost.png` | Pre vs post with 45-degree line |
| `fig_coefplot_ols.png` | Coefficient plot (OLS) |
| `fig_coefplot_ancova.png` | Coefficient plot (ANCOVA) |
| `fig_age_by_treatment.png` | Balance: age distribution |
| `fig_liberal_by_treatment.png` | Balance: political orientation |
| `fig_treatment_duration.png` | Engagement: treatment duration by arm |

---

**Bottom line**: AI chatbot interactions can meaningfully shift how people perceive bias in news coverage, and they do so more effectively than static interventions. Whether this is a feature or a bug depends entirely on the accuracy of the perceptions being induced.
