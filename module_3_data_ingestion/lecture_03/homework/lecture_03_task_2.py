product_name = "Морковь мытая"
price = 2.5
stock_quantity = 150
is_local_farm = True
supplier = None

has_coupon = True
has_card = False
total = 10

#рассчитываем is_hit
is_hit = (price < 3) and (is_local_farm == True)

#выводим на экран
print('Является ли товар хитом?', is_hit)

#добавляем другие проверки
has_supplier = supplier is not None
print('Поставщик указан?', has_supplier)

can_show_in_app = (has_supplier == True) and (stock_quantity > 0)
print('Показывать в приложении?', can_show_in_app)

needs_restock = (stock_quantity <= 20) or (is_hit == True)
print('Нужно пополнение?', needs_restock)

is_blocked = not(is_local_farm == True)
print('Товар заблокирован для акции?', is_blocked)

#проверка приоритетов
discount_without_brackets = has_coupon == True or has_card == True and total > 50
discount_with_brackets = (has_coupon == True or has_card == True) and total > 50

print('Скидка без скобок:', discount_without_brackets)
print('Скидка cо скобками:', discount_with_brackets)

#изменяем значения
price += 1.0
stock_quantity *= 2
boxes = stock_quantity
boxes //= 10
is_hit = (price < 3) and (is_local_farm == True)
needs_restock = (stock_quantity <= 20) or (is_hit == True)

print('Цена после изменения:', price)
print('Остаток после изменения:', stock_quantity)
print('Полных коробок по 10 кг:', boxes)

print('Является ли товар хитом (после изменений)?', is_hit)
print('Нужно пополнение (после изменений)?', needs_restock)
