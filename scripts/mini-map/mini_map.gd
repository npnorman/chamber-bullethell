extends Node2D

@onready var control: Control = $CanvasLayer/Control

var icon_scene:PackedScene = preload("res://scenes/menu/icon.tscn")

var mini_size_scalar = 30.0
var center_offset:Vector2 = Vector2(1,1) * mini_size_scalar * 5.5
var mini_room_size:Vector2 = Vector2(1,1) * mini_size_scalar
var player_color_rect:ColorRect = ColorRect.new()
var player_size_scalar = 0.25
var locations = []

func _ready():
	player_color_rect.color = Color("red")
	player_color_rect.set_size(mini_room_size * player_size_scalar)
	player_color_rect.set_position(Vector2.ZERO)
	player_color_rect.z_index = 1
	control.add_child(player_color_rect)

func convert_to_mini_coords(coords:Vector2):
	var mini_coords:Vector2 = coords * mini_room_size / (Globals.tile_size * Globals.room_size)
	mini_coords += center_offset
	return mini_coords

func add_room_as_mini(room_coords:Vector2, room_special:int):
	
	if (room_coords in locations) == false:
		locations.append(room_coords)
		
		#convert coords
		var mini_coords = convert_to_mini_coords(room_coords)
		
		#add color rect
		var new_color_rect:ColorRect = ColorRect.new()
		
		new_color_rect.color = Color("black",0.5)
		new_color_rect.set_size(mini_room_size)
		new_color_rect.set_position(mini_coords)
		
		#add shop or boss icon
		var icon:String = ""
		if room_special == Globals.Special.SHOP:
			# add shop icon
			icon = "dollar"
			
		elif room_special == Globals.Special.BOSS_TP:
			# add boss icon
			icon = "skull"
		
		if icon != "":
			#add icon to current room
			var icon_control:Control = icon_scene.instantiate()
			
			control.add_child(icon_control)
			
			icon_control.set_icon(icon)
			icon_control.set_scale(Vector2.ONE * mini_size_scalar / 20)
			icon_control.set_position(mini_coords + mini_room_size/2)
			icon_control.z_index = 1
		
		control.add_child(new_color_rect)

func set_player_location(player_location:Vector2):
	var mini_coords = convert_to_mini_coords(player_location) + Vector2.ONE * mini_size_scalar/2 - Vector2.ONE * mini_size_scalar * player_size_scalar * 0.5
	player_color_rect.set_position(mini_coords)
