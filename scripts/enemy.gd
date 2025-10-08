extends CharacterBody2D

var target:CharacterBody2D
@export var speed : float = 300.0
@export var health : int = 12
@export var bulletDamage: int = 1
@export var bulletSpeed : float = 300.0
@export var distance_from_player : float = 100
@export var bulletScene:PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var reroute_timer: Timer = $RerouteTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_moving:bool = true
var is_dead:bool = false
var last_static_position:Vector2
var is_wiggle_room_set = true
var wiggle_room:float = 1.0
var wait_time:float = 3.0

signal killed(enemy_position: Vector2, ammo_dropped: int)

func _ready() -> void:
	target = get_tree().get_nodes_in_group("Player")[0]
	reroute_timer.wait_time = wait_time
	decide_nav_route()

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
		animation_player.stop()
		animation_player.play("color_red")

func enemy_die():
	# or dead body
	if not is_dead:
		killed.emit(self.global_position, 5)
	is_dead = true
	animated_sprite_2d.play("death")
	animation_player.play("death")

func shoot():
	var newBullet:Area2D = bulletScene.instantiate()
	
	newBullet.get_node("Sprite2D").modulate = Color("green")
	newBullet.damage = bulletDamage
	newBullet.speed = bulletSpeed
	newBullet.global_position = global_position
	newBullet.direction = global_position.direction_to(target.global_position)
	newBullet.rotation = global_position.angle_to_point(target.global_position) + deg_to_rad(90.0)
	
	get_parent().add_child(newBullet)

func _on_reroute_timer_timeout() -> void:
	# reroute navagent
	# stops jittering
	shoot()
	decide_nav_route()
	
	# random
	var times = [-2,2]
	var rng = RandomNumberGenerator.new()
	var wiggle = times[rng.randi_range(0,times.size()-1)]
	reroute_timer.wait_time = wait_time + wiggle
