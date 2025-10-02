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
var m = 10
var roommap = [
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
var startingRoom = [0,0,ExitType.ONE,Rotation.ZERO]
var rooms = []

func generatorRoom(exit, rotation, count):
	var rooms = []
	
	for i in count:
		rooms.append([0,0,exit,rotation])
	
	return rooms

func generateDeadEnd(exit, rotation):
	return [0,0,exit,rotation]

func _ready() -> void:
	m = 11
	var center = int(floor(m / 2))
	
	var knapsack = generatorRoom(ExitType.FOUR,Rotation.ZERO,5)
	
	startingRoom.append(roomstack)
	roommap[center][center] = roomstack
