extends Node

var room_size:int = 35
var tile_size:int = 16

#signal stat_changed

# Enums to show what names correspond to what IDs
enum Bullets {Normal, Ricochet, Shotgun, Explosive, Health, Railgun, Gambler, Empty = -1}

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

# Ammo array where a given bullet ID's ammo is shown in the index of the ID number
var ammo: Array[int] = [30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]:
	get:
		return ammo

# Gives the maximum ammo that can be held of a given ammo type
var ammo_max: Array[int] = [999, 30, 30, 30, 6, 15, 20, 30, 30, 30, 30, 30]

# Array of the IDs of ammo the player currently has, with -1 meaning nothing is in the slot
var ammo_types: Array[int] = [0, -1, -1, -1]

# Shows the rarity of each bullet to be used to determine pickup texture
var ammo_rarities: Array[int] = [0, 1, 1, 1, 1, 2, 2, 0, 0, 0, 0, 0]

# 6 cylinder magazine represented by a size 6 array that is frequently being changed
var magazine: Array[int] = [-1, -1, -1, -1, -1, -1]:
	get:
		return magazine

func change_scene(file_name:String):
	get_tree().change_scene_to_file(file_name)
