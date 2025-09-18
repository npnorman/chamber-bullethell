extends CharacterBody2D

var target:CharacterBody2D
@export var speed : float = 300.0
@export var health : int = 2
@export var distance_from_player : float = 100

@onready var sprite: Sprite2D = $Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_moving:bool = true
var last_static_position:Vector2
var is_wiggle_room_set = true
var wiggle_room:float = 1.0

func _ready() -> void:
	target = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta: float) -> void:
	
	move_to_target(delta)
	
	move_and_slide()

func is_within_distance_from_target():
	
	if target.global_position.distance_to(global_position) <= distance_from_player:
		return true
		
	return false

func decide_nav_route():
	#set target
	#TODO: make more inline with what we want later
	var v1 = target.global_position - global_position
	var v1n = v1.normalized()
	
	nav_agent.target_position = target.global_position - (v1n * distance_from_player)

func move_to_target(delta):
	#move towards target
	var direction = Vector2.ZERO
	
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, delta)

func take_damage(damage:int):
	health -= damage
	if health <= 0:
		enemy_die()
	else:
		animation_player.play("color_red")

func enemy_die():
	# or dead body
	animation_player.play("death")

func _on_reroute_timer_timeout() -> void:
	# reroute navagent
	# stops jittering
	decide_nav_route()
