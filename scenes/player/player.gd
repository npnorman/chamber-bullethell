extends CharacterBody2D

var can_shoot: bool = true
var can_blank: bool = true
var mouse_ui_mode: bool = false
var is_invincible: bool = false
var is_dead: bool = false
var player_knockback: Vector2
var active_bullet_pos: int = 0
@export var can_reload: bool = true
@export var player_direction: Vector2
@export var speed: int = 150
@export var health: int = 6
@export var bullet_types: Array[int] = [0, -1, -1, -1]

var joy_stick_direction = Vector2.ZERO

# onready variables
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var gun_sprite: Sprite2D = $GunSprite
@onready var dice: Sprite2D = $Dice
@onready var shot_effects: AnimatedSprite2D = $GunSprite/ShotEffects
@onready var controller_crosshair: Sprite2D = $GunSprite/ControllerCrosshair

signal bullet_fired(pos: Vector2, direction: Vector2, id: int)
signal cylinder_cycled
signal toggle_inventory
signal update_health(new_health: int)
signal game_paused(death: bool)

func _ready() -> void:
	
	player_direction = Vector2.RIGHT
	
	if !Settings.isMouse:
		controller_crosshair.visible = true
	else:
		controller_crosshair.visible = false

func _process(_delta):
	if not is_dead:
		var movement_direction = Input.get_vector("Left", "Right", "Up", "Down")
		velocity = movement_direction * speed + player_knockback
		if player_knockback.length() > 0:
			player_knockback = player_knockback.move_toward(Vector2.ZERO, _delta * 10000)
		move_and_slide()
		rotate_gun()
		
		if Settings.isMouse:
			player_direction = (get_global_mouse_position() - position).normalized()
		else:
			#controller
			var last_direction = player_direction
			
			joy_stick_direction.x = Input.get_joy_axis(0,JOY_AXIS_RIGHT_X)
			joy_stick_direction.y = Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)
			
			joy_stick_direction = joy_stick_direction.normalized()
			
			player_direction = joy_stick_direction
			
			if player_direction == Vector2.ZERO:
				player_direction = Vector2.RIGHT
			
		if dice.visible == true:
			dice.position.y -= 25 * _delta
		
		if not mouse_ui_mode:
			# Shoot Input
			if Input.is_action_pressed("Shoot") and can_shoot:
				shoot()
			
			# Blank input, adds knockback for no bullet cost and has a 1.5 second cooldown
			if Input.is_action_pressed("Blank") and can_blank:
				blank()
			
			if Input.is_action_pressed("Unload") and can_reload:
				unload()
		
		# Normal reload and Special reload inputs
		if Input.is_action_just_pressed("Main Reload") and Globals.magazine[active_bullet_pos] == Globals.Bullets.Empty and Globals.ammo[0] > 0:
			reload(0)
		if Input.is_action_just_pressed("Special Reload 1") and Globals.magazine[active_bullet_pos] == Globals.Bullets.Empty and Globals.ammo[Globals.ammo_types[1]] > 0:
			reload(Globals.ammo_types[1])
		if Input.is_action_just_pressed("Special Reload 2") and Globals.magazine[active_bullet_pos] == Globals.Bullets.Empty and Globals.ammo[Globals.ammo_types[2]] > 0:
			reload(Globals.ammo_types[2])
		if Input.is_action_just_pressed("Special Reload 3") and Globals.magazine[active_bullet_pos] == Globals.Bullets.Empty and Globals.ammo[Globals.ammo_types[3]] > 0:
			reload(Globals.ammo_types[3])

		# Menu/Inventory
		if Input.is_action_just_pressed("Inventory"):
			toggle_inventory.emit()
			mouse_ui_mode = not mouse_ui_mode
		if Input.is_action_just_pressed("Menu"):
			game_paused.emit(false)
		
		# Animations
		if Input.is_action_pressed("Down"):
			animated_sprite_2d.play("walk")
		
		elif Input.is_action_pressed("Up"):
			animated_sprite_2d.play("walk")
			
		elif Input.is_action_pressed("Right"):
			animated_sprite_2d.play("walk")
			
		elif Input.is_action_pressed("Left"):
			animated_sprite_2d.play("walk")
		
		else:
			animated_sprite_2d.play("idle")

# This function will aim the revolver to where the mouse is and can rotate the 
# sprite vertically depending on which direction it is facing
func rotate_gun():
	
	if Settings.isMouse:
		gun_sprite.look_at(get_global_mouse_position())
	else:
		gun_sprite.rotation = joy_stick_direction.angle()
	
	var rounded_rotation: int = abs(gun_sprite.rotation_degrees)
	if (rounded_rotation % 360) > 90 and (rounded_rotation % 360) < 270:
		gun_sprite.flip_v = true
	else:
		gun_sprite.flip_v = false

# Starts shot cooldown, sends shoot signal to level manager, rotates cylinder, updates magazine
func shoot():
	can_shoot = false
	if Globals.magazine[active_bullet_pos] >= 0:
		if gun_sprite.flip_v:
			bullet_fired.emit($GunSprite/BulletOrigin2.global_position, player_direction, Globals.magazine[active_bullet_pos])
			shot_effects.position = Vector2(17, 4)
			#animations.play("Flash2")
		else:
			bullet_fired.emit($GunSprite/BulletOrigin1.global_position, player_direction, Globals.magazine[active_bullet_pos])
			shot_effects.position = Vector2(17, -4)
			#animations.play("Flash1")
		shot_effects.play("shoot")
		add_shot_knockback(Globals.magazine[active_bullet_pos])
		if Globals.magazine[active_bullet_pos] != Globals.Bullets.Railgun:
			SfxPlayer.player_shot_sound()
		else:
			SfxPlayer.railgun_sound()
		Globals.magazine[active_bullet_pos] = Globals.Bullets.Empty
		if $ShootCooldown.wait_time < 0.33:
			$ShootCooldown.wait_time = 0.33
	else:
		$ShootCooldown.wait_time = 0.15
	$ShootCooldown.start()
	can_reload = false
	cycle_cylinder()

# Loads in a normal or special bullet depending on what button was pressed to call this method
func reload(id: int):
	if can_reload and id != -1:
		Globals.magazine[active_bullet_pos] = id
		Globals.ammo[id] -= 1
		if Globals.ammo[id] < 1:
			get_tree().current_scene.update_hud()
		can_reload = false
		cycle_cylinder()

# Removes current round and adds it back to your inventory if you have it in a slot
func unload():
	var active_id = Globals.magazine[active_bullet_pos]
	var first_empty_slot = Globals.ammo_types.find(-1)
	var in_inventory: bool = false
	if Globals.ammo_types.find(active_id) != -1:
		in_inventory = true
	if active_id != -1:
		Globals.ammo[active_id] += 1
	Globals.magazine[active_bullet_pos] = Globals.Bullets.Empty
	if first_empty_slot != -1 and in_inventory == false:
		Globals.ammo_types[first_empty_slot] = active_id
		get_tree().current_scene.update_hud()
	can_reload = false
	cycle_cylinder()

# Moves every bullet in the cyclinder to the left (or right) once
func cycle_cylinder():
	if active_bullet_pos < 5:
		active_bullet_pos += 1
	else:
		active_bullet_pos = 0
	cylinder_cycled.emit()

# Moves player back and plays blank animation at the gun's barrel
func blank():
	add_shot_knockback(Globals.Bullets.Shotgun, 1500)
	if gun_sprite.flip_v:
		shot_effects.position = Vector2(17, 4)
	else:
		shot_effects.position = Vector2(17, -4)
	shot_effects.play("blank")
	SfxPlayer.blank_sound()
	can_blank = false
	$BlankCooldown.start()
		
# Prints the name of the bullet type corresponding to the given ID
func print_bullet_name(id: int):
	print(Globals.Bullets.find_key(id))

# Adds knockback to player from shooting. Can be reworked later to change for different bullets
func add_shot_knockback(bullet_id: int = 0, knockback_amount = 750):
	if bullet_id == Globals.Bullets.Shotgun:
		player_knockback = (player_direction * -1) * knockback_amount

# Takes 1 health from the player, currently starts with 6 total
func take_damage(damage):
	if not is_invincible and not is_dead:
		health -= damage
		update_health.emit(health)
		if health <= 0:
			player_die()
		else:
			is_invincible = true
			SfxPlayer.player_damage_sound()
			$IFrames.start()
			animations.play("damage")

# Stops player from moving and plays death animation
func player_die():
	is_dead = true
	animations.play("death")

# Function call specifically for the health bullet, can also be used for other healing sources
func heal():
	var old_health = health
	health += 4
	if health > 10:
		health = 10
	SfxPlayer.heal_sound()
	update_health.emit(health)
	animations.play("heal")

# Temporarily displays a die sprite over the player showing what their gambler round roll was
func roll_die(roll: int) -> void:
	var dice_atlas: AtlasTexture = dice.texture
	dice.position = Vector2(0, -35)
	dice.get_child(0).visible = false
	match roll:
		1:
			dice_atlas.region = Rect2(0,0,16,16)
		2:
			dice_atlas.region = Rect2(16,0,16,16)
		3:
			dice_atlas.region = Rect2(0,16,16,16)
		4:
			dice_atlas.region = Rect2(16,16,16,16)
		5:
			dice_atlas.region = Rect2(0,32,16,16)
		6:
			dice_atlas.region = Rect2(16,32,16,16)
			dice.get_child(0).visible = true
	dice.visible = true
	$DiceTimer.start()
	
# Cooldown between shots
func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true

# Invincibility timer after taking damage
func _on_i_frames_timeout() -> void:
	is_invincible = false

# Cooldown between blanks
func _on_blank_cooldown_timeout() -> void:
	can_blank = true

func _on_dice_timer_timeout() -> void:
	dice.visible = false
	dice.get_child(0).visible = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		game_paused.emit(true)
