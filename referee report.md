# Referee-Style Review and Improvement Plan

## Summary
- Produce a formal experimental-economics referee memo grounded in the current repo artifacts: [primary_analysis.do](/abs/path/c:/Users/Administrator/Desktop/bias_news_llm/primary_analysis.do), [primary_analysis_report.tex](/abs/path/c:/Users/Administrator/Desktop/bias_news_llm/primary_analysis_report.tex), and [primary_analysis_summary.md](/abs/path/c:/Users/Administrator/Desktop/bias_news_llm/primary_analysis_summary.md).
- Organize the memo into `Major Concerns`, `Minor Concerns`, and `Revision Plan`, with the major concerns prioritized by threat to causal interpretation and publication credibility.
- Anchor each critique in specific repo evidence rather than generic econometrics advice.

## Key Review Points
- Reproducibility and sample construction:
  - Flag the unresolved sample inconsistency across artifacts: report/tables use `N=670`, the summary states `N=661`, and the source country files currently contain `333` US observations and `337` UK observations.
  - Note that the repo lacks a transparent preprocessing/exclusion pipeline from the raw CSV exports to the final `.dta` files, so exclusion rules cannot be audited.
  - Flag that the pooled analysis file does not retain a country identifier, yet the summary makes US/UK heterogeneity claims that are not supported by the main script.
  - Flag that the summary references tables/figures and analyses not present in the current executable pipeline.

- Statistical design and inference:
  - Critique the lack of a clean endpoint hierarchy: the write-up treats `bias` as the standout result, but the design description does not clearly pre-specify one primary outcome and secondary outcomes.
  - Critique reliance on within-arm `change != 0` t-tests as causal evidence; these are descriptive and do not identify treatment effects relative to other arms.
  - Critique the breadth of multiple testing: 4 outcomes, 3 treatment arms, multiple pairwise contrasts, several specifications, mechanism regressions, and descriptive significance claims without a familywise or FDR correction strategy.
  - Treat the pooled treatment-effect regressions as intent-to-treat estimates, but recommend that the revised analysis present one primary specification clearly and demote auxiliary specifications.

- Interpretation and causal claims:
  - Challenge the “monotone dose-response” framing because the ordering in means is not enough; the relevant `Comment vs Static` contrast is weak and no formal monotonicity/trend test is shown.
  - Challenge the “specificity is a strength” interpretation as too strong; a null on other outcomes does not by itself rule out demand effects or other broad response mechanisms.
  - Emphasize that the design identifies changes in perceptions, not whether the induced perceptions are accurate or welfare-improving.
  - Flag that the current write-up overstates evidentiary strength with language such as “about as clean as it gets.”

- Mechanisms and mediation:
  - Critique the mediation section as post-treatment associational analysis, not credible causal mediation.
  - Highlight that the claimed verification mechanism is especially weak for the main `Chatbot vs Static` contrast because the verification measure is not clearly higher for Chatbot than Static, and adding the mechanism barely changes the Static coefficient.
  - Recommend reframing these results as exploratory correlates unless mediator timing/design supports a true mediation claim.

## Analysis Interface Changes
- Define one primary estimand explicitly:
  - ITT effect of `Chatbot` versus `Static` on post-treatment perceived bias, controlling for pre-treatment bias.
- Define secondary estimands explicitly:
  - `Chatbot vs Comment`, `Comment vs Static`, and all non-bias outcomes as secondary/exploratory unless pre-registered otherwise.
- Define one authoritative analysis sample:
  - A documented participant flow from raw CSV to final estimation sample, with counts by country and treatment.
- No software API changes are needed; the changes are to the analysis specification, reporting hierarchy, and reproducibility pipeline.

## Improvement Plan
- Rebuild the data pipeline:
  - Create a documented sample-construction step from raw CSV exports to the pooled analysis dataset.
  - Preserve country in the pooled file and report exclusions by country and treatment.
  - Add a participant flow table so the final `N` is auditable.

- Tighten the main empirical strategy:
  - Present a single primary regression for the main claim and report pairwise contrasts as planned comparisons.
  - Keep the bias outcome primary if that is the intended claim; otherwise rewrite the paper as a multiple-outcome study and adjust inference accordingly.
  - Add multiple-testing correction for the outcome family and clearly state which claims survive it.

- Reframe mechanism and heterogeneity sections:
  - Relabel the current mediation results as exploratory post-treatment associations.
  - Add content analysis of chatbot/comment text before attributing the effect to interactivity rather than message content.
  - Only report US/UK heterogeneity after restoring country to the executable pipeline and generating interaction results from that pipeline.

- Rewrite the interpretation:
  - Tone down claims of specificity, dose-response, and mechanism.
  - State clearly that the experiment shows a shift in perceived anti-China bias, not the truth or falsity of that perception.
  - Separate internal validity claims from external-validity claims about countries, topics, and platforms.

## Test Plan
- Verify that one executable pipeline reproduces every reported sample count, coefficient, table, and figure.
- Verify that every table/figure referenced in the summary or report is actually generated by the analysis pipeline.
- Re-estimate the main bias effect under the revised primary specification and report corrected inference.
- Confirm whether country heterogeneity is estimable from the retained analysis dataset before keeping any cross-national claims.
- Check that any mechanism claim is labeled exploratory unless supported by a stronger design.

## Assumptions and Defaults
- The deliverable is a referee-style memo, not code changes.
- The review will prioritize analysis, inference, and interpretation over prose polish.
- Reproducibility issues are in scope because they materially affect credibility of the empirical claims.
- When artifacts conflict, the executable script and observed data files will be treated as more authoritative than the narrative summary.
