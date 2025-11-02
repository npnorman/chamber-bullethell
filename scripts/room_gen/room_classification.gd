extends Node2D

@export var exit_type = Globals.ExitType.FOUR
@export var room_rotation = Globals.Rotation.ZERO

var fire_wall = preload("res://scenes/RoomGen/fire_wall.tscn")
var invalid_exits = []

@onready var enemies: Node = $Enemies
@onready var center: Marker2D = $Center
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var is_completed = false
var walls = []
var room = Globals.tile_size * Globals.room_size
var coordinates = [
	Vector2(room - Globals.tile_size / 2, -room / 2), # Right Wall
	Vector2(room / 2, -(room - Globals.tile_size / 2)), # Top Wall
	Vector2(Globals.tile_size / 2, -room / 2), # Left Wall
	Vector2(room / 2, -Globals.tile_size / 2), # Bottom Wall
	]

func _process(delta: float) -> void:
	if enemies != null:
		if !is_completed and enemies.get_child_count() <= 0:
			is_completed = true
			remove_walls()

func get_exit_type():
	return exit_type

func get_room_rotation():
	return room_rotation

func activate_enemies():
	if enemies != null:
		print("Activating enemies")
		for node in enemies.get_children():
			if node.is_in_group("Enemy"):
				node.activate()

func set_walls():
	
	if enemies != null:
		if enemies.get_child_count() > 0:
			
			activate_enemies()
			
			var exits = Globals.get_exits(Vector4(0,0,exit_type,room_rotation))
			print(exits)
			
			if !is_completed and len(walls) == 0:
				# set at all four spots (for now)
				for i in range(0,4):
					
					#only for each exit
					if exits[i] != 0 and invalid_exits[i] != 1:
						var temp_fire_wall:Node2D = fire_wall.instantiate()
						
						temp_fire_wall.position = coordinates[i]
						temp_fire_wall.rotation_degrees = (-90 * i + 90) % 360 # matches exit (R,U,L,D)
						
						walls.append(temp_fire_wall)
						add_child(temp_fire_wall)

func remove_walls():
	for i in range(0, len(walls)):
		walls[i].put_out()

func set_dead_ends(invalid_exits):
	var exits = Globals.get_exits(Vector4(0,0,exit_type,room_rotation))
	self.invalid_exits = invalid_exits
	
	if !is_completed and len(walls) == 0:
		for i in range(0,4):
			
			#only for each exit
			if exits[i] != 0 and invalid_exits[i] != 0:
				# set tiles to wall elements
				
				if i == 0: #right
					for k in range(-21,-14):
						# tile location, tileset id, tile location in atlas
						tile_map_layer.set_cell(Vector2i(34,k),0,Vector2i(6,1))
				elif i == 1: #top
					for k in range(12,22):
						# tile location, tileset id, tile location in atlas
						tile_map_layer.set_cell(Vector2i(k,-35),0,Vector2i(5,0))
				elif i == 2: #left
					for k in range(-21,-14):
						# tile location, tileset id, tile location in atlas
						tile_map_layer.set_cell(Vector2i(0,k),0,Vector2i(4,1))
				elif i == 3: #bottom
					for k in range(12,22):
						# tile location, tileset id, tile location in atlas
						tile_map_layer.set_cell(Vector2i(k,-1),0,Vector2i(5,2))
