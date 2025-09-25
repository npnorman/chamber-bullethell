extends Node

signal stat_changed

# Enums to show what names correspond to what IDs
enum Bullets {Normal, Ricochet, Shotgun, Empty = -1}

# Ammo array where a given bullet ID's ammo is shown in the index of the ID number
var ammo: Array[int] = [30, 18, 18]:
	get:
		return ammo

# 6 cylinder magazine represented by a size 6 array that is frequently being changed
var magazine: Array[int] = [-1, -1, -1, -1, -1, -1]:
	get:
		return magazine
