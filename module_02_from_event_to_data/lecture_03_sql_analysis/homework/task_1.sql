SELECT 
    s.sales_id,
    p.product_name,
    sh.address AS shop_address
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN shops sh ON e.shop_id = sh.shop_id
JOIN products p ON s.product_id = p.product_id
ORDER BY s.sales_id;