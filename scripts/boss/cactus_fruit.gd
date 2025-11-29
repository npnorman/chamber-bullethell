extends RigidBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var second_wind_timer: Timer = $SecondWindTimer

@export var bulletDamage: int = 1
@export var bulletSpeed : float = 300.0
@export var bulletScene:PackedScene

var shoot_pos:Vector2

func _ready() -> void:
	timer.wait_time = RandomNumberGenerator.new().randf_range(1.25,2.25)
	timer.start()

func _on_timer_timeout() -> void:
	
	shoot_pos = global_position
	shoot_spiral()
	explode()
	second_wind_timer.start()

func shoot_spiral():
	var shoot_targets:Array[Vector2] = [
		Vector2(1,0),
		Vector2(1,1),
		Vector2(-1,0),
		Vector2(0,1),
		Vector2(0,-1),
		Vector2(-1,1),
		Vector2(-1,-1),
		Vector2(1,-1),
	]
	
	for target in shoot_targets:
		shoot(target.normalized())

func shoot(shoot_target):
	#spawn bullets
	var newBullet:Area2D = bulletScene.instantiate()
	
	newBullet.get_node("Sprite2D").modulate = Color("green")
	newBullet.damage = bulletDamage
	newBullet.speed = bulletSpeed
	newBullet.global_position = shoot_pos
	newBullet.direction = shoot_target
	newBullet.rotation = shoot_pos.angle_to_point(shoot_pos + shoot_target) + deg_to_rad(90.0)
	
	SfxPlayer.enemy_shot_sound()
	get_tree().current_scene.add_child(newBullet)

func explode():
	animation_player.play("explode")

func _on_second_wind_timer_timeout() -> void:
	shoot_spiral()
