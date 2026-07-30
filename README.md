# Marketing Channel ROI & Campaign Performance Analysis (SQL / BigQuery)

## Problem Statement
Marketing teams need to know which channels deliver the best return so budget can be allocated efficiently across sources. This project analyzes campaign-level performance data across four social media channels to identify underperforming channels and quantify the business case for reallocating spend.

## Dataset
Marketing Campaign Performance dataset (Kaggle), containing approx. 300,000 campaign records across Instagram, Twitter, Facebook, and Pinterest, with fields for acquisition cost, ROI, conversion rate, clicks, impressions, campaign goal, and more.

## Tools
- **Google BigQuery** (Standard SQL)
- CTEs, `CASE`/`REPLACE`/`CAST` for data cleaning, aggregate functions, `APPROX_QUANTILES`, and window functions (`RANK() OVER PARTITION BY`)

## Approach
1. **Channel-level aggregation** — compared average acquisition cost, ROI, conversion rate, and clicks across all four channels.
2. **Distribution check** — verified the ROI gap using min/max/median (not just averages) to rule out outlier skew.
3. **Ranking by campaign goal** — used a CTE to pre-aggregate ROI by channel and goal, then applied a window function to rank channels within each objective (Brand Awareness, Increase Sales, Market Expansion, Product Launch).
4. **Business impact estimate** — translated the ROI gap into an estimated total-return figure (spend × ROI) to frame the finding in terms a Marketing/Finance stakeholder would act on.

## Key Findings
| Channel | Campaigns | Avg. Acquisition Cost | Avg. ROI | Est. Total Return |
|---|---|---|---|---|
| Instagram | 75,101 | $7,726 | 4.01 | approx. $2.33B |
| Twitter | 74,653 | $7,774 | 4.00 | approx. $2.32B |
| Facebook | 75,164 | $7,745 | 3.99 | approx. $2.32B |
| Pinterest | 75,082 | $7,770 | **0.72** | **approx. $418M** |

- **Pinterest underperforms every other channel by approx. 5.5x on ROI**, despite receiving a nearly identical number of campaigns and acquisition cost.
- The gap is **structural, not outlier-driven** — Pinterest's ROI caps out at 1.43 across every single campaign, while other channels range up to 8.0.
- Pinterest ranks **last across all four campaign goals** (Brand Awareness, Increase Sales, Market Expansion, Product Launch) — the underperformance isn't tied to a specific campaign type.
- At near-identical spend levels (approx. $580-583M each), Pinterest generated an estimated **approx. $418M** in return versus **approx. $2.32B** for each of the other three channels.

## Business Recommendation
Reallocate marketing budget away from Pinterest toward Instagram, Twitter, and Facebook, which deliver comparable cost-efficiency but approx. 5.5x higher return. Before fully discontinuing Pinterest spend, investigate channel-specific factors (audience mismatch, ad format limitations, or platform-specific pricing dynamics) that may explain the consistent underperformance.

## Files
- `marketing_channel_roi_analysis.sql` — full commented query set (4 queries: channel aggregation, distribution check, CTE + window function ranking, business impact estimate)
