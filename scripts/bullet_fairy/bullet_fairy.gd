extends CharacterBody2D

var target : Vector2 = Vector2.ZERO
var starting_position : Vector2 = Vector2.ZERO
var distance = 100
var units = Globals.tile_size
var currentOffset = 0
var currentUnit = 0

@export var speed = 1000
@export var square_radius = Globals.room_size / 2
@export var bullet_scene:PackedScene
@export var wait_time:float = 0.5

@onready var timer: Timer = $Timer

func _ready() -> void:
	square_radius = square_radius * units
	set_starting_positioning_target()
	timer.wait_time = wait_time

func set_starting_positioning_target():
	target = Vector2(starting_position.x - square_radius, starting_position.y - square_radius)

func is_ready_for_next_target():
	if global_position.distance_to(target) <= distance:
		return true
	else:
		return false

func change_target():
	currentOffset = 1 - currentOffset
	currentUnit += units * 2
	target = Vector2(starting_position.x + (currentOffset * square_radius * 2), starting_position.y + currentUnit)
	
	if currentUnit > square_radius * 2:
		stop()

func drop_bullet():
	get_parent().spawn_pickup(Globals.Bullets.Normal, 1, global_position)

func _physics_process(delta: float) -> void:
	
	move_to_target(delta)
	
	if is_ready_for_next_target():
		change_target()
	
	move_and_slide()

func stop():
	self.queue_free()

func move_to_target(delta):
	#move towards target
	var direction = Vector2.ZERO
	
	direction = global_position.direction_to(target)
	velocity = velocity.lerp(direction * speed, delta)

func _on_timer_timeout() -> void:
	if (global_position.distance_to(starting_position) < (Globals.room_size * Globals.tile_size / 2)):
		drop_bullet()
