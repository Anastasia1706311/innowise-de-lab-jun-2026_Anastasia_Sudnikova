from typing import Optional, Union, List, Tuple, Dict

def calculate_total_delivery_cost(
    product_name: str,
    weights: Union[List[float], Tuple[float, ...]],
    prices: Union[List[float], Tuple[float, ...]],
    discount: Optional[float] = None,
    currency_rate: Union[int, float] = 1,
    *extra_costs: float
) -> Dict[str, float]:
    '''
    Рассчитывает итоговую стоимость партии товара с учетом базовых цен,
    скидки и дополнительных расходов.
    :param product_name: Название товара
    :param weights:коллекция с весами партий
    :param prices:коллекция с ценами за кг.
    :param discount:скидка, которой по умолчанию нет, но может быть передана в функцию.
    :param currency_rate:коэффициент пересчета валюты, который может быть как целым числом,
    так и дробным. По умолчанию всегда равен 1.
    :param extra_costs:дополнительные расходы (например, доставка, упаковка, хранение).
    :return: Dict[str, float]
        Словарь с названием товара в качестве ключа и итоговой стоимостью в качестве значения
    '''

    # Проверяем, что количество элементов в весах и ценах совпадает
    if len(weights) != len(prices):
        raise ValueError(f"Количество элементов в weights ({len(weights)}) и prices ({len(prices)}) не совпадает")

    # Типизируем локальные переменные
    total_sum: float = 0.0

    # Рассчитываем стоимость каждой позиции
    for i in range(len(weights)):
        weight: float = float(weights[i])
        price: float = float(prices[i])
        total_sum += weight * price

    # Применяем скидку, если она передана
    if discount is not None:
        discount_sum: float = total_sum * (1 - discount)
        total_sum = discount_sum

    # Суммируем дополнительные расходы
    extra_sum: float = sum(extra_costs)
    total_sum += extra_sum

    # Применяем курс валюты
    final_sum: float = total_sum * float(currency_rate)

    # Возвращаем результат в виде словаря
    return {product_name: final_sum}

# Тестирование функции с входными данными

# 1. Для овощей
result1 = calculate_total_delivery_cost(
    "Овощная партия",
    [100, 50],
    [4, 6],
    0.1,
    1,
    20, 15
)

# 2. Для фруктов
result2 = calculate_total_delivery_cost(
    "Фруктовая партия",
    (30, 20, 10),
    (15, 12, 18),
    None,
    1.2,
    25
)

# Вывод результатов
for product, cost in result1.items():
    print(f"Товар: {product}, итоговая стоимость: {cost}")

for product, cost in result2.items():
    print(f"Товар: {product}, итоговая стоимость: {cost}")