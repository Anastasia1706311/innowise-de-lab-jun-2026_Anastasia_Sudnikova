def audit_logger(func):
    def wrapper(*args, **kwargs):
        print('[AUDIT] Запуск анализа...')
        result = func(*args, **kwargs)
        print('[AUDIT] Анализ завершен.')
        return result
    return wrapper

@audit_logger
def get_sorted_report(branches):
    '''
    Сортирует список филиалов по выручке по убыванию.
    :param branches: Список словарей с ключами "city" и "revenue"
    :return:Отсортированный список филиалов
    '''

    return sorted(branches, key=lambda x: x["revenue"], reverse=True)

branches = [
    {"city": "Minsk", "revenue": 15000},
    {"city": "Warsaw", "revenue": 32000},
    {"city": "London", "revenue": 12000}
]

# Вызов функции и сохранение результата
sorted_report = get_sorted_report(branches)

# Вывод результата построчно
print("\nТоп филиалов:")
for i, branch in enumerate(sorted_report, 1):
    print(f"{i}. {branch['city']}: {branch['revenue']}")