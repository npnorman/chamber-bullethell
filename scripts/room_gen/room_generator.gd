extends Node

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

# map
# m x m (m = 10) expand to 11 for overflow
var current_location:Vector2 = Vector2(0,0)
var current_room:int = 0

var roomstack:Array = []
var starting_room:Vector4 = Vector4(0,0,ExitType.ONE,Rotation.NINETY)
var rooms:Array = []
var knapsack:Array = []

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
	current_location.x = centerM
	current_location.y = centerN
	
	#define rooms in bag to pull
	knapsack += generateRooms(ExitType.FOUR,Rotation.ZERO,5)
	
	add_room_current_location(starting_room)
	generateMap()

func generateMap(seed:int = -1):
	var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	if seed != -1:
		rng.seed = seed
	
	# pick a random room in the knapsack, and remove it
	var knapsack_index:int = rng.randi_range(0,len(knapsack)-1)
	var newRoom:Vector4 = knapsack[knapsack_index]
	
	# pick a random room in the stack
	var roomstack_index:int = rng.randi_range(0,len(roomstack)-1)
	var oldRoom:Vector4 = roomstack[roomstack_index]
	
	# pick a random exit from that room
	var number_of_exits = get_number_of_exits(oldRoom)
	var exits:Array = get_exits(oldRoom)
	var possible_index:Array = [0,1,2,3]
	var exit_index = possible_index[rng.rand_weighted(exits)]
	
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
	if is_room_in_xy(checkingCoordinates) == false:
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
				pass
				#get room at xy
				#get exits of room
				#if no exits point to this room
					# it can fit, add to map/stack
					# otherwise, pick another random spot
	
	# if no room can fit, remove the topmost room from stack
		# try a different room from knapsack
			# if all rooms cannot fit,
				# remove rooms from knapsack (ERROR)
	
	# after all rooms are placed
	# for each room
		# for each exit
			# if there is no room there
				# add a dead end (generate one)
	
	# after stack is full,
		# for each room in stack
			# use 32x32 offset to place room scenes
			# (rooms should have leftmost corner at 0,0)
			# (rooms should have centered walkways to connect)

func get_number_of_exits(room:Vector4):
	var number_of_exits = 0
	
	match room.z:
		ExitType.ZERO:
			number_of_exits = 0
		ExitType.NONE:
			number_of_exits = 0
		ExitType.ONE:
			number_of_exits = 1
		ExitType.TWO_CLOSE:
			number_of_exits = 2
		ExitType.TWO_APART:
			number_of_exits = 2
		ExitType.THREE:
			number_of_exits = 3
		ExitType.FOUR:
			number_of_exits = 4
	
	return number_of_exits

func get_exits(room:Vector4):
	var exits:Array = [0,0,0,0]
	# offset of (x-1,y+1,x-1,y-1)
		# a 1 if correct, a zero if not
	
	match int(room.z):
		ExitType.ONE:
			exits = [1,0,0,0]
		ExitType.TWO_CLOSE:
			exits = [1,1,0,0]
		ExitType.TWO_APART:
			exits = [1,0,1,0]
		ExitType.THREE:
			exits = [1,1,1,0]
		ExitType.FOUR:
			exits = [1,1,1,1]
	
	var amount = 0
	
	match int(room.w):
		Rotation.NINETY:
			amount = 1
		Rotation.ONEEIGHTY:
			amount = 2
		Rotation.TWOSEVENTY:
			amount = 3
	
	exits = rotate_exits(exits,amount)
	return exits

func rotate_exits(exits:Array, amount:int):
	for i in range(0,amount):
		exits = cyclic_shift(exits)
	
	return exits

func cyclic_shift(exits:Array):
	var swap = exits[3]
	exits[3] = exits[2]
	exits[2] = exits[1]
	exits[1] = exits[0]
	exits[0] = swap
	
	return exits

func is_room_in_xy(coordinates:Vector2):
	var x = coordinates.x
	var y = coordinates.y
	
	for i in range(0,len(roomstack)):
		if roomstack[i].x == x and roomstack[i].y == y:
			return true
		else:
			return false
