-- ============================================
-- СОЗДАНИЕ СХЕМЫ MART
-- ============================================

CREATE SCHEMA IF NOT EXISTS mart;

-- ============================================
-- MART 1: mart_daily_anomaly (Ежедневные отклонения)
-- ============================================

CREATE OR REPLACE VIEW mart.mart_daily_anomaly AS
WITH daily_revenue AS (
    SELECT
        d.full_date,
        sh.shop_id,
        SUM(f.net_revenue) AS daily_revenue
    FROM gold.fact_sales f
    JOIN gold.dim_date d ON f.date_key = d.date_key
    JOIN gold.dim_shop sh ON f.shop_key = sh.shop_key
    GROUP BY d.full_date, sh.shop_id
),
expected_revenue AS (
    SELECT
        full_date,
        shop_id,
        daily_revenue,
        AVG(daily_revenue) OVER (
            PARTITION BY shop_id
            ORDER BY full_date
            ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
        ) AS expected_revenue
    FROM daily_revenue
)
SELECT
    full_date,
    shop_id,
    daily_revenue,
    COALESCE(expected_revenue, daily_revenue) AS expected_revenue,
    CASE
        WHEN expected_revenue IS NOT NULL AND expected_revenue > 0
        THEN ROUND(((daily_revenue - expected_revenue) / expected_revenue) * 100, 2)
        ELSE 0
    END AS uplift
FROM expected_revenue
ORDER BY full_date DESC, shop_id;

-- ============================================
-- MART 2: mart_shop_daily (Географическое распределение)
-- ============================================

CREATE OR REPLACE VIEW mart.mart_shop_daily AS
SELECT
    loc.country_name,
    loc.city_name,
    sh.shop_address,
    sh.shop_id,
    COUNT(DISTINCT f.sales_id) AS total_transactions,
    SUM(f.quantity) AS total_items_sold,
    ROUND(AVG(f.net_revenue), 2) AS avg_revenue_per_sale,
    ROUND(SUM(f.net_revenue), 2) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_shop sh ON f.shop_key = sh.shop_key
JOIN gold.dim_location loc ON sh.city_id = loc.city_id
GROUP BY loc.country_name, loc.city_name, sh.shop_address, sh.shop_id
ORDER BY total_revenue DESC;

-- ============================================
-- MART 3: mart_customer_behavior (Поведение клиентов)
-- ============================================

CREATE OR REPLACE VIEW mart.mart_customer_behavior AS
WITH customer_stats AS (
    SELECT
        c.customer_id,
        COUNT(f.sales_id) AS purchase_count,
        SUM(f.net_revenue) AS total_spent,
        MAX(d.full_date) AS last_purchase_date,
        CURRENT_DATE - MAX(d.full_date) AS days_since_last_purchase
    FROM gold.dim_customer c
    JOIN gold.fact_sales f ON c.customer_key = f.customer_key
    JOIN gold.dim_date d ON f.date_key = d.date_key
    GROUP BY c.customer_id
),
customer_segments AS (
    SELECT
        customer_id,
        purchase_count,
        total_spent,
        CASE
            WHEN days_since_last_purchase <= 30 THEN 'Active'
            WHEN days_since_last_purchase <= 90 THEN 'At Risk'
            ELSE 'Inactive'
        END AS customer_status,
        CASE
            WHEN total_spent >= 1000 THEN 'High Value'
            WHEN total_spent >= 500 THEN 'Medium Value'
            WHEN total_spent >= 100 THEN 'Low Value'
            ELSE 'Very Low Value'
        END AS revenue_segment
    FROM customer_stats
)
SELECT
    customer_status,
    revenue_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spent), 2) AS avg_spent,
    ROUND(SUM(total_spent), 2) AS total_revenue
FROM customer_segments
GROUP BY customer_status, revenue_segment
ORDER BY customer_status, revenue_segment;

-- ============================================
-- MART 4: mart_employee_performance (Эффективность сотрудников)
-- ============================================

CREATE OR REPLACE VIEW mart.mart_employee_performance AS
WITH employee_stats AS (
    SELECT
        e.employee_id,
        e.full_name AS employee_name,
        sh.shop_id,
        COUNT(DISTINCT f.sales_id) AS total_sales,
        SUM(f.quantity) AS total_items_sold,
        SUM(f.net_revenue) AS total_revenue,
        ROUND(AVG(f.net_revenue), 2) AS avg_sale_value
    FROM gold.dim_employee e
    JOIN gold.fact_sales f ON e.employee_key = f.employee_key
    JOIN gold.dim_shop sh ON f.shop_key = sh.shop_key
    GROUP BY e.employee_id, e.full_name, sh.shop_id
),
percentiles AS (
    SELECT
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_revenue) AS p75,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_revenue) AS p50
    FROM employee_stats
)
SELECT
    es.employee_id,
    es.employee_name,
    es.shop_id,
    es.total_sales,
    es.total_items_sold,
    es.total_revenue,
    es.avg_sale_value,
    RANK() OVER (ORDER BY es.total_revenue DESC) AS revenue_rank,
    CASE
        WHEN es.total_revenue >= p.p75 THEN 'Top Performer'
        WHEN es.total_revenue >= p.p50 THEN 'Average'
        ELSE 'Underperformer'
    END AS performance_tier
FROM employee_stats es
CROSS JOIN percentiles p
ORDER BY es.total_revenue DESC;

-- ============================================
-- MART 5: mart_product_seasonality (Сезонность продуктов)
-- ============================================

CREATE OR REPLACE VIEW mart.mart_product_seasonality AS
WITH monthly_product_sales AS (
    SELECT
        p.category_name,
        d.month_name,
        d.year_num,
        SUM(f.quantity) AS total_quantity_sold,
        SUM(f.net_revenue) AS total_revenue,
        COUNT(DISTINCT f.sales_id) AS total_transactions
    FROM gold.fact_sales f
    JOIN gold.dim_product p ON f.product_key = p.product_key
    JOIN gold.dim_date d ON f.date_key = d.date_key
    GROUP BY p.category_name, d.month_name, d.year_num
),
monthly_rank AS (
    SELECT
        category_name,
        month_name,
        year_num,
        total_quantity_sold,
        total_revenue,
        total_transactions,
        RANK() OVER (PARTITION BY category_name ORDER BY total_quantity_sold DESC) AS sales_rank
    FROM monthly_product_sales
)
SELECT
    category_name,
    month_name,
    year_num,
    total_quantity_sold,
    total_revenue,
    total_transactions,
    sales_rank,
    CASE
        WHEN sales_rank = 1 THEN 'Peak'
        WHEN sales_rank <= 3 THEN 'High'
        ELSE 'Normal'
    END AS seasonality_pattern
FROM monthly_rank
WHERE sales_rank <= 5
ORDER BY category_name, sales_rank;