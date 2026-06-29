SELECT 
    sh.shop_id,
    sh.address,
    c.city_name,
    co.country_name
FROM shops sh
JOIN cities c ON sh.city_id = c.city_id
JOIN countries co ON c.country_id = co.country_id
WHERE co.country_name = 'Poland'
ORDER BY sh.shop_id;