extends Node2D
class_name LevelContainer

var bullet_scene: PackedScene = preload("res://scenes/player/bullets/player-bullet.tscn")
var bullet_pickup_scene: PackedScene = preload("res://scenes/bullet_pickup.tscn")

func _ready():
	for enemy: CharacterBody2D in $Enemies.get_children():
		enemy.killed.connect(_on_enemy_killed)
	$Pickups/BulletPickup.ammo_changed.connect(_on_bullet_pickup_ammo_changed)

# Adjust HUD when cylinder changes
func _on_player_cylinder_cycled() -> void:
	$HUD.start_rotating()
	$HUD.update_chamber_textures()
	$HUD.update_counters()

# Allow player to reload again once cylinder is done spinning
func _on_hud_rotation_completed() -> void:
	$Player.can_reload = true

func _on_enemy_killed(enemy_position: Vector2, ammo_dropped: int) -> void:
	var bullet_pickup: Area2D = bullet_pickup_scene.instantiate()
	bullet_pickup.global_position = enemy_position
	bullet_pickup.amount = ammo_dropped
	bullet_pickup.ammo_changed.connect(_on_bullet_pickup_ammo_changed)
	$Pickups.add_child(bullet_pickup)
		

func _on_bullet_pickup_ammo_changed() -> void:
	$HUD.update_counters()

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
			bullet.ricochets = 1
			bullet.bullet_id = Globals.Bullets.Ricochet
			$Projectiles.add_child(bullet)
			
		# Shotgun Bullets 
		Globals.Bullets.Shotgun: 
			for i in range(6):
				var bullet = bullet_scene.instantiate()
				bullet.position = pos
				bullet.bullet_id = Globals.Bullets.Shotgun
				bullet.speed = 750
				bullet.damage = 3
				var new_angle = dir.angle() + randf_range(-0.4, 0.4)
				bullet.rotation_degrees = rad_to_deg(new_angle) + 90
				bullet.direction = Vector2(cos(new_angle), sin(new_angle))
				$Projectiles.add_child(bullet)
			
	
