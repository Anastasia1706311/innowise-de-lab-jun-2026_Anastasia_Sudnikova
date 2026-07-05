raw_sku = "CARROT-001"
raw_regions = ("Minsk", "Warsaw", "Berlin", "Warsaw")
raw_weight_str = "2.5"
raw_stock_str = "150"

#преобразование типов
weight_kg = float(raw_weight_str)
stock_quantity = int(raw_stock_str)

#преобразование коллекций
sku_as_list = list(raw_sku)
regions_list = list(raw_regions)
unique_regions = set(raw_regions)
regions_tuple = tuple(unique_regions)

#выводим значения и их типы
print(weight_kg, type(weight_kg))
print(stock_quantity, type(stock_quantity))
print(sku_as_list, type(sku_as_list))
print(regions_list, type(regions_list))
print(unique_regions, type(unique_regions))
print(regions_tuple, type(regions_tuple))

#создаем пустые коллекции двумя способами
empty_list_1 = []
empty_list_2 = list()

empty_dict_1 = {}
empty_dict_2 = dict()

empty_tuple_1 = ()
empty_tuple_2 = tuple()

empty_set = set()

#вывод bool пустых коллекций
print(bool(empty_list_1))
print(bool(empty_dict_1))
print(bool(empty_tuple_1))
print(bool(empty_set))

# Непустые коллекции (создаём сразу с элементами)
nonempty_list_1 = [1, 2, 3]
nonempty_list_2 = list([4, 5, 6])

nonempty_dict_1 = {"a": 1, "b": 2}
nonempty_dict_2 = dict(c=3, d=4)

nonempty_tuple_1 = (5, 6, 7)
nonempty_tuple_2 = tuple([8, 9, 10])

nonempty_set = {1, 2, 3}

#вывод непустых коллекций
print(bool(nonempty_list_1))
print(bool(nonempty_dict_1))
print(bool(nonempty_tuple_2))
print(bool(nonempty_set))
