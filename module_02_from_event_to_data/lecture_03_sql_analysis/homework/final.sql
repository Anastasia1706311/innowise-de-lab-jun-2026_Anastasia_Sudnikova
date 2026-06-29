WITH shop_stats AS (
    
    SELECT 
        co.country_name,
        sh.shop_id,
        sh.address,
        COUNT(s.sales_id) AS total_sales_count,
        SUM(s.total_price) AS total_sales_amount
    FROM sales s
    JOIN employees e ON s.employee_id = e.employee_id
    JOIN shops sh ON e.shop_id = sh.shop_id
    JOIN cities c ON sh.city_id = c.city_id
    JOIN countries co ON c.country_id = co.country_id
    GROUP BY co.country_name, sh.shop_id, sh.address
    HAVING COUNT(s.sales_id) >= 2  -- оставляем только магазины с >= 2 продажами
),
country_stats AS (
    
    SELECT 
        country_name,
        SUM(total_sales_amount) AS country_total
    FROM shop_stats
    GROUP BY country_name
)
SELECT 
    ss.country_name,
    ss.shop_id,
    ss.address,
    ss.total_sales_count,
    ss.total_sales_amount,
    cs.country_total AS country_tx,
    
    ss.total_sales_amount / cs.country_total AS country_sales_share,
    
    RANK() OVER (
        PARTITION BY ss.country_name 
        ORDER BY ss.total_sales_amount DESC
    ) AS country_rank,
    -- 5. Накопительный оборот по стране (кумулятивная сумма)
    SUM(ss.total_sales_amount) OVER (
        PARTITION BY ss.country_name 
        ORDER BY ss.total_sales_amount DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS country_running_total
FROM shop_stats ss
JOIN country_stats cs ON ss.country_name = cs.country_name
ORDER BY 
    ss.country_name,
    country_rank;