extends RigidBody2D

@onready var timer: Timer = $Timer
@export var bulletDamage: int = 1
@export var bulletSpeed : float = 300.0
@export var bulletScene:PackedScene


#func _ready() -> void:
	#timer.start()
#
#func _on_timer_timeout() -> void:
	##spawn bullets
	#var newBullet:Area2D = bulletScene.instantiate()
	#var shoot_target:Vector2 = get_tree().get_nodes_in_group("Player")[0].global_position
	#
	#newBullet.get_node("Sprite2D").modulate = Color("green")
	#newBullet.damage = bulletDamage
	#newBullet.speed = bulletSpeed
	#newBullet.global_position = global_position
	#newBullet.direction = global_position.direction_to(shoot_target)
	#newBullet.rotation = global_position.angle_to_point(shoot_target) + deg_to_rad(90.0)
	#
	#SfxPlayer.enemy_shot_sound()
	#get_tree().current_scene.add_child(newBullet)
