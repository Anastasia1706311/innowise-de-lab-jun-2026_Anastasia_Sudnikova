#создаем родительский класс Продукт
class Product:
    #пишем конструктор
    def __init__(self, name, price):
        self.name = name
        self.__price = price

    #создаем сеттер для изменения цены
    def set_price(self, new_price):
        if new_price > 0:
            self.__price = new_price
            print(f'Цена изменена на: {self.__price}')
        else:
            print('Ошибка безопасности: Цена должна быть положительной!')

    #создаем геттер для получения цены
    def get_price(self):
        return self.__price

    #создаем метод для подсчета цены
    def calculate_cost(self):
        return self.get_price()

    #создаем метод для вывода информации
    def get_display_info(self):
        return f'Товар: {self.name} | Цена: {self.get_price()} руб.'

#создаем дочерний класс Взвешенная продукция
class WeighableProduct(Product):
    #пишем конструктор через super()
    def __init__(self, name, price, weight):
        super().__init__(name, price)
        self.weight = weight

    #переопределяем метод для подсчета цены
    def calculate_cost(self):
        return self.get_price() * self.weight

    #переопределяем метод для вывода информации
    def get_display_info(self):
        return f'Весовой товар: {self.name} | Вес: {self.weight} кг | Итого: {self.calculate_cost()} руб.'

#создаем дочерний класс Упакованная продукция
class PackagedProduct(Product):
    #пишем конструктор
    def __init__(self, name, price, quantity):
        super().__init__(name, price)
        self.quantity = quantity

    #переопределяем метод подсчета цены
    def calculate_cost(self):
        return self.get_price() * self.quantity

    #переопределяем метод вывода информации
    def get_display_info(self):
        return f'Упаковка: {self.name} | Количество: {self.quantity} шт. | Итого: {self.calculate_cost()} руб.'


# Создаем корзину
cart = []

# Добавляем товары
cart.append(Product("Молоко", 100))
cart.append(WeighableProduct("Яблоки", 50, 2.5))
cart.append(PackagedProduct("Яйца", 12, 10))

# Попытка "взлома" - установка отрицательной цены
cart[0].set_price(-200)

# Печатаем чек
print("\n--- Чек EcoMarket ---")

total_sum = 0.0

for item in cart:
    # Полиморфизм: Python сам определит, какой метод вызывать
    print(item.get_display_info())
    total_sum += item.calculate_cost()

print("---------------------")
print(f"ИТОГО К ОПЛАТЕ: {total_sum} руб.")