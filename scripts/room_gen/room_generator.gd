extends Node2D

@export var test_room:PackedScene
var one_room = preload("res://scenes/RoomGen/room_types/test_one.tscn")
var two_close_room = preload("res://scenes/RoomGen/room_types/test_two_close.tscn")
var two_apart_room = preload("res://scenes/RoomGen/room_types/test_two_apart.tscn")
var three_room = preload("res://scenes/RoomGen/room_types/test_three.tscn")
var four_room = preload("res://scenes/RoomGen/room_types/test_four.tscn")
var start_room = preload("res://scenes/RoomGen/room_types/testStart.tscn")

# map
# m x m (m = 10) expand to 11 for overflow
var current_location:Vector2 = Vector2(0,0)
var current_room:int = 0

var roomstack:Array = []
var starting_room:Vector4 = Vector4(0,0,Globals.ExitType.ONE,Globals.Rotation.NINETY)
var rooms:Array = []
var knapsack:Array = []
var roomsack:Array = []

func generateRooms(exit, rotation, count):
	var rooms:Array = []
	
	for i in count:
		rooms.append(Vector4(0,0,exit,rotation))
	
	return rooms

func add_room_current_location(room:Vector4):
	room.x = current_location.x
	room.y = current_location.y
	
	roomstack.append(room)

func generateDeadEnd(exit, rotation):
	return Vector4(0,0,exit,rotation)

func _ready() -> void:
	var m = 11
	var n = 11
	
	#define center of room to place start
	var centerM:int = int(floor(m / 2))
	var centerN:int = int(floor(n/2))
	var center = Vector2(centerM,centerN)
	current_location.x = centerM
	current_location.y = centerN
	
	#define rooms in bag to pull
	#knapsack += generateRooms(Globals.ExitType.FOUR,Globals.Rotation.ZERO,15)
	roomsack += [one_room,two_close_room,two_apart_room,three_room,four_room,start_room]
	knapsack += generateRooms(Globals.ExitType.FOUR,Globals.Rotation.ZERO,5)
	knapsack += generateRooms(Globals.ExitType.THREE,Globals.Rotation.ZERO,1)
	knapsack += generateRooms(Globals.ExitType.TWO_APART,Globals.Rotation.ZERO,2)
	#knapsack += generateRooms(Globals.ExitType.TWO_CLOSE,Globals.Rotation.ZERO,5)
	
	add_room_current_location(starting_room)
	generateMap(m,n)
	print("Roomstack")
	print(roomstack)
	
	# after stack is full,
	display_rooms(center)

func generateMap(m,n,seed:int = -1):
	var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	if seed != -1:
		rng.seed = seed
	
	while len(knapsack) > 0:
		pick_room_from_knapsack(rng,m,n)
		
		# if no room can fit, remove the topmost room from stack
			# try a different room from knapsack
				# if all rooms cannot fit,
					# remove rooms from knapsack (ERROR)
		
	# after all rooms are placed
	# for each room
		# for each exit
			# if there is no room there
				# add a dead end (generate one)
				# shop and treasure room count
				# get exits
				# create a room to satisfy all exits

func display_rooms(center:Vector2):
	for i in range(0,len(roomstack)):
	# for each room in stack
		place_room_at_xy(roomstack[i],center)
		# use 32x32 offset to place room scenes
		# (rooms should have leftmost corner at 0,0)
		# (rooms should have centered walkways to connect)

func place_room_at_xy(coords:Vector4,center:Vector2):
	var tile_offset = 32 * 16 #32 tiles each at 16 pixels
	
	var newRoom:Node2D
	
	for i in range(0,len(roomsack)):
		var tempRoom = roomsack[i].instantiate()
		if tempRoom.get_exit_type() == coords.z:
			if tempRoom.get_room_rotation() == coords.w:
				newRoom = tempRoom
	
	var adjusted_coords:Vector2 = Vector2(coords.x,coords.y)
	adjusted_coords -= center
	adjusted_coords *= tile_offset
	adjusted_coords.y *= -1
	
	newRoom.global_position = adjusted_coords
	
	add_child(newRoom)

func pick_room_from_knapsack(rng:RandomNumberGenerator,m,n):
	# pick a random room in the knapsack, and remove it
	var knapsack_index:int = rng.randi_range(0,len(knapsack)-1)
	var newRoom:Vector4 = knapsack.pop_at(knapsack_index)
	
	# pick a random room in the stack
	var roomstack_index:int = rng.randi_range(0,len(roomstack)-1)
	var oldRoom:Vector4 = roomstack[roomstack_index]
	
	current_location.x = oldRoom.x
	current_location.y = oldRoom.y
	
	# pick a random exit from that room
	var number_of_exits = get_number_of_exits(oldRoom)
	var exits:Array = get_exits(oldRoom)
	var possible_index:Array = [0,1,2,3]
	var exit_index = possible_index[rng.rand_weighted(exits)]
	
	var is_blocking = false
	
	var new_exits:Array = get_exits(newRoom)
	var new_exit_index:int = (exit_index + 2) % 4
	#check to see if it matches an exit
	if exits[exit_index] == 1 and new_exits[new_exit_index] == 1:
		is_blocking = false
	else:
		is_blocking = true
	
	exits[0] *= -1
	exits[3] *= -1
	
	for i in range(0, len(exits)):
		if i != exit_index:
			exits[i] = 0
	
	#get the offset
	var offset:Vector2 = Vector2(0,0)
	offset.x = exits[0] + exits[2]
	offset.y = exits[1] + exits[3]
	
	var checkingCoordinates:Vector2 = Vector2(0,0)
	checkingCoordinates = current_location + offset
	
	# check if that spot (x,y) is taken
	if abs(checkingCoordinates.x) > m or abs(checkingCoordinates.y) > n:
		is_blocking = true
		
	elif is_room_in_xy(checkingCoordinates):
		is_blocking = true
		
	else:
		var neighbors = [
			Vector2( 1, 0),
			Vector2(-1, 0),
			Vector2( 0, 1),
			Vector2( 0,-1)
			]
		# for each neighbor (if exists)
		for i in range(0, len(neighbors)):
			# check if neighbor's exit is being blocked
			if is_room_in_xy(current_location + neighbors[i]):
				if is_blocking_exit(current_location, neighbors[i], exits):
					is_blocking = true
	
	if is_blocking == true:
		knapsack.append(newRoom)
		#try again
	else:
		# place room
		newRoom.x = checkingCoordinates.x
		newRoom.y = checkingCoordinates.y
		current_location = checkingCoordinates
		roomstack.append(newRoom)

func is_blocking_exit(room_coords:Vector2,neighbor_coords:Vector2, room_exits:Array):
	#get room at xy
	var neighbor:Vector4 = get_room_at_xy(room_coords + neighbor_coords)
	#get exits of room
	var neighbor_exits:Array = get_exits(neighbor)
	
	var is_blocking:bool = false
	
	#check if blocking neighbor
	if neighbor_coords.x == -1 and neighbor_exits[0] == 1:
		#check if current room has path to this room
		if room_exits[2] != 1:
			is_blocking = true
		
	elif neighbor_coords.x == 1 and neighbor_exits[2] == -1:
		#check if current room has path to this room
		if room_exits[0] != 1:
			is_blocking = true
		
	elif neighbor_coords.y == -1 and neighbor_exits[1] == -1:
		#check if current room has path to this room
		if room_exits[1] != 1:
			is_blocking = true
		
	elif neighbor_coords.y == 1 and neighbor_exits[3] == 1:
		#check if current room has path to this room
		if room_exits[3] != 1:
			is_blocking = true
	
	return is_blocking

func get_room_at_xy(coordinates:Vector2):
	var x = coordinates.x
	var y = coordinates.y
	var room:Vector4
	
	for i in range(0,len(roomstack)):
		if roomstack[i].x == x and roomstack[i].y == y:
			room = roomstack[i]
	
	return room

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

func is_room_in_xy(coordinates:Vector2):
	var x = coordinates.x
	var y = coordinates.y
	
	var is_room_in_spot = false
	for i in range(0,len(roomstack)):
		if roomstack[i].x == x and roomstack[i].y == y:
			is_room_in_spot = true
			break
	
	return is_room_in_spot
