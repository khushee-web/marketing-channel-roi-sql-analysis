/* ============================================================
   Project: Marketing Channel ROI & Campaign Performance Analysis
   Author: Khushi
   Tool: Google BigQuery (Standard SQL)
   Dataset: Marketing Campaign Performance (Kaggle)
   Table: amex-churn-analysis.marketing_analytics.campaigns

   Goal: Compare ROI across marketing channels to identify
   underperforming channels and recommend budget reallocation.
   ============================================================ */


/* ------------------------------------------------------------
   QUERY 1: Channel-Level Performance Summary
   Purpose: Aggregate spend, ROI, conversion rate, and clicks
   by channel to get a first-pass comparison.
   Note: Acquisition_Cost is stored as text with a "$" sign,
   so it's cleaned with REPLACE + CAST before aggregating.
   ------------------------------------------------------------ */
SELECT
  Channel_Used,
  COUNT(*) AS num_campaigns,
  ROUND(AVG(CAST(REPLACE(Acquisition_Cost, '$', '') AS FLOAT64)), 2) AS avg_acquisition_cost,
  ROUND(AVG(CAST(ROI AS FLOAT64)), 2) AS avg_roi,
  ROUND(AVG(CAST(Conversion_Rate AS FLOAT64)), 4) AS avg_conversion_rate,
  ROUND(AVG(CAST(Clicks AS FLOAT64)), 0) AS avg_clicks
FROM `amex-churn-analysis.marketing_analytics.campaigns`
GROUP BY Channel_Used
ORDER BY avg_roi DESC;

-- Result: Instagram, Twitter, and Facebook all average ~4.0 ROI
-- at similar acquisition cost (~$7,750) and conversion rate (~8%).
-- Pinterest averages only 0.72 ROI at a nearly identical cost --
-- roughly 5.5x lower return for the same spend.


/* ------------------------------------------------------------
   QUERY 2: ROI Distribution Check (Min / Max / Median)
   Purpose: Confirm the ROI gap isn't caused by a few outlier
   campaigns skewing the average -- check the full range.
   ------------------------------------------------------------ */
SELECT
  Channel_Used,
  MIN(CAST(ROI AS FLOAT64)) AS min_roi,
  MAX(CAST(ROI AS FLOAT64)) AS max_roi,
  APPROX_QUANTILES(CAST(ROI AS FLOAT64), 2)[OFFSET(1)] AS median_roi
FROM `amex-churn-analysis.marketing_analytics.campaigns`
GROUP BY Channel_Used
ORDER BY median_roi DESC;

-- Result: Facebook, Instagram, and Twitter all range up to 8.0 ROI
-- with medians around 3.9-4.0. Pinterest's ROI caps out at 1.43
-- across every single campaign -- confirming this is a structural,
-- channel-wide issue, not a few underperforming outliers.


/* ------------------------------------------------------------
   QUERY 3: Channel Ranking by Campaign Goal (CTE + Window Function)
   Purpose: Check whether Pinterest underperforms across all
   campaign objectives, or only specific ones -- using a CTE to
   pre-aggregate, then RANK() to compare channels within each goal.
   ------------------------------------------------------------ */
WITH channel_goal_perf AS (
  SELECT
    Channel_Used,
    Campaign_Goal,
    ROUND(AVG(CAST(ROI AS FLOAT64)), 2) AS avg_roi,
    COUNT(*) AS num_campaigns
  FROM `amex-churn-analysis.marketing_analytics.campaigns`
  GROUP BY Channel_Used, Campaign_Goal
)
SELECT
  Campaign_Goal,
  Channel_Used,
  avg_roi,
  num_campaigns,
  RANK() OVER (PARTITION BY Campaign_Goal ORDER BY avg_roi DESC) AS roi_rank
FROM channel_goal_perf
ORDER BY Campaign_Goal, roi_rank;

-- Result: Pinterest ranks last (4th) across all four campaign
-- goals (Brand Awareness, Increase Sales, Market Expansion,
-- Product Launch), consistently scoring ~0.71-0.72 ROI regardless
-- of objective. Instagram, Twitter, and Facebook cluster tightly
-- around 3.97-4.04 ROI. This confirms the underperformance is
-- channel-specific, not tied to any particular campaign type.


/* ------------------------------------------------------------
   QUERY 4: Estimated Total Return by Channel (Business Impact)
   Purpose: Translate the ROI gap into an estimated dollar impact
   (spend x ROI) -- the framing a Marketing/Finance stakeholder
   actually needs to justify a budget reallocation decision.
   ------------------------------------------------------------ */
SELECT
  Channel_Used,
  COUNT(*) AS num_campaigns,
  ROUND(SUM(CAST(REPLACE(Acquisition_Cost, '$', '') AS FLOAT64)), 2) AS total_spend,
  ROUND(AVG(CAST(ROI AS FLOAT64)), 2) AS avg_roi,
  ROUND(SUM(CAST(REPLACE(Acquisition_Cost, '$', '') AS FLOAT64)) * AVG(CAST(ROI AS FLOAT64)), 2) AS estimated_total_return
FROM `amex-churn-analysis.marketing_analytics.campaigns`
GROUP BY Channel_Used
ORDER BY avg_roi DESC;

-- Result: Despite receiving almost identical total spend
-- (~$580-583M each), Pinterest generated an estimated ~$418M
-- in total return, compared to ~$2.32 billion each for Instagram,
-- Twitter, and Facebook. Same investment level, ~5.5x less return --
-- the clearest possible case for reallocating Pinterest's budget
-- to the other three channels.
