extends Node

# The goal of this file is to implement a room generation algorithm
# that is based on the idea of the "Drunkard Walk"

# define max rooms left, right, up, and down

enum Direction {
	Right,
	Left,
	Up,
	Down
}

class RoomType:
	# exits from room
	var coordinates = []
	var right = []
	var left = []
	var up = []
	var down = []

	func has_coordinate(coordinate, direction_coordinates):
		if coordinate == direction_coordinates:
			return true
		
		return false
	
	func has_exit(coordinate, direction):
		match direction:
			Direction.Right:
				return has_coordinate(coordinate, right)
			Direction.Left:
				return has_coordinate(coordinate, left)
			Direction.Up:
				return has_coordinate(coordinate, up)
			Direction.Down:
				return has_coordinate(coordinate, down)


var matrix_map = [
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
]

var rooms_to_add = []
var rooms_stack = []

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	
	# make a generate room type function
	var tempRoom = RoomType.new()
	tempRoom.up.append([0,0])
	tempRoom.coordinates.append([0,0])
	rooms_to_add.append(tempRoom)
	
	var height = len(matrix_map) - 1
	var width = len(matrix_map[0]) - 1
	
	# Start with starting room
	# get list of rest of rooms
	while len(rooms_to_add) > 0:
		var room = rooms_to_add.pop_front()
		# pick a random location to attach to
		var i_row = randi_range(0,height)
		var j_column = randi_range(0,width)
		# if it fits,
		if matrix_map[i_row][j_column] == 0:
			######TODO: Check for larger areas
			# add to matrix
			matrix_map[i_row][j_column] = 1
			# add to stack (with coordiantes i,j)
			rooms_stack.push_back(room)
		# if it doesnt,
			# keep trying
			# if it cant fit anywhere,
				# pop from stack
				# remove from matrix
				# pick a new room
		# continue for all rooms
	
	for i in matrix_map:
		print(i)
