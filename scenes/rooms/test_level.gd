extends Node2D
class_name LevelParent

var bullet_scene: PackedScene = preload("res://scenes/player-bullet.tscn")

func _on_player_bullet_fired(pos, dir):
	var bullet = bullet_scene.instantiate()
	bullet.position = pos
	bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
	bullet.direction = dir
	$Projectiles.add_child(bullet)
