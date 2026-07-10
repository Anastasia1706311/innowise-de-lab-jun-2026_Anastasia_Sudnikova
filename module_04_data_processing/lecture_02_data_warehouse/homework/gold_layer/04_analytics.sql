-- ============================================
-- АНАЛИТИЧЕСКИЙ ЗАПРОС 1: Выручка по месяцам и магазинам
-- ============================================

SELECT
    d.year_num,
    d.month_name,
    sh.city_name,
    ROUND(SUM(f.net_revenue), 2) AS total_revenue,
    COUNT(DISTINCT f.sales_id) AS sales_count,
    ROUND(AVG(f.net_revenue), 2) AS avg_check
FROM gold.fact_sales f
JOIN gold.dim_date d ON f.date_key = d.date_key
JOIN gold.dim_shop sh ON f.shop_key = sh.shop_key
GROUP BY d.year_num, d.month_name, sh.city_name
ORDER BY d.year_num DESC, d.month_name, sh.city_name;

-- ============================================
-- АНАЛИТИЧЕСКИЙ ЗАПРОС 2: Топ-10 клиентов
-- ============================================

SELECT
    c.full_name,
    c.city_id,
    COUNT(f.sales_id) AS purchases,
    ROUND(SUM(f.net_revenue), 2) AS total_spent,
    ROUND(AVG(f.net_revenue), 2) AS avg_check
FROM gold.fact_sales f
JOIN gold.dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.full_name, c.city_id
ORDER BY total_spent DESC
LIMIT 10;

-- ============================================
-- АНАЛИТИЧЕСКИЙ ЗАПРОС 3: Анализ продаж по сотрудникам
-- ============================================

SELECT
    e.full_name AS employee_name,
    sh.shop_id,
    COUNT(DISTINCT f.sales_id) AS transactions,
    SUM(f.quantity) AS items_sold,
    ROUND(SUM(f.net_revenue), 2) AS total_revenue,
    ROUND(AVG(f.net_revenue), 2) AS avg_sale_value
FROM gold.fact_sales f
JOIN gold.dim_employee e ON f.employee_key = e.employee_key
JOIN gold.dim_shop sh ON f.shop_key = sh.shop_key
WHERE e.is_current = TRUE
GROUP BY e.full_name, sh.shop_id
ORDER BY total_revenue DESC
LIMIT 20;

-- ============================================
-- АНАЛИТИЧЕСКИЙ ЗАПРОС 4: Самые продаваемые товары
-- ============================================

SELECT
    p.product_name,
    p.category_name,
    SUM(f.quantity) AS total_quantity_sold,
    COUNT(DISTINCT f.sales_id) AS purchase_count,
    ROUND(SUM(f.net_revenue), 2) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_product p ON f.product_key = p.product_key
GROUP BY p.product_name, p.category_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- ============================================
-- АНАЛИТИЧЕСКИЙ ЗАПРОС 5: Средний чек и маржинальность
-- ============================================

SELECT
    d.year_num,
    d.month_name,
    ROUND(AVG(f.net_revenue), 2) AS avg_check,
    ROUND(AVG(f.discount_amount), 2) AS avg_discount,
    ROUND(AVG(f.discount_amount / NULLIF(f.total_price, 0)) * 100, 2) AS avg_discount_percent,
    COUNT(DISTINCT f.sales_id) AS transactions
FROM gold.fact_sales f
JOIN gold.dim_date d ON f.date_key = d.date_key
GROUP BY d.year_num, d.month_name
ORDER BY d.year_num DESC, d.month_name;