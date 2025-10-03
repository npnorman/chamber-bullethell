extends Node

signal stat_changed

# Enums to show what names correspond to what IDs
enum Bullets {Normal, Ricochet, Shotgun, Empty = -1}

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
var ammo: Array[int] = [30, 12, 12]:
	get:
		return ammo

# 6 cylinder magazine represented by a size 6 array that is frequently being changed
var magazine: Array[int] = [2, 0, 0, 0, 0, 0]:
	get:
		return magazine
