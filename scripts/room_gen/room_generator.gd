extends Node

enum ExitType {
	FOUR,
	THREE,
	TWO,
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
var roommap:Array = [
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]],
	[[],[],[],[],[],[],[],[],[],[],[]]
]

var roomstack:Array = []
var starting_room:Vector4 = Vector4(0,0,ExitType.ONE,Rotation.ZERO)
var rooms:Array = []

func generateRooms(exit, rotation, count):
	var rooms:Array = []
	
	for i in count:
		rooms.append(Vector4(0,0,exit,rotation))
	
	return rooms

func add_room_current_location(room:Vector4):
	roommap[current_location.x][current_location.y] = room

func generateDeadEnd(exit, rotation):
	return Vector4(0,0,exit,rotation)

func _ready() -> void:
	var m = len(roommap)
	var n = len(roommap[0])
	
	#define center of room to place start
	var centerM:int = int(floor(m / 2))
	var centerN:int = int(floor(n/2))
	current_location.x = centerM
	current_location.y = centerN
	
	#define rooms in bag to pull
	var knapsack:Array = generateRooms(ExitType.FOUR,Rotation.ZERO,5)
	
	roomstack.append(starting_room)
	add_room_current_location(starting_room)
	generateMap()
	
	for line in roommap:
		print(line)

func generateMap():
	# pick a random room in the knapsack
	# pick a random room in the stack
	# pick a random exit from that room
	# check if that spot (x,y) is taken
		# for each neighbor (if exists)
			# check if neighbor's exit is being blocked
				# if it can fit, add to map/stack
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
