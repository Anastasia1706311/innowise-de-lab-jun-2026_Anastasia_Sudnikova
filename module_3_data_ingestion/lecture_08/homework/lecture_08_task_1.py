#создаем функцию для подсчета стоимости партии товара
SMALL_BATCH_LIMIT = 500
def calculate_batch (weight, price, discount = 0.0):
    '''
    :param weight: обязательный параметр, который принимает вес,
    :param price: обязательный параметр, который принимает цену
    :param discount: необязательный параметр, который принимает скидку или по умолчанию равен 0.0
    :return: кортеж из двух значений: (final_sum, is_limit_exceeded), где второе значение — булево (True/False).
    '''

    final_sum = weight * price * (1 - discount)
    is_limit_exceeded = final_sum > SMALL_BATCH_LIMIT
    return (final_sum, is_limit_exceeded)

# Вызов функции для моркови (100 кг по 4$, без скидки)
sum1, exceeded1 = calculate_batch(100, 4)

# Вызов функции для яблок (50 кг по 20$, скидка 10%)
sum2, exceeded2 = calculate_batch(50, 20, 0.1)

# Вывод читаемого отчёта
print(f"Партия 1 (Морковь): Сумма {sum1}. Превышение лимита: {exceeded1}")
print(f"Партия 2 (Яблоки): Сумма {sum2}. Превышение лимита: {exceeded2}")


