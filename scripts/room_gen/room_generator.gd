extends Node2D

var level_scheme = Globals.Level.DESERT
@export var seed:int = -1
var whitelisted_seeds: Array[int] = [
	-8936538142480759030,
	8330090822928439027,
	-2374852792297491077,
	5791905783169608974,
	8709846147640377037,
	4123980760642043700,
	-7566002206154862345,
	-7716214477206242611,
	-6119666404580504737,
	-1968190462505291320,
	-7958553637138446281,
	-5937690610881136008,
	-3094195938774167016,
	5609049809592965788,
	608514840451453305,
	4001039430144054665,
	-464886403964471626,
	3370616903778519379,
	-7441315699145809511,
	-244267153831101229,
	-6807139612009162576,
	2819756536803145403
]

var one_room = preload("res://scenes/RoomGen/room_types/test_one.tscn")
var two_close_room = preload("res://scenes/RoomGen/room_types/test_two_close.tscn")
var two_apart_room = preload("res://scenes/RoomGen/room_types/test_two_apart.tscn")
var three_room = preload("res://scenes/RoomGen/room_types/test_three.tscn")
var four_room = preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom4.tscn")
var desert_start_room = preload("res://rooms/AlgorithmRooms/DesertRooms/desert_start.tscn")
var tavern_start_room = preload("res://rooms/AlgorithmRooms/TavernRooms/tavern_start.tscn")
var hell_start_room = preload("res://rooms/AlgorithmRooms/HellRooms/hell_start.tscn")

var desert_shop = preload("res://rooms/AlgorithmRooms/SpecialtyRooms/Desert/desert_shop.tscn")
var desert_boss_tp = preload("res://rooms/AlgorithmRooms/SpecialtyRooms/Desert/desert_boss_tp.tscn")

var desert_rooms = [ #dont include start
	[2,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom3.tscn")],
	[5,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom4.tscn")],
	[2,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom5.tscn")],
	[1,desert_shop],
	[1,desert_boss_tp],
	[1,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom0.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom1.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom2.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom6.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom7.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom8.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/DesertRooms/DesertRoom9.tscn")],
]
var saloon_rooms = [
	[5,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom6.tscn")],
	#boss tp + shop
	[1,preload("res://rooms/AlgorithmRooms/SpecialtyRooms/Tavern/Tavern_boss_tp.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/SpecialtyRooms/Tavern/Tavern_Shop.tscn")],
	
	[1,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom0.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom1.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom2.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom3.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom4.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom5.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom7.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom8.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/TavernRooms/TavernRoom9.tscn")],
]
var hell_rooms = [
	[5,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom4.tscn")],
	#bosstp and shop
	[1,preload("res://rooms/AlgorithmRooms/SpecialtyRooms/Hell/hell_boss_tp.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/SpecialtyRooms/Hell/Hell_Shop.tscn")],
	
	[1,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom0.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom1.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom2.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom3.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom5.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom6.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom7.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom8.tscn")],
	[1,preload("res://rooms/AlgorithmRooms/HellRooms/HellRoom9.tscn")],
]

# map
# m x m (m = 10) expand to 11 for overflow
var current_location:Vector2 = Vector2(0,0)
var current_room:int = 0

var roomstack:Array = []
var starting_room:Vector4 = Vector4(0,0,Globals.ExitType.ONE,Globals.Rotation.NINETY)
var rooms:Array = []
var knapsack:Array = []
var rejected_knapsack = [] #twice around
var roomsack:Array = []

func generateRooms(exit:int, room_rotation:int, count:int):
	var rooms:Array = []
	
	for i in count:
		rooms.append(Vector4(0,0,exit,room_rotation))
	
	return rooms

func add_room_current_location(room:Vector4):
	room.x = current_location.x
	room.y = current_location.y
	
	roomstack.append(room)

func generateDeadEnd(exit, rotation):
	return Vector4(0,0,exit,rotation)

func _ready() -> void:
	
	# get level scheme
	level_scheme = Globals.current_level
	
	# check seed from global
	if Globals.current_seed != -1:
		seed = Globals.current_seed
	
	var m = 11
	var n = 11
	
	#define center of room to place start
	var centerM:int = int(floor(m / 2))
	var centerN:int = int(floor(n/2))
	var center = Vector2(centerM,centerN)
	current_location.x = centerM
	current_location.y = centerN
	
	#define rooms in bag to pull
	var all_rooms = [desert_rooms, saloon_rooms, hell_rooms]
	roomsack += all_rooms[level_scheme]
	
	for room in roomsack:
		var tempRoom = room[1].instantiate()
		knapsack += generateRooms(tempRoom.exit_type, tempRoom.room_rotation, room[0])
	
	add_room_current_location(starting_room)
	if seed == -1:
		var rng:RandomNumberGenerator = RandomNumberGenerator.new()
		var seed_index = rng.randi_range(0, whitelisted_seeds.size() - 1)
		seed = whitelisted_seeds[seed_index]
	generateMap(m,n,seed)
	print("Rooms:    ",roomstack)
	print("Rejected: ",rejected_knapsack)
	print("rooms ",len(roomstack)," rejected ",len(rejected_knapsack))
	
	#get dead ends to fill
	var invalid_exits = get_invalid_exits(roomstack)
	
	# after stack is full,
	display_rooms(center, invalid_exits)

func get_invalid_exits(roomstack):
	
	var invalid_exits = []
	
	# for each room
	for room in roomstack:
		var temp_invalid_exits = [0,0,0,0]
		# get exits
		var currentExits = Globals.get_exits(room)
		currentExits[2] *= -1
		currentExits[3] *= -1
		# for each exit
		for i in range(0,4):
			# if in exits
			if currentExits[i] != 0:
				# if room at exit
				var coords = Vector2(room.x, room.y)
				
				if i % 2 == 0:
					# x's
					coords.x += currentExits[i]
				else:
					#y's
					coords.y += currentExits[i]
				
				if is_room_in_xy(coords):
					# set invalid = 0
					temp_invalid_exits[i] = 0
				# otherwise
				else:
					# set invalid = 1 // dead end
					temp_invalid_exits[i] = 1
				
		invalid_exits.append(temp_invalid_exits)
	
	return invalid_exits

func generateMap(m,n,seed:int):
	var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	if seed != -1:
		rng.seed = seed
		seed(seed) # global seed for .shuffle()
		Globals.current_seed = seed
	else:
		seed(rng.seed)
		print("Seed: ", rng.seed)
		Globals.current_seed = rng.seed
	
	var has_rejected = 5
	while len(knapsack) > 0:
		pick_room_from_knapsack(rng,m,n)
		
		if len(knapsack) == 0 and has_rejected > 0:
			has_rejected -= 1
			if len(rejected_knapsack) > 0:
				knapsack = rejected_knapsack.duplicate(true)
				rejected_knapsack.clear()
		
		# if no room can fit, remove the topmost room from stack
			# try a different room from knapsack
				# if all rooms cannot fit,
					# remove rooms from knapsack (ERROR)

func display_rooms(center:Vector2, invalid_exits):
	for i in range(0,len(roomstack)):
	# for each room in stack
		place_room_at_xy(roomstack[i],center, invalid_exits[i])
		# use 32x32 offset to place room scenes
		# (rooms should have leftmost corner at 0,0)
		# (rooms should have centered walkways to connect)

func place_room_at_xy(coords:Vector4,center:Vector2, invalid_exit):
	var tile_offset = Globals.room_size * Globals.tile_size
	
	var newRoom:Node2D
	
	if coords.x == center.x and coords.y == center.y:
		#starting room
		#use starting room instead of roomsack
		match Globals.current_level:
			Globals.Level.SALOON:
				newRoom = tavern_start_room.instantiate()
			Globals.Level.DESERT:
				newRoom = desert_start_room.instantiate()
			Globals.Level.HELL:
				newRoom = hell_start_room.instantiate()
		
	else:
		#look thru roomsack
		#shuffle the roomsack
		roomsack.shuffle()
		for i in range(0,len(roomsack)):
			var tempRoom:Node2D = roomsack[i][1].instantiate()
			#if any allocated
			if roomsack[i][0] > 0:
				if tempRoom.get_exit_type() == coords.z:
					if tempRoom.get_room_rotation() == coords.w:
						#instantiate room
						newRoom = tempRoom
						
						#remove from sack (subtract 1)
						roomsack[i][0] -= 1
						break
	
	var adjusted_coords:Vector2 = Vector2(coords.x,coords.y)
	adjusted_coords -= center
	adjusted_coords *= tile_offset
	adjusted_coords.y *= -1
	
	add_child(newRoom)
	newRoom.global_position = adjusted_coords
	newRoom.set_dead_ends(invalid_exit)

func pick_room_from_knapsack(rng:RandomNumberGenerator,m,n):
	# if this is true, the room cannot fit
	var is_blocking = false
	
	# pick a random room in the knapsack, and remove it
	var knapsack_index:int = rng.randi_range(0,len(knapsack)-1)
	var newRoom:Vector4 = knapsack.pop_at(knapsack_index)
	
	# for each room
		# pick and try to make it work
		# if it does, keepGoing
		# if it doesn't remove
	# get list of all rooms in stack (copy)
	
	var roomstack_copy = roomstack.duplicate(true)
	# shuffle rooms
	roomstack_copy.shuffle()
	
	var roomstack_index:int = 0
	# for each room, pick one and try to make it work
	while len(roomstack_copy) > 0:
		var oldRoom:Vector4 = roomstack_copy[roomstack_index]
	
		current_location.x = oldRoom.x
		current_location.y = oldRoom.y
		
		# pick a random exit from that room
		var number_of_exits = Globals.get_number_of_exits(oldRoom)
		var exits:Array = Globals.get_exits(oldRoom)
		var possible_index:Array = [0,1,2,3]
		
		for i in range(0,len(exits)):
			if exits[i] == 0:
				possible_index.erase(i)
		
		#shuffle exits
		possible_index.shuffle()
		
		# while exit is not chosen,
		var index = 0
		while len(possible_index) > 0:
			# choose an exit
			var exit_index = possible_index[index]
			
			var new_exits:Array = Globals.get_exits(newRoom)
			# new roomexit needs to be opposite of this room
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
					if is_room_in_xy(checkingCoordinates + neighbors[i]):
						if is_blocking_exit(checkingCoordinates, neighbors[i], new_exits):
							is_blocking = true
				
			if is_blocking == true:
				# try next exit
				possible_index.erase(exit_index)
				#try again
			else:
				# place room
				possible_index.clear() #stop while
				newRoom.x = checkingCoordinates.x
				newRoom.y = checkingCoordinates.y
				current_location = checkingCoordinates
				roomstack.append(newRoom)
		
		if is_blocking == true:
			# oldroom cant fit new room
			roomstack_copy.erase(oldRoom)
		else:
			#stop while loop
			roomstack_copy.clear()
	
	if is_blocking == true:
		# room cannot fit anywhere
		# add to rejected list
		rejected_knapsack.append(newRoom)

func is_blocking_exit(room_coords:Vector2,neighbor_coords:Vector2, room_exits:Array):
	#get room at xy
	var neighbor:Vector4 = get_room_at_xy(room_coords + neighbor_coords)
	#get exits of room
	var neighbor_exits:Array = Globals.get_exits(neighbor)
	
	var is_blocking:bool = false
	
	#check if blocking neighbor
	if neighbor_coords.x == -1:
		if abs(neighbor_exits[0]) == 1:
			#check if current room has path to this room
			if room_exits[2] == 0:
				is_blocking = true
		else:
			#if there is no exit from the neighbor to us
			#make sure we do not have an exit going to the neighbor
			if room_exits[2] != 0:
				#there is an exit here to the neighbor
				is_blocking = true
		
	elif neighbor_coords.x == 1:
		if abs(neighbor_exits[2]) == 1:
			#if the neighbor has an exit to the current room
			#make sure the current room has an exit to its neighbor
			if room_exits[0] == 0:
				is_blocking = true
		else:
			#if there is no exit from the neighbor to us
			#make sure we do not have an exit going to the neighbor
			if room_exits[0] != 0:
				#there is an exit here to the neighbor
				is_blocking = true
		
	elif neighbor_coords.y == -1:
		if abs(neighbor_exits[1]) == 1:
			#check if current room has path to this room
			if room_exits[3] == 0:
				is_blocking = true
		else:
			#if there is no exit from the neighbor to us
			#make sure we do not have an exit going to the neighbor
			if room_exits[3] != 0:
				#there is an exit here to the neighbor
				is_blocking = true
		
	elif neighbor_coords.y == 1:
		if abs(neighbor_exits[3]) == 1:
			#check if current room has path to this room
			if room_exits[1] == 0:
				is_blocking = true
		else:
			#if there is no exit from the neighbor to us
			#make sure we do not have an exit going to the neighbor
			if room_exits[1] != 0:
				#there is an exit here to the neighbor
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

func is_room_in_xy(coordinates:Vector2):
	var x = coordinates.x
	var y = coordinates.y
	
	var is_room_in_spot = false
	for i in range(0,len(roomstack)):
		if roomstack[i].x == x and roomstack[i].y == y:
			is_room_in_spot = true
			break
	
	return is_room_in_spot
