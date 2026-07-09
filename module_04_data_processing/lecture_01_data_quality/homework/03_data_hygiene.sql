-- ============================================
-- 1. УДАЛЕНИЕ ДУБЛИКАТОВ В EMPLOYEES
-- ============================================

-- Удаляем дубликаты, оставляя одну запись для каждого employee_id
WITH duplicates AS (
    SELECT
        employee_id,
        MIN(ctid) AS keep_id  -- ctid - физический адрес строки
    FROM silver.silver_employees
    GROUP BY employee_id
    HAVING COUNT(*) > 1
)
DELETE FROM silver.silver_employees
WHERE ctid NOT IN (
    SELECT keep_id FROM duplicates
);

-- Проверка: сколько уникальных сотрудников осталось
SELECT COUNT(DISTINCT employee_id) AS unique_employees
FROM silver.silver_employees;

-- ============================================
-- 2. УДАЛЕНИЕ СТРОК С NULL В КЛЮЧЕВЫХ ПОЛЯХ
-- ============================================

-- Удаляем сотрудников без employee_id
DELETE FROM silver.silver_employees
WHERE employee_id IS NULL;

-- Удаляем продажи без sales_id
DELETE FROM silver.silver_sales
WHERE sales_id IS NULL;

-- ============================================
-- 3. ЧИСТКА "СИРОТ" (СОТРУДНИКИ БЕЗ ПРОДАЖ)
-- ============================================

-- Удаляем сотрудников, которые не совершали продаж
DELETE FROM silver.silver_employees
WHERE employee_id NOT IN (
    SELECT DISTINCT employee_id
    FROM silver.silver_sales
    WHERE employee_id IS NOT NULL
);

-- Проверка: сколько сотрудников осталось с продажами
SELECT COUNT(DISTINCT employee_id) AS employees_with_sales
FROM silver.silver_sales
WHERE employee_id IS NOT NULL;

-- ============================================
-- 4. ОБОГАЩЕНИЕ SALES (ДОБАВЛЯЕМ shop_id И city_id)
-- ============================================

-- Обновляем shop_id в sales из данных сотрудников
UPDATE silver.silver_sales
SET shop_id = e.shop_id
FROM silver.silver_employees e
WHERE silver.silver_sales.employee_id = e.employee_id;

-- Обновляем city_id в sales из данных сотрудников
UPDATE silver.silver_sales
SET city_id = e.city_id
FROM silver.silver_employees e
WHERE silver.silver_sales.employee_id = e.employee_id;

-- Проверка: сколько записей обогащено
SELECT
    COUNT(*) AS total_sales,
    COUNT(shop_id) AS sales_with_shop,
    COUNT(city_id) AS sales_with_city
FROM silver.silver_sales;

-- ============================================
-- 5. ДОПОЛНИТЕЛЬНАЯ ОЧИСТКА (ОПЦИОНАЛЬНО)
-- ============================================

-- Удаляем продажи с отрицательными ценами или количеством
DELETE FROM silver.silver_sales
WHERE total_price < 0 OR quantity < 0;

-- Удаляем продукты с отрицательной ценой
DELETE FROM silver.silver_products
WHERE price < 0;

-- Удаляем сотрудников, где hire_date < birth_date (потом добавим CHECK)
UPDATE silver.silver_employees
SET hire_date = '1900-01-01'
WHERE hire_date < birth_date;