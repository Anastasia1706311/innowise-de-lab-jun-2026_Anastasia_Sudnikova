SELECT 
    p.product_name,
    SUM(s.total_price) AS total_sales,
    AVG(s.total_price) AS avg_check
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(s.total_price) > 400000.00
ORDER BY total_sales DESC;