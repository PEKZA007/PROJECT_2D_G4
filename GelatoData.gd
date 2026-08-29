extends RefCounted
class_name GelatoData

# ------------------------------------------------------------
#  ข้อมูลรสเจลาโต้ / ท็อปปิ้ง / ภาชนะ ของ Good Goods Gelato House
#  ใช้ร่วมกันระหว่าง Game.gd (เล่นเกม) และ Shop.gd (ร้านค้า)
# ------------------------------------------------------------

const FLAVOR_ORDER := ["choc_mint", "cookies_cream", "dark_chocolate", "lemon", "pistachio", "strawberry_cheesecake"]

const FLAVORS := {
	"choc_mint": {
		"name": "ช็อกโกแลตมินต์", "value": 10,
		"cone": "res://assets/gelato/cone/scoop_ChocMint.png",
		"small": "res://assets/gelato/small/scoop_ChocMint.png",
		"large1": "res://assets/gelato/large/scoop1_ChocMint.png",
		"large2": "res://assets/gelato/large/scoop2_ChocMint.png",
		"thumb": "res://assets/gelato/thumbs/flavor_ChocMint.png",
	},
	"cookies_cream": {
		"name": "คุกกี้แอนด์ครีม", "value": 10,
		"cone": "res://assets/gelato/cone/scoop_CookiesCream.png",
		"small": "res://assets/gelato/small/scoop_CookiesCream.png",
		"large1": "res://assets/gelato/large/scoop1_Cookiesandcream.png",
		"large2": "res://assets/gelato/large/scoop2_Cookiesandcream.png",
		"thumb": "res://assets/gelato/thumbs/flavor_CookiesCream.png",
	},
	"dark_chocolate": {
		"name": "ดาร์กช็อกโกแลต", "value": 12,
		"cone": "res://assets/gelato/cone/scoop_DarkChocolate.png",
		"small": "res://assets/gelato/small/scoop_DarkChocolate.png",
		"large1": "res://assets/gelato/large/scoop1_DarkChocolate.png",
		"large2": "res://assets/gelato/large/scoop2_DarkChocolate.png",
		"thumb": "res://assets/gelato/thumbs/flavor_DarkChocolate.png",
	},
	"lemon": {
		"name": "เลมอน", "value": 8,
		"cone": "res://assets/gelato/cone/scoop_Lemon.png",
		"small": "res://assets/gelato/small/scoop_Lemon.png",
		"large1": "res://assets/gelato/large/scoop1_Lemon.png",
		"large2": "res://assets/gelato/large/scoop2_Lemon.png",
		"thumb": "res://assets/gelato/thumbs/flavor_Lemon.png",
	},
	"pistachio": {
		"name": "พิสตาชิโอ", "value": 14,
		"cone": "res://assets/gelato/cone/scoop_Pistachio.png",
		"small": "res://assets/gelato/small/scoop_Pistachio.png",
		"large1": "res://assets/gelato/large/scoop1_Pistachio.png",
		"large2": "res://assets/gelato/large/scoop2_Pistachio.png",
		"thumb": "res://assets/gelato/thumbs/flavor_Pistachio.png",
	},
	"strawberry_cheesecake": {
		"name": "สตรอเบอร์รี่ชีสเค้ก", "value": 16,
		"cone": "res://assets/gelato/cone/scoop_StrawberryCheesePie.png",
		"small": "res://assets/gelato/small/scoop_StrawberryCheesePie.png",
		"large1": "res://assets/gelato/large/scoop1_Strawberrycheesepie.png",
		"large2": "res://assets/gelato/large/scoop2_Strawberrycheesepie.png",
		"thumb": "res://assets/gelato/thumbs/flavor_StrawberryCheesePie.png",
	},
}

const TOPPING_ORDER := ["cookie", "peanuts", "strawberry"]

const TOPPINGS := {
	"cookie": {
		"name": "คุกกี้", "value": 5,
		"cone": "res://assets/gelato/cone/topping_Cookie.png",
		"small": "res://assets/gelato/small/topping_Cookie.png",
		"large": "res://assets/gelato/large/topping_Cookie.png",
		"thumb": "res://assets/gelato/thumbs/topping_Cookie.png",
	},
	"peanuts": {
		"name": "ถั่ว", "value": 5,
		"cone": "res://assets/gelato/cone/topping_Peanuts.png",
		"small": "res://assets/gelato/small/topping_Peanuts.png",
		"large": "res://assets/gelato/large/topping_Peanuts.png",
		"thumb": "res://assets/gelato/thumbs/topping_Peanuts.png",
	},
	"strawberry": {
		"name": "สตรอเบอร์รี่", "value": 6,
		"cone": "res://assets/gelato/cone/topping_Strawberry.png",
		"small": "res://assets/gelato/small/topping_Strawberry.png",
		"large": "res://assets/gelato/large/topping_Strawberry.png",
		"thumb": "res://assets/gelato/thumbs/topping_Strawberry.png",
	},
}

const CONTAINER_ORDER := ["cone", "small_cup", "large_cup"]

const CONTAINERS := {
	"cone": {
		"name": "โคน", "capacity": 1, "value": 0,
		"thumb": "res://assets/gelato/thumbs/container_cone.png",
	},
	"small_cup": {
		"name": "ถ้วยเล็ก", "capacity": 1, "value": 4,
		"thumb": "res://assets/gelato/thumbs/container_small.png",
	},
	"large_cup": {
		"name": "ถ้วยใหญ่", "capacity": 2, "value": 10,
		"thumb": "res://assets/gelato/thumbs/container_large.png",
	},
}


static func flavor_name(key: String) -> String:
	return FLAVORS.get(key, {}).get("name", key)


static func topping_name(key: String) -> String:
	return TOPPINGS.get(key, {}).get("name", key)


static func container_name(key: String) -> String:
	return CONTAINERS.get(key, {}).get("name", key)


static func container_capacity(key: String) -> int:
	return int(CONTAINERS.get(key, {}).get("capacity", 1))
