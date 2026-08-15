-- =============================================================================
-- Northwind Retail Analytics — Validation & reference KPI queries
-- Use these to sanity-check the model AND as the "ground truth" numbers you
-- reconcile each BI tool's dashboard against before taking screenshots.
-- Written for PostgreSQL; swap date functions for SQLite/BigQuery as needed.
-- =============================================================================

SET search_path TO retail_dw;

-- 1. Referential integrity check — should return zero rows for each
SELECT 'orphan_customer' AS check_name, COUNT(*) FROM fact_sales f
    LEFT JOIN dim_customer c ON f.customer_key = c.customer_key WHERE c.customer_key IS NULL;

SELECT 'orphan_product' AS check_name, COUNT(*) FROM fact_sales f
    LEFT JOIN dim_product p ON f.product_key = p.product_key WHERE p.product_key IS NULL;

-- 2. Headline KPI summary (mirrors the Power BI / Looker / Tableau KPI cards)
SELECT
    COUNT(DISTINCT order_id)                                   AS total_orders,
    SUM(quantity)                                                AS total_units_sold,
    ROUND(SUM(net_revenue)::numeric, 2)                          AS total_net_revenue,
    ROUND(SUM(net_revenue - total_cost)::numeric, 2)              AS total_gross_profit,
    ROUND(AVG(net_revenue)::numeric, 2)                            AS avg_line_value,
    ROUND(SUM(net_revenue)::numeric / COUNT(DISTINCT order_id), 2)  AS avg_order_value,
    ROUND(
        100.0 * SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    )                                                                AS return_rate_pct
FROM fact_sales
WHERE order_status <> 'Cancelled';

-- 3. Monthly revenue trend (feeds the trend-analysis view in all 3 tools)
SELECT
    d.year, d.month_num, d.month_name,
    ROUND(SUM(f.net_revenue)::numeric, 2) AS net_revenue,
    COUNT(DISTINCT f.order_id)              AS orders
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.order_status <> 'Cancelled'
GROUP BY d.year, d.month_num, d.month_name
ORDER BY d.year, d.month_num;

-- 4. Revenue by category / segment (feeds the breakdown view)
SELECT
    p.category,
    c.segment,
    ROUND(SUM(f.net_revenue)::numeric, 2) AS net_revenue,
    ROUND(SUM(f.net_revenue - f.total_cost)::numeric, 2) AS gross_profit
FROM fact_sales f
JOIN dim_product p  ON f.product_key = p.product_key
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE f.order_status <> 'Cancelled'
GROUP BY p.category, c.segment
ORDER BY net_revenue DESC;

-- 5. Top 20 products by net revenue (feeds the drill-down/detail view)
SELECT
    p.product_name, p.category, p.subcategory, p.brand,
    SUM(f.quantity)                          AS units_sold,
    ROUND(SUM(f.net_revenue)::numeric, 2)     AS net_revenue,
    ROUND(SUM(f.net_revenue - f.total_cost)::numeric, 2) AS gross_profit
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
WHERE f.order_status <> 'Cancelled'
GROUP BY p.product_name, p.category, p.subcategory, p.brand
ORDER BY net_revenue DESC
LIMIT 20;

-- 6. Channel performance (used for the channel filter / slicer)
SELECT
    ch.channel_name, ch.channel_type,
    ROUND(SUM(f.net_revenue)::numeric, 2) AS net_revenue,
    COUNT(DISTINCT f.order_id)              AS orders,
    ROUND(SUM(f.net_revenue)::numeric / COUNT(DISTINCT f.order_id), 2) AS avg_order_value
FROM fact_sales f
JOIN dim_channel ch ON f.channel_key = ch.channel_key
WHERE f.order_status <> 'Cancelled'
GROUP BY ch.channel_name, ch.channel_type
ORDER BY net_revenue DESC;

-- 7. Geography breakdown (used for the map/region visual)
SELECT
    g.country, g.region, g.state_province,
    ROUND(SUM(f.net_revenue)::numeric, 2) AS net_revenue
FROM fact_sales f
JOIN dim_geography g ON f.geography_key = g.geography_key
WHERE f.order_status <> 'Cancelled'
GROUP BY g.country, g.region, g.state_province
ORDER BY net_revenue DESC;
