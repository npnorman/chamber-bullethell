extends Node2D

var bullet_ids: Array[int] = [0, 0, 0]
var bullet_prices: Array[int] = [0, 0, 0]
var health_count: int = 2
var has_bullet: Array[bool] = [true, true, true]
@export var bullet_textures: Array[Resource]

@onready var bullet_areas: Array[Area2D] = [$BuyArea1, $BuyArea2, $BuyArea3]

signal bullet_purchased(bullet_id: int, price: int)

# Always sets the first item to health, then randomly generated numbers decide the other 2 items to add
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var i: int = 1
	bullet_ids[0] = Globals.Bullets.Health
	bullet_prices[0] = Globals.ammo_prices[4]
	bullet_areas[0].get_child(0).texture = bullet_textures[4]
	bullet_areas[0].get_child(2).text = Texts.bullet_names[4]
	bullet_areas[0].get_child(3).text = Texts.bullet_prices[4]
	var duplicate: int
	while i < 3:
		var rand_int = rng.randi_range(1, 6)
		while rand_int == duplicate or rand_int == 4:
			rand_int = rng.randi_range(1, 6)
		duplicate = rand_int
		bullet_ids[i] = rand_int
		bullet_prices[i] = Globals.ammo_prices[rand_int]
		bullet_areas[i].get_child(0).texture = bullet_textures[rand_int]
		bullet_areas[i].get_child(2).text = Texts.bullet_names[rand_int]
		bullet_areas[i].get_child(3).text = Texts.bullet_prices[rand_int]
		i += 1
	has_bullet = [true, true, true]
	for area in bullet_areas:
		area.visible = true

func clear_shop(index: int):
	bullet_areas[index].visible = false
	has_bullet[index] = false
	if has_bullet[1] == false and has_bullet[2] == false:
		_ready()
	
func update_hud():
	get_tree().current_scene.update_hud()

func update_bartender():
	var children = get_parent().get_children()
	for child in children:
		if child.has_method("play_saying"):
			child.play_saying()

# Below are 3 similar functions that are called depending on which item's area was entered to purchase that item (if possible)
func _on_buy_area_1_body_entered(body: Node2D) -> void:
	var filled_slots: int = Globals.ammo_types.count(-1)
	var empty_slot: int = Globals.ammo_types.find(-1)
	if Globals.ammo[0] >= Globals.ammo_prices[bullet_ids[0]]:
		if not Globals.ammo_types.has(bullet_ids[0]) and filled_slots > 0 and has_bullet[0]:
			Globals.ammo[0] -= bullet_prices[0]
			Globals.ammo[bullet_ids[0]] += 1
			Globals.ammo_types[empty_slot] = bullet_ids[0]
			update_hud()
			update_bartender()
		elif Globals.ammo_types.has(bullet_ids[0]) and health_count > 0 and has_bullet[0] and Globals.ammo[bullet_ids[0]] < Globals.ammo_max[bullet_ids[0]]:
			Globals.ammo[0] -= bullet_prices[0]
			Globals.ammo[bullet_ids[0]] += 1
			update_hud()
			update_bartender()

func _on_buy_area_2_body_entered(body: Node2D) -> void:
	var filled_slots: int = Globals.ammo_types.count(-1)
	var empty_slot: int = Globals.ammo_types.find(-1)
	if Globals.ammo[0] >= Globals.ammo_prices[bullet_ids[1]]:
		if not Globals.ammo_types.has(bullet_ids[1]) and filled_slots > 0 and has_bullet[1]:
			Globals.ammo[0] -= bullet_prices[1]
			Globals.ammo_types[empty_slot] = bullet_ids[1]
			Globals.ammo[bullet_ids[1]] = Globals.ammo_shop_amount[bullet_ids[1]]
			update_hud()
			clear_shop(1)
			update_bartender()
		elif Globals.ammo_types.has(bullet_ids[1]) and has_bullet[1] and Globals.ammo[bullet_ids[1]] < Globals.ammo_max[bullet_ids[1]]:
			Globals.ammo[0] -= bullet_prices[1]
			Globals.ammo[bullet_ids[1]] += bullet_prices[1]
			Globals.ammo[bullet_ids[1]] = Globals.ammo_shop_amount[bullet_ids[1]]
			update_hud()
			clear_shop(1)
			update_bartender()

func _on_buy_area_3_body_entered(body: Node2D) -> void:
	var filled_slots: int = Globals.ammo_types.count(-1)
	var empty_slot: int = Globals.ammo_types.find(-1)
	if Globals.ammo[0] >= Globals.ammo_prices[bullet_ids[2]]:
		if not Globals.ammo_types.has(bullet_ids[2]) and filled_slots > 0 and has_bullet[2]:
			Globals.ammo[0] -= bullet_prices[2]
			Globals.ammo_types[empty_slot] = bullet_ids[2]
			Globals.ammo[bullet_ids[2]] = Globals.ammo_shop_amount[bullet_ids[2]]
			update_hud()
			clear_shop(2)
			update_bartender()
		elif Globals.ammo_types.has(bullet_ids[2]) and has_bullet[2] and Globals.ammo[bullet_ids[2]] < Globals.ammo_max[bullet_ids[2]]:
			Globals.ammo[0] -= bullet_prices[2]
			Globals.ammo[bullet_ids[2]] += bullet_prices[2]
			Globals.ammo[bullet_ids[2]] = Globals.ammo_shop_amount[bullet_ids[2]]
			update_hud()
			clear_shop(2)
			update_bartender()
