extends Node2D

@export var exit_type = Globals.ExitType.FOUR
@export var room_rotation = Globals.Rotation.ZERO

func get_exit_type():
	return exit_type

func get_room_rotation():
	return room_rotation
