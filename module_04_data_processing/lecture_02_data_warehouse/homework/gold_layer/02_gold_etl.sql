-- ============================================
-- ИДЕМПОТЕНТНАЯ ЗАГРУЗКА: Очищаем Gold перед загрузкой
-- ============================================

TRUNCATE TABLE gold.fact_sales CASCADE;
TRUNCATE TABLE gold.dim_product CASCADE;
TRUNCATE TABLE gold.dim_customer CASCADE;
TRUNCATE TABLE gold.dim_shop CASCADE;
TRUNCATE TABLE gold.dim_employee CASCADE;
TRUNCATE TABLE gold.dim_location CASCADE;
TRUNCATE TABLE gold.dim_date CASCADE;

-- ============================================
-- 1. ЗАГРУЗКА dim_date
-- ============================================

INSERT INTO gold.dim_date (date_key, full_date, day_of_week, week_num, month_num, month_name, quarter_num, year_num, is_weekend)
SELECT
    DISTINCT EXTRACT(YEAR FROM s.sales_timestamp) * 10000 + EXTRACT(MONTH FROM s.sales_timestamp) * 100 + EXTRACT(DAY FROM s.sales_timestamp) AS date_key,
    s.sales_timestamp::DATE AS full_date,
    EXTRACT(DOW FROM s.sales_timestamp) + 1 AS day_of_week,
    EXTRACT(WEEK FROM s.sales_timestamp) AS week_num,
    EXTRACT(MONTH FROM s.sales_timestamp) AS month_num,
    TO_CHAR(s.sales_timestamp, 'Month') AS month_name,
    EXTRACT(QUARTER FROM s.sales_timestamp) AS quarter_num,
    EXTRACT(YEAR FROM s.sales_timestamp) AS year_num,
    CASE WHEN EXTRACT(DOW FROM s.sales_timestamp) IN (6, 0) THEN TRUE ELSE FALSE END AS is_weekend
FROM silver.silver_sales s
WHERE s.sales_timestamp IS NOT NULL;

-- ============================================
-- 2. ЗАГРУЗКА dim_location
-- ============================================

INSERT INTO gold.dim_location (city_id, city_name, country_id, country_name)
SELECT
    c.city_id,
    c.city_name,
    cnt.country_id,
    cnt.country_name
FROM silver.silver_cities c
JOIN silver.silver_countries cnt ON c.country_id = cnt.country_id
GROUP BY c.city_id, c.city_name, cnt.country_id, cnt.country_name;

-- ============================================
-- 3. ЗАГРУЗКА dim_customer
-- ============================================

INSERT INTO gold.dim_customer (customer_id, first_name, middle_initial, last_name, full_name, city_id, address)
SELECT
    customer_id,
    first_name,
    middle_initial,
    last_name,
    COALESCE(first_name || ' ', '') || COALESCE(middle_initial || ' ', '') || COALESCE(last_name, '') AS full_name,
    city_id,
    address
FROM silver.silver_customers
GROUP BY customer_id, first_name, middle_initial, last_name, city_id, address;

-- ============================================
-- 4. ЗАГРУЗКА dim_product
-- ============================================

INSERT INTO gold.dim_product (product_id, product_name, category_id, category_name, price, class, resistant, is_allergic, vitality_days)
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    cat.category_name,
    p.price,
    p.class,
    p.resistant,
    p.is_allergic,
    p.vitality_days
FROM silver.silver_products p
LEFT JOIN silver.silver_categories cat ON p.category_id = cat.category_id
GROUP BY p.product_id, p.product_name, p.category_id, cat.category_name, p.price, p.class, p.resistant, p.is_allergic, p.vitality_days;

-- ============================================
-- 5. ЗАГРУЗКА dim_shop
-- ============================================

INSERT INTO gold.dim_shop (shop_id, shop_address, city_id, city_name, country_id, country_name)
SELECT
    s.shop_id,
    s.shop_address,
    c.city_id,
    c.city_name,
    cnt.country_id,
    cnt.country_name
FROM silver.silver_shops s
JOIN silver.silver_cities c ON s.city_id = c.city_id
JOIN silver.silver_countries cnt ON c.country_id = cnt.country_id
GROUP BY s.shop_id, s.shop_address, c.city_id, c.city_name, cnt.country_id, cnt.country_name;

-- ============================================
-- 6. ЗАГРУЗКА dim_employee (SCD Type 2)
-- ============================================

INSERT INTO gold.dim_employee (employee_id, first_name, middle_initial, last_name, full_name, gender, birth_date, hire_date, valid_from_dt, valid_to_dt, is_current)
SELECT
    employee_id,
    first_name,
    middle_initial,
    last_name,
    COALESCE(first_name || ' ', '') || COALESCE(middle_initial || ' ', '') || COALESCE(last_name, '') AS full_name,
    gender,
    birth_date,
    hire_date,
    '1900-01-01' AS valid_from_dt,
    '9999-12-31' AS valid_to_dt,
    TRUE AS is_current
FROM silver.silver_employees
GROUP BY employee_id, first_name, middle_initial, last_name, gender, birth_date, hire_date;

-- ============================================
-- 7. ЗАГРУЗКА fact_sales
-- ============================================

INSERT INTO gold.fact_sales (
    sales_id,
    product_key,
    customer_key,
    shop_key,
    employee_key,
    date_key,
    quantity,
    discount_amount,
    total_price,
    net_revenue
)
SELECT
    s.sales_id,
    p.product_key,
    c.customer_key,
    sh.shop_key,
    e.employee_key,
    EXTRACT(YEAR FROM s.sales_timestamp) * 10000 + EXTRACT(MONTH FROM s.sales_timestamp) * 100 + EXTRACT(DAY FROM s.sales_timestamp) AS date_key,
    s.quantity,
    ROUND(s.total_price * s.discount, 2) AS discount_amount,
    s.total_price,
    ROUND(s.total_price - (s.total_price * s.discount), 2) AS net_revenue
FROM silver.silver_sales s
JOIN gold.dim_product p ON s.product_id = p.product_id
JOIN gold.dim_customer c ON s.customer_id = c.customer_id
JOIN gold.dim_shop sh ON s.shop_id = sh.shop_id
JOIN gold.dim_employee e ON s.employee_id = e.employee_id AND e.is_current = TRUE
WHERE s.sales_timestamp IS NOT NULL;