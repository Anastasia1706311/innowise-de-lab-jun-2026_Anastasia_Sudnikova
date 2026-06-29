
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', TO_TIMESTAMP(s.sales_timestamp, 'YYYY-MM-DD HH24:MI:SS')) AS month,
        SUM(s.total_price) AS revenue
    FROM sales s
    JOIN employees e ON s.employee_id = e.employee_id
    JOIN shops sh ON e.shop_id = sh.shop_id
    JOIN cities c ON sh.city_id = c.city_id
    JOIN countries co ON c.country_id = co.country_id
    WHERE co.country_name = 'Germany'
    GROUP BY DATE_TRUNC('month', TO_TIMESTAMP(s.sales_timestamp, 'YYYY-MM-DD HH24:MI:SS'))
)
SELECT 
    month AS sale_month,
    revenue AS monthly_revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_diff_vs_previous
FROM monthly_revenue
ORDER BY month;