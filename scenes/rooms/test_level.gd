extends Node2D
class_name LevelParent

var bullet_scene: PackedScene = preload("res://scenes/player/bullets/player-bullet.tscn")

func _on_player_bullet_fired(pos, dir, id):
	
	match id:
		
		# Normal Bullets
		Globals.Bullets.Normal:
			var bullet = bullet_scene.instantiate()
			bullet.position = pos
			bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
			bullet.direction = dir
			$Projectiles.add_child(bullet)
			
		# Ricochet Bullets (Special effect not yet implemented)
		Globals.Bullets.Ricochet:
			var bullet = bullet_scene.instantiate()
			bullet.position = pos
			bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
			bullet.direction = dir
			bullet.bullet_id = Globals.Bullets.Ricochet
			$Projectiles.add_child(bullet)
			
		# Shotgun Bullets 
		Globals.Bullets.Shotgun: 
			for i in range(5):
				var bullet = bullet_scene.instantiate()
				bullet.position = pos
				bullet.bullet_id = Globals.Bullets.Shotgun
				bullet.speed = 750
				var new_angle = dir.angle() + randf_range(-0.5, 0.5)
				bullet.rotation_degrees = rad_to_deg(new_angle) + 90
				bullet.direction = Vector2(cos(new_angle), sin(new_angle))
				$Projectiles.add_child(bullet)
			
	
