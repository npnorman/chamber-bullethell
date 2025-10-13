extends Node2D
class_name LevelContainer

var bullet_scene: PackedScene = preload("res://scenes/player/bullets/player-bullet.tscn")
var bullet_pickup_scene: PackedScene = preload("res://scenes/bullet_pickup.tscn")

# Connects signals for testing, will work differently in the future
func _ready():
	for enemy: CharacterBody2D in $Enemies.get_children():
		enemy.killed.connect(_on_enemy_killed)
	for chest: Area2D in $Chests.get_children():
		chest.chest_opened.connect(_on_chest_opened)

# Adjust HUD when cylinder changes
func _on_player_cylinder_cycled() -> void:
	$HUD.start_rotating()
	$HUD.update_chamber_textures()
	$HUD.update_counters()

# Allow player to reload again once cylinder is done spinning
func _on_hud_rotation_completed() -> void:
	$Player.can_reload = true
	SfxPlayer.cylinder_click_sound()

# When an enemy dies, spawn an ammo pickup at their location
func _on_enemy_killed(enemy_position: Vector2, ammo_dropped: int) -> void:
	var bullet_pickup: Area2D = bullet_pickup_scene.instantiate()
	bullet_pickup.global_position = enemy_position
	bullet_pickup.amount = ammo_dropped
	bullet_pickup.ammo_changed.connect(_on_bullet_pickup_ammo_changed)
	$Pickups.add_child(bullet_pickup)

func _on_chest_opened(bullet_id: int, chest_position: Vector2):
	var bullet_pickup: Area2D = bullet_pickup_scene.instantiate()
	bullet_pickup.global_position = chest_position + Vector2(0, 8)
	bullet_pickup.bullet_id = bullet_id
	bullet_pickup.amount = Globals.ammo_max[bullet_id]
	bullet_pickup.ammo_changed.connect(_on_bullet_pickup_ammo_changed)
	#TODO: Get rid of the below code and have bullet pickup sprite depend on rarity
	if bullet_id == 1:
		bullet_pickup.modulate = Color(0, 0.5, 1, 1)
	elif bullet_id == 2:
		bullet_pickup.modulate = Color(1, 0, 0, 1)
	$Pickups.add_child(bullet_pickup)
		
# Updates HUD when ammo is picked up
func _on_bullet_pickup_ammo_changed(new_ammo_type: bool, slot: int, bullet_id: int) -> void:
	if new_ammo_type:
		$Player.bullet_types[slot] = bullet_id
		$Player.update_bullet_types()
		$HUD.set_ammo_types()
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
			
	
