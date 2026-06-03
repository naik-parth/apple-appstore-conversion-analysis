-- ==============================================================================
-- Title: App Store Services - Trial to Paid Conversion Analysis
-- Dialect: Google Standard SQL (BigQuery)
-- ==============================================================================

WITH BaseSubscriptions AS (
    SELECT
        TO_HEX(SHA256(CAST(f.user_id AS STRING))) AS hashed_user_id,
        a.app_name,
        c.campaign_name,
        f.trial_start_date,
        f.trial_end_date,
        f.status,
        f.total_revenue_usd,
        ROW_NUMBER() OVER (
            PARTITION BY f.user_id 
            ORDER BY f.trial_start_date ASC
        ) AS ecosystem_trial_sequence
    FROM `app-store-498315.data.fact_subscriptions` f
    JOIN `app-store-498315.data.dim_app_data` a 
        ON CAST(f.app_id AS INT64) = a.app_id
    JOIN `app-store-498315.data.campaign_data` c 
        ON CAST(f.campaign_id AS INT64) = c.campaign_id
    WHERE CAST(f.trial_end_date AS DATE) <= CURRENT_DATE() 
),

TrialOutcomes AS (
    SELECT
        app_name,
        campaign_name,
        hashed_user_id,
        ecosystem_trial_sequence,
        total_revenue_usd,
        CASE
            WHEN status IN ('Active', 'Canceled') AND total_revenue_usd > 0 THEN 1
            ELSE 0
        END AS did_convert_to_paid
    FROM BaseSubscriptions
),

AggregatedMetrics AS (
    SELECT
        app_name,
        campaign_name,
        COUNT(DISTINCT hashed_user_id) AS total_matured_trials,
        SUM(CASE WHEN ecosystem_trial_sequence = 1 THEN 1 ELSE 0 END) AS first_time_ecosystem_users,
        SUM(did_convert_to_paid) AS total_conversions,
        SUM(total_revenue_usd) AS total_revenue_generated,
        ROUND(
            IEEE_DIVIDE(SUM(did_convert_to_paid) * 100.0, COUNT(DISTINCT hashed_user_id)), 
            2
        ) AS conversion_rate_pct
    FROM TrialOutcomes
    GROUP BY 
        app_name, 
        campaign_name
)

SELECT
    app_name,
    campaign_name,
    total_matured_trials,
    first_time_ecosystem_users,
    conversion_rate_pct,
    total_revenue_generated,
    DENSE_RANK() OVER (
        PARTITION BY app_name 
        ORDER BY conversion_rate_pct DESC
    ) AS campaign_rank_within_app
FROM AggregatedMetrics
ORDER BY 
    app_name ASC, 
    campaign_rank_within_app ASC;