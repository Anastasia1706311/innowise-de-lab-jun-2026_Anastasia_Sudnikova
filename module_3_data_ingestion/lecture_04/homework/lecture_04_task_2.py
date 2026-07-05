# Список списков
daily_logs = [
    [500, 0, 1200],       # Касса 1 (Нормальная)
    [300, -999, 800],     # Касса 2 (Сломалась посередине, 800 не должно посчитаться)
    [1500, 200]           # Касса 3 (Нормальная)
]

total_revenue = 0 #общая выручка магазинов

for cash_index, cash_transactions in enumerate(daily_logs, start=1):
    print(f"--- Обработка Кассы №{cash_index} ---")

    for transaction in cash_transactions:
        if transaction == -999:
            print('Аварийная остановка кассы!')
            break
        elif transaction == 0:
            print('Пропуск сбоя')
            continue
        else:
            total_revenue += transaction
            print('Добавлено:', transaction)

print('=== ИТОГ ДНЯ ===')
print(f"Итоговая выручка магазина: {total_revenue} рублей")