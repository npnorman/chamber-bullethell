extends Node

var room_size:int = 35
var tile_size:int = 16

#signal stat_changed

#flag for boss TP
var isBossTPUnlocked = false
var is_boss_transition_room_activated = false
var temporary_loadout = []
var temporary_types = []

# seed for regen purposes
var current_seed = -1

# Enums to show what names correspond to what IDs
enum Bullets {Normal, Ricochet, Shotgun, Explosive, Health, Railgun, Gambler, Empty = -1}

enum Level {
	DESERT,
	SALOON,
	HELL
}

var current_level:int = Level.DESERT

#RoomGen enums
enum ExitType {
	FOUR,
	THREE,
	TWO_CLOSE,
	TWO_APART,
	ONE,
	ZERO,
	NONE
}

enum Rotation {
	ZERO,
	NINETY,
	ONEEIGHTY,
	TWOSEVENTY
}

enum Special {
	NONE,
	START,
	SHOP,
	BOSS_TP,
	BOSS,
	BOSS_TRANSITION
}

enum Scenes {
	START,
	SETTINGS,
	CREDITS,
	WIN,
	CUSTOM,
}

func save_current_loadout():
	print("SAVING:",ammo)
	temporary_loadout = ammo.duplicate()
	temporary_types = ammo_types.duplicate()

func load_temp_loadout():
	if !temporary_loadout.is_empty() and len(temporary_loadout) == len(ammo):
		print("LOADING:",temporary_loadout)
		ammo = temporary_loadout.duplicate()
		ammo_types = temporary_types.duplicate()
		
		temporary_loadout.clear()
		temporary_types.clear()

func get_scene_string(scene_enum:int):
	match scene_enum:
		Scenes.START:
			return "res://scenes/menu/start_menu.tscn"
		Scenes.SETTINGS:
			return "res://scenes/menu/settings.tscn"
		Scenes.CREDITS:
			return "res://scenes/menu/credits.tscn"
		Scenes.WIN:
			return "res://scenes/menu/win_room.tscn"
	
	return ""

func get_exits(room:Vector4):
	var exits:Array = [0,0,0,0]
	# offset of (x+1,y+1,x-1,y-1)
		# a 1 if correct, a zero if not
	
	match int(room.z):
		Globals.ExitType.ONE:
			exits = [0,0,1,0]
		Globals.ExitType.TWO_CLOSE:
			exits = [0,1,1,0]
		Globals.ExitType.TWO_APART:
			exits = [1,0,1,0]
		Globals.ExitType.THREE:
			exits = [1,1,0,1]
		Globals.ExitType.FOUR:
			exits = [1,1,1,1]
	
	var amount = 0
	
	match int(room.w):
		Globals.Rotation.NINETY:
			amount = 1
		Globals.Rotation.ONEEIGHTY:
			amount = 2
		Globals.Rotation.TWOSEVENTY:
			amount = 3
	
	exits = rotate_exits(exits,amount)
	return exits

func rotate_exits(exits:Array, amount:int):
	for i in range(0,amount):
		exits = cyclic_shift(exits)
	
	return exits

func cyclic_shift(exits:Array):
	var swap = exits[3]
	exits[3] = exits[0]
	exits[0] = exits[1]
	exits[1] = exits[2]
	exits[2] = swap
	
	return exits

func get_number_of_exits(room:Vector4):
	var number_of_exits = 0
	
	match room.z:
		Globals.ExitType.ZERO:
			number_of_exits = 0
		Globals.ExitType.NONE:
			number_of_exits = 0
		Globals.ExitType.ONE:
			number_of_exits = 1
		Globals.ExitType.TWO_CLOSE:
			number_of_exits = 2
		Globals.ExitType.TWO_APART:
			number_of_exits = 2
		Globals.ExitType.THREE:
			number_of_exits = 3
		Globals.ExitType.FOUR:
			number_of_exits = 4
	
	return number_of_exits

# Ammo array where a given bullet ID's ammo is shown in the index of the ID number
var ammo: Array[int] = [30, 0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0]:
	get:
		return ammo

# Gives the maximum ammo that can be held of a given ammo type
#var ammo_max: Array[int] = [999, 18, 18, 18, 3, 12, 18, 30, 30, 30, 30, 30]
var ammo_max: Array[int] = [999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999]

var ammo_shop_amount = [999, 18, 18, 18, 3, 12, 18, 30, 30, 30, 30, 30]

# Array of the IDs of ammo the player currently has, with -1 meaning nothing is in the slot
var ammo_types: Array[int] = [0, 6, -1, -1]

# Shows the rarity of each bullet to be used to determine pickup texture
var ammo_rarities: Array[int] = [0, 1, 1, 1, 1, 2, 2, 0, 0, 0, 0, 0]

# Array of the shop prices for each bullet (health bullets are bought 1 at a time)
var ammo_prices: Array[int] = [0, 15, 15, 15, 10, 20, 20, 0, 0, 0, 0, 0]

# 6 cylinder magazine represented by a size 6 array that is frequently being changed
var magazine: Array[int] = [-1, -1, -1, -1, -1, -1]:
	get:
		return magazine

# current room
var current_room_center:Vector2 = Vector2.ZERO

func change_level(level_scheme:int = current_level):
	# load level scheme
	current_level = level_scheme
	get_tree().change_scene_to_file("res://rooms/TestingRoom.tscn")

func change_level_and_reset(level_scheme:int=current_level,ammo=true,boss=true,seed=true):
	change_level(level_scheme)
	reset_player_stats(ammo,boss,seed)

func change_scene(scene_enum:int, file_name:String = ""):
	if scene_enum != Scenes.CUSTOM:
		file_name = get_scene_string(scene_enum)
	
	get_tree().change_scene_to_file(file_name)

func reset_ammo():
	print("RESETING AMM0")
	ammo = [30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	ammo_types = [0, -1, -1, -1]
	magazine = [-1, -1, -1, -1, -1, -1]

func reset_player_stats(ammo = true, boss = true, seed = true):
	if ammo:
		reset_ammo()
	
	if boss:
		isBossTPUnlocked = false
	
	if seed:
		current_seed = -1

func change_scene_and_reset(scene_enum:int, file_name:String = "", ammo = true, boss = true, seed = true):
	
	change_scene(scene_enum, file_name)
	reset_player_stats(ammo, boss, seed)

func clear_temp_loadout():
	temporary_loadout.clear()
	temporary_types.clear()
	isBossTPUnlocked = false
	is_boss_transition_room_activated = false

# cheat codes
func _input(event: InputEvent) -> void:
	
	if event.is_action("BulletGain") and event.is_pressed() == false and event.is_echo() == false:
		ammo[0] = 999
