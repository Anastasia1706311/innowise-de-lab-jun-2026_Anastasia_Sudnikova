SELECT 
    e.first_name,
    e.last_name,
    sh.address AS shop_address,
    s.total_price,
    s.transaction_number
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN shops sh ON e.shop_id = sh.shop_id
WHERE s.total_price = (
    SELECT MAX(total_price) FROM sales
);