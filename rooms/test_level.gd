extends Node2D
class_name LevelContainer

var bullet_scene: PackedScene = preload("res://scenes/player/bullets/player-bullet.tscn")
var bullet_pickup_scene: PackedScene = preload("res://scenes/bullet_pickup.tscn")
@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var enemies: Node = $Enemies
@onready var pickups: Node = $Pickups
@onready var chests: Node = $Chests
@onready var projectiles: Node = $Projectiles


# Connects signals for testing, will work differently in the future
func _ready():
	for enemy: CharacterBody2D in enemies.get_children():
		enemy.killed.connect(_on_enemy_killed)
	for chest: Area2D in chests.get_children():
		chest.chest_opened.connect(_on_chest_opened)

# Adjust HUD when cylinder changes
func _on_player_cylinder_cycled() -> void:
	hud.start_rotating()
	hud.update_chamber_textures()
	hud.update_counters()

# Allow player to reload again once cylinder is done spinning
func _on_hud_rotation_completed() -> void:
	player.can_reload = true
	SfxPlayer.cylinder_click_sound()

# When an enemy dies, spawn an ammo pickup at their location
func _on_enemy_killed(enemy_position: Vector2, ammo_dropped: int) -> void:
	spawn_pickup(0, ammo_dropped, enemy_position)

# When a chest is opened, spawn a pickup at its location of the contained type
func _on_chest_opened(bullet_id: int, chest_position: Vector2):
	spawn_pickup(bullet_id, Globals.ammo_max[bullet_id], chest_position)

# When an ammo type in the inventory is trashed, a pickup is dropped near the player
func _on_hud_ammo_dropped(bullet_id: int, amount: int) -> void:
	spawn_pickup(bullet_id, amount, (player.global_position - Vector2(50, -25)))

# General pickup spawning function that can be called through a signal or directly by a child node
func spawn_pickup(bullet_id: int, amount: int, pickup_position: Vector2) -> void:
	var bullet_pickup: Area2D = bullet_pickup_scene.instantiate()
	bullet_pickup.global_position = pickup_position
	bullet_pickup.bullet_id = bullet_id
	bullet_pickup.amount = amount
	bullet_pickup.active_texture = Globals.ammo_rarities[bullet_id]
	bullet_pickup.ammo_changed.connect(_on_bullet_pickup_ammo_changed)
	pickups.add_child(bullet_pickup)

# Updates HUD when ammo is picked up
func _on_bullet_pickup_ammo_changed(new_ammo_type: bool, slot: int, bullet_id: int) -> void:
	if new_ammo_type:
		player.bullet_types[slot] = bullet_id
		player.update_bullet_types()
		hud.set_ammo_types()
	hud.update_counters()

func _on_player_bullet_fired(pos, dir, id):
	
	match id:
		
		# Normal Bullets
		Globals.Bullets.Normal:
			var bullet = bullet_scene.instantiate()
			bullet.position = pos
			bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
			bullet.direction = dir
			projectiles.add_child(bullet)
			
		# Ricochet Bullets (Special effect not yet implemented)
		Globals.Bullets.Ricochet:
			var bullet = bullet_scene.instantiate()
			bullet.position = pos
			bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
			bullet.direction = dir
			bullet.ricochets = 1
			bullet.bullet_id = Globals.Bullets.Ricochet
			projectiles.add_child(bullet)
			
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
				projectiles.add_child(bullet)
			
	
func _on_player_toggle_inventory() -> void:
	hud.display_inventory()
