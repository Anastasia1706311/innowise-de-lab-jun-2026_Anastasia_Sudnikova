
--Добавили два новых продукта
INSERT INTO products (product_id, product_name, price, category_id, class, modify_timestamp, resistant, is_allergic, vitality_days)
VALUES 
    (1001, 'Organic Apple Juice', 4.99, 7, 'A', NOW(), 'Yes', 'No', 30),
    (1002, 'Whole Grain Bread', 3.49, 3, 'B', NOW(), 'No', 'No', 15);

--Выбрать только Продукты (Products) у которых is_allergic и resistant = 'Yes'.
SELECT *
FROM products
WHERE is_allergic = 'Yes' 
  AND resistant = 'Yes';

--Обновить поле is_allergic у продукта Bananas Family Pack
UPDATE products 
SET is_allergic = 'YES'
WHERE product_name = 'Bananas Family Pack';

--Удалить один из двух добавленных продуктов.
DELETE FROM products 
WHERE product_id = 1002;

--Создать новую таблицу с именем Data_Layers необходимую для описания слоев со столбцами: LayerID (SERIAL, PRIMARY KEY), LayerName (VARCHAR(50), UNIQUE, NOT NULL), Description (TEXT).
CREATE TABLE data_layers (
	layerID SERIAL PRIMARY KEY,
	layerName VARCHAR(50) UNIQUE NOT NULL,
	description TEXT
);

--Заполнить колонку LayerName тремя значениями 'Bronze', 'Silver', 'Gold', которые обозначают слои в медальонной архитектуре.
INSERT INTO data_layers (layername)
VALUES ('Bronze'),
	   ('Silver'),
	   ('Gold');

--Добавить колонку manager_email в таблицу Data_Layers (VARCHAR(100)).
ALTER TABLE data_layers  
ADD COLUMN manager_email VARCHAR(100);

--Добавить ограничение UNIQUE к столбцу manager_email в таблице Data_Layers (предварительно заполнив столбец любыми значениями, чтобы избежать ошибки).
ALTER TABLE data_layers
ADD CONSTRAINT unique_manager_email UNIQUE (manager_email);

--Переименовать столбец address в таблице Shops в shop_address.
ALTER TABLE shops 
RENAME COLUMN address TO shop_address;

--Создать новую роль (пользователя) PostgreSQL с именем data_engineer_trainee (стажер) и простым паролем.
Предоставить data_engineer_trainee право SELECT на таблицу Sales.
CREATE USER data_engineer_trainee WITH PASSWORD 'trainee_password_123';
GRANT SELECT ON sales TO data_engineer_trainee;
GRANT INSERT, UPDATE ON sales TO data_engineer_trainee;

--Практика DML с использованием WHERE, JOIN и транзакций для поддержки Data Platform.
UPDATE products
SET price = price * 1.1
FROM categories
WHERE products.category_id = categories.category_id
  AND categories.category_name = 'Fruits';

DELETE FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
);

BEGIN;

INSERT INTO employees (first_name, last_name, birth_date, gender, city_id, shop_id, hire_date)
VALUES ('Alex', 'Johnson', '1990-05-15', 'M', 1, 1, NOW())
RETURNING employee_id;

INSERT INTO sales (product_id, customer_id, employee_id, quantity, total_price, sales_timestamp)
VALUES (1, 100, (SELECT MAX(employee_id) FROM employees), 2, 49.98, NOW());

COMMIT;

--Функция: Создать функцию AvgSalesPerEmployee (PL/pgSQL), для вычисления средней суммы продаж для сотрудника.
CREATE OR REPLACE FUNCTION AvgSalesPerEmployee(p_employee_id INTEGER)
RETURNS NUMERIC(10,2) AS
$$
DECLARE
    avg_amount NUMERIC(10,2);
BEGIN
    SELECT AVG(total_price)
    INTO avg_amount
    FROM sales
    WHERE employee_id = p_employee_id;

    IF avg_amount IS NULL THEN
        RETURN 0;
    ELSE
        RETURN avg_amount;
    END IF;
END;
$$
LANGUAGE plpgsql;

--Представление (View): Создать представление FullStatShops для суммарной статистики по магазинам с колонками (shop_id, shop_address, country, total_sales_count, total_sales_amount).
CREATE OR REPLACE VIEW fullstatsshops AS
SELECT 
    sh.shop_id,
    sh.shop_address AS shop_address,   -- теперь правильно!
    co.country_name AS country,
    COUNT(s.sales_id) AS total_sales_count,
    SUM(s.total_price) AS total_sales_amount
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN shops sh ON e.shop_id = sh.shop_id
JOIN cities c ON sh.city_id = c.city_id
JOIN countries co ON c.country_id = co.country_id
GROUP BY sh.shop_id, sh.shop_address, co.country_name;

--Найти сотрудников с продажами > 1000.
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(s.total_price) AS total_sales
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING SUM(s.total_price) > 1000
ORDER BY total_sales DESC;

--Обновить класс продуктов на 'A' для категорий с общей выручкой > 5000.
UPDATE products
SET class = 'A'
WHERE category_id IN (
    SELECT p.category_id
    FROM products p
    JOIN sales s ON p.product_id = s.product_id
    GROUP BY p.category_id
    HAVING SUM(s.total_price) > 5000
);

--Установить modify_timestamp (функция NOW()) для продуктов без даты.
UPDATE products
SET modify_timestamp = NOW()
WHERE modify_timestamp IS NULL;