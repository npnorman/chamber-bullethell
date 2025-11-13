extends CharacterBody2D

# arms
@onready var right_arm: Node2D = $RightArm
@onready var left_arm: Node2D = $LeftArm

var target:Vector2 = Vector2.ZERO
var origin:Vector2 = Vector2.ZERO
var direction:Vector2 = Vector2.ZERO
var speed : float = 500

# Bullets
var bulletDamage = 1
var bulletSpeed = 100
var despawnTime = 10
@export var bulletScene:PackedScene
var player

var targetDelta = 100
var movementOffset = 0
var movementSize = Globals.room_size * Globals.tile_size / 2
var phase2 = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(-1,0),
	Vector2(0,-1)
]

func _ready() -> void:
	#get player
	player = get_tree().get_first_node_in_group("Player")
	
	origin = global_position
	set_target(origin + phase2[movementOffset])

func _physics_process(delta: float) -> void:
	
	if global_position.distance_to(target) < targetDelta:
		# set new target
		movementOffset = (movementOffset + 1) % len(phase2)
		set_target(origin + (phase2[movementOffset] * movementSize))
		
		shoot_arm(right_arm)
		shoot_arm(left_arm)
	
	move_to_target(delta)
	move_and_slide()

func set_target(target:Vector2):
	self.target = target

func move_to_target(delta):
	#move towards target
	var direction = Vector2.ZERO
	
	direction = global_position.direction_to(target)
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, delta)

func get_shoot_target():
	return player.global_position

func shoot(shoot_from_position:Vector2):
	var newBullet:Area2D = bulletScene.instantiate()
	var shoot_target:Vector2 = get_shoot_target()
	
	var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	var colors = [Color("Yellow"), Color("8c6e00"), Color("ffc64a")]
	var color_index:int = rng.randi_range(0, len(colors) - 1)
	print(color_index)
	
	var color:Color = colors[color_index]
	
	newBullet.get_node("Sprite2D").modulate = color
	newBullet.damage = bulletDamage
	newBullet.speed = bulletSpeed
	newBullet.global_position = shoot_from_position
	newBullet.direction = shoot_from_position.direction_to(shoot_target)
	newBullet.rotation = shoot_from_position.angle_to_point(shoot_target) + deg_to_rad(90.0)
	
	SfxPlayer.enemy_shot_sound()
	get_tree().current_scene.add_child(newBullet)
	
	newBullet.set_despawn_timer(despawnTime)

func shoot_arm(arm):
	for marker:Marker2D in arm.get_children():
		shoot(marker.global_position)
