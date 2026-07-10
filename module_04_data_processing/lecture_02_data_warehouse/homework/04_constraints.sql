-- ============================================
-- ПЕРВИЧНЫЕ КЛЮЧИ (PRIMARY KEYS)
-- ============================================

ALTER TABLE silver.silver_countries ADD PRIMARY KEY (country_id);
ALTER TABLE silver.silver_cities ADD PRIMARY KEY (city_id);
ALTER TABLE silver.silver_categories ADD PRIMARY KEY (category_id);
ALTER TABLE silver.silver_products ADD PRIMARY KEY (product_id);
ALTER TABLE silver.silver_shops ADD PRIMARY KEY (shop_id);
ALTER TABLE silver.silver_employees ADD PRIMARY KEY (employee_id);
ALTER TABLE silver.silver_customers ADD PRIMARY KEY (customer_id);
ALTER TABLE silver.silver_sales ADD PRIMARY KEY (sales_id);

-- ============================================
-- ВНЕШНИЕ КЛЮЧИ (FOREIGN KEYS)
-- ============================================

-- Cities → Countries
ALTER TABLE silver.silver_cities
    ADD CONSTRAINT fk_cities_countries
    FOREIGN KEY (country_id) REFERENCES silver.silver_countries(country_id);

-- Products → Categories
ALTER TABLE silver.silver_products
    ADD CONSTRAINT fk_products_categories
    FOREIGN KEY (category_id) REFERENCES silver.silver_categories(category_id);

-- Shops → Cities
ALTER TABLE silver.silver_shops
    ADD CONSTRAINT fk_shops_cities
    FOREIGN KEY (city_id) REFERENCES silver.silver_cities(city_id);

-- Employees → Cities
ALTER TABLE silver.silver_employees
    ADD CONSTRAINT fk_employees_cities
    FOREIGN KEY (city_id) REFERENCES silver.silver_cities(city_id);

-- Employees → Shops
ALTER TABLE silver.silver_employees
    ADD CONSTRAINT fk_employees_shops
    FOREIGN KEY (shop_id) REFERENCES silver.silver_shops(shop_id);

-- Customers → Cities
ALTER TABLE silver.silver_customers
    ADD CONSTRAINT fk_customers_cities
    FOREIGN KEY (city_id) REFERENCES silver.silver_cities(city_id);

-- Sales → Employees
ALTER TABLE silver.silver_sales
    ADD CONSTRAINT fk_sales_employees
    FOREIGN KEY (employee_id) REFERENCES silver.silver_employees(employee_id);

-- Sales → Customers
ALTER TABLE silver.silver_sales
    ADD CONSTRAINT fk_sales_customers
    FOREIGN KEY (customer_id) REFERENCES silver.silver_customers(customer_id);

-- Sales → Products
ALTER TABLE silver.silver_sales
    ADD CONSTRAINT fk_sales_products
    FOREIGN KEY (product_id) REFERENCES silver.silver_products(product_id);

-- Sales → Shops (обогащение)
ALTER TABLE silver.silver_sales
    ADD CONSTRAINT fk_sales_shops
    FOREIGN KEY (shop_id) REFERENCES silver.silver_shops(shop_id);

-- Sales → Cities (обогащение)
ALTER TABLE silver.silver_sales
    ADD CONSTRAINT fk_sales_cities
    FOREIGN KEY (city_id) REFERENCES silver.silver_cities(city_id);

-- ============================================
-- БИЗНЕС-КОНСТРЕЙНТЫ (CHECK CONSTRAINTS)
-- ============================================

-- Проверка: дата найма должна быть позже даты рождения
ALTER TABLE silver.silver_employees
    ADD CONSTRAINT chk_hire_after_birth
    CHECK (hire_date > birth_date);

-- Проверка: цены и скидки не могут быть отрицательными
ALTER TABLE silver.silver_products
    ADD CONSTRAINT chk_price_positive
    CHECK (price >= 0);

ALTER TABLE silver.silver_sales
    ADD CONSTRAINT chk_total_price_positive
    CHECK (total_price >= 0);

ALTER TABLE silver.silver_sales
    ADD CONSTRAINT chk_discount_range
    CHECK (discount >= 0 AND discount <= 1);

ALTER TABLE silver.silver_sales
    ADD CONSTRAINT chk_quantity_positive
    CHECK (quantity > 0);

-- ============================================
-- ПРОВЕРКА ВСЕХ ОГРАНИЧЕНИЙ
-- ============================================

-- Смотрим список всех ограничений
SELECT
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid IN (
    SELECT oid FROM pg_class
    WHERE relnamespace = (
        SELECT oid FROM pg_namespace WHERE nspname = 'silver'
    )
)
ORDER BY conname;