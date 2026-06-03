-- DDL to create pristine dimension tables in BigQuery
CREATE OR REPLACE TABLE `app-store-498315.data.dim_app_data` AS
SELECT 101 AS app_id, 'Apple Music' AS app_name, 10.99 AS monthly_price, 90 AS trial_duration_days UNION ALL
SELECT 102, 'Apple TV+', 9.99, 7 UNION ALL
SELECT 103, 'iCloud+', 2.99, 30 UNION ALL
SELECT 104, 'Apple Arcade', 6.99, 30 UNION ALL
SELECT 105, 'Apple Fitness+', 9.99, 30;

CREATE OR REPLACE TABLE `app-store-498315.data.campaign_data` AS
SELECT 201 AS campaign_id, 'Holiday Bundle Promo' AS campaign_name, 'Email' AS channel UNION ALL
SELECT 202, 'iPhone Upgrade Cross-Sell', 'In-App Notification' UNION ALL
SELECT 203, 'TikTok Influencer Campaign', 'Paid Social' UNION ALL
SELECT 204, 'Organic Search', 'Organic';