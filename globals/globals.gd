extends Node

var room_size:int = 35
var tile_size:int = 16

#signal stat_changed

# Enums to show what names correspond to what IDs
enum Bullets {Normal, Ricochet, Shotgun, Explosive, Health, Railgun, Gambler, Empty = -1}

enum Level {
	DESERT,
	SALOON,
	HELL
}

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
	BOSS_TP
}

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
var ammo: Array[int] = [60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]:
	get:
		return ammo

# Gives the maximum ammo that can be held of a given ammo type
var ammo_max: Array[int] = [999, 30, 30, 30, 3, 12, 18, 30, 30, 30, 30, 30]

# Array of the IDs of ammo the player currently has, with -1 meaning nothing is in the slot
var ammo_types: Array[int] = [0, -1, -1, -1]

# Shows the rarity of each bullet to be used to determine pickup texture
var ammo_rarities: Array[int] = [0, 1, 1, 1, 1, 2, 2, 0, 0, 0, 0, 0]

# 6 cylinder magazine represented by a size 6 array that is frequently being changed
var magazine: Array[int] = [-1, -1, -1, -1, -1, -1]:
	get:
		return magazine

# current room
var current_room_center:Vector2 = Vector2.ZERO

func change_scene(file_name:String):
	get_tree().change_scene_to_file(file_name)
