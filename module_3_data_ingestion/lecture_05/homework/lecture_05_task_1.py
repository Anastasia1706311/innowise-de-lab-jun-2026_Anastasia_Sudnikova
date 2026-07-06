raw_log = "ORDER-2025-01-15|FRT-APPLE-PL|+111 (23) 456-78-90| мИНсК "

#разделение строки
new_raw_log = raw_log.split(sep = '|')
order_id = new_raw_log[0]
product_code = new_raw_log[1]
raw_phone = new_raw_log[2]
raw_city = new_raw_log[3]

#разбираем код товара
category = product_code[:3]
region = product_code[-2:]
position = product_code.find('-')
print(f'Позиция первого дефиса в коде товара: {position}')

if product_code.startswith('FRT'):
    print("Код товара начинается с 'FRT'")
else:
    print("Код товара не начинается с 'FRT'")

#приводим телефон к нормальному формату
clean_phone = ""
for i in raw_phone:
    if i.isdigit():
        clean_phone += i

print(f'Длина номера телефона: {len(clean_phone)}')

#приводим название города к нормальному виду:
clean_city = raw_city.strip().lower().title()

#формируем отчет
print(f'Заказ: {order_id}\nКатегория: {category} | Регион: {region}\nТелефон: {clean_phone}\nГород: {clean_city}')