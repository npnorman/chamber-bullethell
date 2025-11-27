extends Node2D
class_name LevelContainer

@export var bullet_scene: PackedScene
@export var bullet_pickup_scene: PackedScene 

@export var bullet_fairy:PackedScene

# boss room
@export var boss_room:Node2D

@onready var hud: CanvasLayer = $HUD
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var player: CharacterBody2D = $Player
@onready var enemies: Node = $Enemies
@onready var pickups: Node = $Pickups
@onready var chests: Node = $Chests
@onready var projectiles: Node = $Projectiles
@onready var bullet_fairy_timer: Timer = $BulletFairyTimer
@onready var camera: Camera2D = $Camera2D
@onready var mini_map: CanvasLayer = $MiniMap
@onready var enemy_count: RichTextLabel = $HUD/EnemyCount

var is_bullet_fairy_spawned = false
var current_room = null
var room_change_delta: float = Globals.tile_size * 16
var is_walls_ready = false
var is_hud_transparent: bool = false

func _ready() -> void:
	camera.zoom = Vector2.ONE * 1.37
	#TESTING
	spawn_player_in_boss_room()

func _process(delta: float) -> void:
	
	# check number of enemeies
	check_number_of_enemies()
	
	check_for_bullet_fairy_spawn()
	
	var previous_center_room = Globals.current_room_center
	update_center_room()
	
	#in a new room
	if  Globals.current_room_center != previous_center_room:
		
		#add to minimap
		mini_map.add_room_as_mini(Globals.current_room_center, current_room.special)
		mini_map.set_player_location(Globals.current_room_center)
		
		#set up walls
		if current_room != null:
			is_walls_ready = true
	
	if is_walls_ready:
		if Globals.current_room_center.distance_to(player.global_position) < room_change_delta:
			is_walls_ready = false
			current_room.set_walls()
	
	update_camera_position()
	
	# Make hud see-through if mouse is low enough
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.y > 400 and not is_hud_transparent:
		hud.toggle_transparency(true)
		is_hud_transparent = true
	elif mouse_pos.y < 400 and is_hud_transparent:
		hud.toggle_transparency(false)
		is_hud_transparent = false

func check_number_of_enemies():
	var numEnemies = len(get_tree().get_nodes_in_group("Enemy"))
	var enemyDelta = 20
	
	# get label
	# label shows: Enemies to kill = len - 5, clamp at 0
	enemy_count.text = "Unlock Boss In: " + str( maxi(numEnemies - enemyDelta, 0) )
	
	# if enemy count is <= 5
	if numEnemies <= enemyDelta:
		#unlock boss room
		Globals.isBossTPUnlocked = true

func check_for_bullet_fairy_spawn():
	var total_bullets = Globals.ammo.reduce(func(a,b): return a+b)

	if total_bullets <= 0:
		if is_bullet_fairy_spawned == false:
			is_bullet_fairy_spawned = true
			bullet_fairy_timer.start()
	else:
		is_bullet_fairy_spawned = false

var room_radius = Globals.tile_size * Globals.room_size / 2

func update_center_room():
	var rooms = get_tree().get_nodes_in_group("Rooms")
	
	var temp_distance = 10000000000
	var temp_room = null
	var temp_closest_room = Vector2.ZERO
	# for each room, get center
	for room in rooms:
		# save closest room
		var center = Vector2(room.global_position.x + room_radius,room.global_position.y - room_radius)
		
		var player_temp_distance = center.distance_to(player.global_position)
		if  player_temp_distance < temp_distance:
			#new closest
			temp_distance = player_temp_distance
			temp_closest_room = center
			temp_room = room
			# save as var
	Globals.current_room_center = temp_closest_room
	current_room = temp_room
	
	if current_room.special == Globals.Special.BOSS:
		#make camera different
		Globals.current_room_center = Vector2(current_room.global_position.x + room_radius * 2, current_room.global_position.y - room_radius * 2)

func update_camera_position():
	# set the camera position to the room the player is in
	camera.position = Globals.current_room_center

func update_hud():
	hud.set_ammo_types()
	hud.update_counters()

# Adjust HUD when cylinder changes
func _on_player_cylinder_cycled() -> void:
	hud.start_rotating()
	hud.update_chamber_textures()
	hud.update_counters()

# Allow player to reload again once cylinder is done spinning
func _on_hud_rotation_completed() -> void:
	player.can_reload = true
	SfxPlayer.cylinder_click_sound()

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
		Globals.ammo_types[slot] = bullet_id
		hud.set_ammo_types()
	hud.update_counters()

func _on_player_toggle_inventory() -> void:
	hud.display_inventory()

func _on_player_bullet_fired(pos, dir, id):
	
	match id:
		
		Globals.Bullets.Normal:
			var bullet = bullet_scene.instantiate()
			bullet.position = pos
			bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
			bullet.direction = dir
			projectiles.add_child(bullet)
			
		Globals.Bullets.Ricochet:
			var bullet = bullet_scene.instantiate()
			bullet.position = pos
			bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
			bullet.direction = dir
			bullet.ricochets = 1
			bullet.bullet_id = Globals.Bullets.Ricochet
			projectiles.add_child(bullet)
			
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
		
		#TODO: Add explosive functionality to this bullet
		Globals.Bullets.Explosive:
			var bullet = bullet_scene.instantiate()
			bullet.position = pos
			bullet.damage = 4
			bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
			bullet.direction = dir
			bullet.explosive = true
			projectiles.add_child(bullet)
		
		Globals.Bullets.Health:
			player.heal()
		
		#TODO: Add railgun functionality to this bullet
		Globals.Bullets.Railgun:
			var bullet = bullet_scene.instantiate()
			bullet.bullet_id = Globals.Bullets.Railgun
			bullet.position = pos
			bullet.damage = 10
			bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
			bullet.direction = dir
			projectiles.add_child(bullet)
		
		Globals.Bullets.Gambler:
			var dice_roll = randi_range(1, 6)
			var bullet = bullet_scene.instantiate()
			match dice_roll:
				1:
					bullet.damage = -1
				2:
					bullet.damage = 2
				3:
					bullet.damage = 6
				4:
					bullet.damage = 12
				5:
					bullet.damage = 20
				6:
					bullet.damage = 50
			bullet.position = pos
			bullet.rotation_degrees = rad_to_deg(dir.angle()) + 90
			bullet.direction = dir
			player.roll_die(dice_roll)
			projectiles.add_child(bullet)

func spawn_player_in_boss_room():
	player.position = boss_room.position + Vector2(Globals.tile_size * Globals.room_size, Globals.tile_size * -10)
	mini_map.visible = false
	camera.zoom = Vector2.ONE * 0.69

func _on_bullet_fairy_timer_timeout() -> void:
	#spawn bullet fairy
	var temp_bullet_fairy = bullet_fairy.instantiate()
	temp_bullet_fairy.starting_position = Globals.current_room_center
	temp_bullet_fairy.global_position = Vector2.ZERO
	add_child(temp_bullet_fairy)

func _on_player_update_health(new_health: int) -> void:
	hud.update_health(new_health)

func _on_pause_menu_game_resumed() -> void:
	pause_menu.visible = false
	get_tree().paused = false

func _on_player_game_paused(death: bool) -> void:
	if death:
		pause_menu.on_death()
	else:
		pause_menu.on_pause()
	pause_menu.visible = true
	get_tree().paused = true
