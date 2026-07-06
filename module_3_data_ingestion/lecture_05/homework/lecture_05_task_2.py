product = " фермерский ТВОРОГ "
price = 4.567
qty = 3
csv_row = "milk,bread,cheese"
review = "Это лучший ТВОРОГ в городе!"
file_path = r"C:\EcoMarket\data\2025\january\sales.csv"

#нормализуем название товара
clean_product = product.strip().lower().title()

#рассчитываем итоговую сумму
total = price * qty
receipt = f'Чек "EcoMarket"\nТовар:\t{clean_product}\nКол-во:\t{qty}\nИтого:\t{total:.2f}'
print(receipt)

#Подготовка строки из CSV
new_csv_row = csv_row.split(',')
result_row = ' | '.join(new_csv_row)
print(result_row)

#проверка отзыва клиента
if "творог" in review.lower():
    print(f"Отзыв относится к категории: Dairy\t{file_path}")

#r"" используется перед строкой, чтобы путь к файлу выводился без искажений 