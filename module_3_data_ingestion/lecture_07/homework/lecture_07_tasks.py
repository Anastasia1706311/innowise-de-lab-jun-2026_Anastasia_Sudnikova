#Задание 1
center_coords = (40.7128, -74.0060)
#center_coords[0] = 41.000
print(f'Coordinates of the location of the central warehouse: {center_coords[0]} , {center_coords[1]}')
print(type(center_coords))
print(len(center_coords))

#Задание 2
product = {
	"id": 105,
	"name": "Organic Buckwheat",
	"price": 3.50,
	"stock": 100
}

product["price"] = 4.20
product["category"] = "Grains"
discount_rate = product.get("discount", 0)
print(product)
print(discount_rate)

#Задание 3
suppliers_log = [
	"FreshFarm Inc",
	"GreenFields Ltd",
	"AgroWorld Co",
	"FreshFarm Inc",
	"GreenFields Ltd"
]

unique_suppliers = set(suppliers_log)
unique_suppliers.add("GreenFields Ltd")
print("FreshFarm Inc" in unique_suppliers)
print(unique_suppliers)
print(len(unique_suppliers))

#Задание 4
usd_prices = {
"Banana": 1.2,
"Mango": 2.5,
"Avocado": 2.0
}

eur_prices = {fruit: price * 0.9 for fruit, price in usd_prices.items()}

print(eur_prices)

#Задание 5
import json
api_response_json = """ 
{ 
	"store": "StoreHub", 
	"orders": [ 
		{"id": 1, "total": 50}, 
		{"id": 2, "total": 200}, 
		{"id": 3, "total": 150} 
		]
 } 
"""

response_dict = json.loads(api_response_json)
orders = response_dict["orders"]
high_value_orders = [order for order in orders if order["total"] > 100]
response_dict["high_value_orders"] = high_value_orders
updated_json = json.dumps(response_dict, ensure_ascii=False, indent=2)
print(updated_json)