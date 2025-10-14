extends CharacterBody2D

var player:CharacterBody2D
var target : Vector2 = Vector2.ZERO
var start : Vector2 = Vector2.ZERO
var distance = 100
var units = 32
var currentOffset = 0
var currentUnit = 0

@export var speed = 2000
@export var square_radius = 10
@export var bullet_scene:PackedScene
@export var wait_time:float = 0.5

@onready var timer: Timer = $Timer

func _ready() -> void:
	square_radius = square_radius * units
	player = get_tree().get_nodes_in_group("Player")[0]
	set_starting_target()
	timer.wait_time = wait_time

func set_starting_target():
	start = Vector2(player.global_position.x - square_radius, player.global_position.y - square_radius)
	target = start

func is_ready_for_next_target():
	if global_position.distance_to(target) <= distance:
		return true
	else:
		return false

func change_target():
	currentOffset = 1 - currentOffset
	currentUnit += units * 3
	target = Vector2(start.x + (currentOffset * square_radius * 2), start.y + currentUnit)
	
	if currentUnit > square_radius * 2:
		stop()

func drop_bullet():
	var bullet:Area2D = bullet_scene.instantiate()
	bullet.amount = 1
	bullet.bullet_id = 0
	
	bullet.global_position = global_position
	get_parent().add_child(bullet)

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
	drop_bullet()
