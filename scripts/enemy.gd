extends CharacterBody2D

var target:CharacterBody2D
@export var is_active: bool = true
@export var speed : float = 300.0
@export var health : int = 12
@export var bulletDamage: int = 1
@export var bulletSpeed : float = 300.0
@export var distance_from_player : float = 100
@export var wait_time:float = 3.0
@export var wiggle : float = 2.0
@export var bulletScene:PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var reroute_timer: Timer = $RerouteTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_target_reached:bool = false
var is_dead:bool = false

signal killed(enemy_position: Vector2, ammo_dropped: int)

func _ready() -> void:
	
	nav_agent.target_desired_distance = distance_from_player
	
	target = get_tree().get_nodes_in_group("Player")[0]
	reroute_timer.wait_time = wait_time
	decide_nav_route()

func _physics_process(delta: float) -> void:
	if is_active and !is_dead:
		
		if !is_target_reached:
			move_to_target(delta)
		else:
			velocity = velocity.lerp(Vector2.ZERO,0.5)
		
		move_and_slide()

func decide_nav_route():
	#set target
	is_target_reached = false
	nav_agent.target_position = target.global_position

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
	var shoot_target:Vector2 = get_shoot_target()
	
	newBullet.get_node("Sprite2D").modulate = Color("green")
	newBullet.damage = bulletDamage
	newBullet.speed = bulletSpeed
	newBullet.global_position = global_position
	newBullet.direction = global_position.direction_to(shoot_target)
	newBullet.rotation = global_position.angle_to_point(shoot_target) + deg_to_rad(90.0)
	
	get_parent().add_child(newBullet)

func activate():
	is_active = true

func get_shoot_target():
	return target.global_position

func _on_reroute_timer_timeout() -> void:
	# reroute navagent
	if !is_dead and is_active:
		shoot()
		decide_nav_route()
		
		# random
		var times = [-wiggle,wiggle]
		var rng = RandomNumberGenerator.new()
		var wiggle = times[rng.randi_range(0,times.size()-1)]
		reroute_timer.wait_time = wait_time + wiggle

func _on_navigation_agent_2d_target_reached() -> void:
	is_target_reached = true
