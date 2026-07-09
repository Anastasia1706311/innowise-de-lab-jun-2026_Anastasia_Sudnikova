-- ============================================
-- СОЗДАНИЕ СХЕМЫ SILVER
-- ============================================

CREATE SCHEMA IF NOT EXISTS silver;

-- ============================================
-- ТАБЛИЦА: silver.silver_countries
-- ============================================

CREATE TABLE IF NOT EXISTS silver.silver_countries (
    country_id INTEGER,
    country_name VARCHAR(100),
    country_code VARCHAR(3)
);

-- ============================================
-- ТАБЛИЦА: silver.silver_cities
-- ============================================

CREATE TABLE IF NOT EXISTS silver.silver_cities (
    city_id INTEGER,
    city_name VARCHAR(100),
    zipcode INTEGER,
    country_id INTEGER
);

-- ============================================
-- ТАБЛИЦА: silver.silver_categories
-- ============================================

CREATE TABLE IF NOT EXISTS silver.silver_categories (
    category_id INTEGER,
    category_name VARCHAR(100)
);

-- ============================================
-- ТАБЛИЦА: silver.silver_products
-- ============================================

CREATE TABLE IF NOT EXISTS silver.silver_products (
    product_id INTEGER,
    product_name VARCHAR(200),
    price NUMERIC(10, 2),           -- вместо float
    category_id INTEGER,
    class VARCHAR(50),
    modify_timestamp VARCHAR(50),   -- пока строка, обработаем в Python
    resistant BOOLEAN,              -- вместо varchar
    is_allergic BOOLEAN,            -- вместо varchar
    vitality_days INTEGER
);

-- ============================================
-- ТАБЛИЦА: silver.silver_shops
-- ============================================

CREATE TABLE IF NOT EXISTS silver.silver_shops (
    shop_id INTEGER,
    city_id INTEGER,
    shop_address VARCHAR(200)
);

-- ============================================
-- ТАБЛИЦА: silver.silver_employees
-- ============================================

CREATE TABLE IF NOT EXISTS silver.silver_employees (
    employee_id INTEGER,
    first_name VARCHAR(50),
    middle_initial VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE,                -- вместо varchar
    gender VARCHAR(10),
    city_id INTEGER,
    shop_id INTEGER,
    hire_date DATE                  -- вместо varchar
);

-- ============================================
-- ТАБЛИЦА: silver.silver_customers
-- ============================================

CREATE TABLE IF NOT EXISTS silver.silver_customers (
    customer_id INTEGER,
    first_name VARCHAR(50),
    middle_initial VARCHAR(50),
    last_name VARCHAR(50),
    city_id INTEGER,
    address VARCHAR(200)
);

-- ============================================
-- ТАБЛИЦА: silver.silver_sales (ОБОГАЩЕННАЯ)
-- ============================================

CREATE TABLE IF NOT EXISTS silver.silver_sales (
    sales_id INTEGER,
    employee_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    discount NUMERIC(10, 2),        -- вместо float
    total_price NUMERIC(10, 2),     -- вместо float
    sales_timestamp TIMESTAMP,      -- вместо varchar
    transaction_number VARCHAR(50),
    -- ОБОГАЩЕНИЕ: добавляем поля для упрощения аналитики
    shop_id INTEGER,
    city_id INTEGER
);