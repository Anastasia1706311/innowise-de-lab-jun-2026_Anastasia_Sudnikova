prices = [100, -50, 300, 40, 800]

prices.remove(-50)
prices.append(150)
prices.sort()

tax_prices = [price * 1.2 for price in prices if price * 1.2 > 100.0]

print(f'Базовый прайс (очищенный): {prices}')
print(f'Цены с НДС (>100): {tax_prices}')
print(f'Общая выручка: {sum(tax_prices)}')
print(f'Минимум: {min(tax_prices)}')
print(f'Максимум: {max(tax_prices)}')