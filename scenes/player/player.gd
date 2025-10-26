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

# onready variables
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var gun_sprite: Sprite2D = $GunSprite
@onready var dice: Sprite2D = $Dice

signal bullet_fired(pos: Vector2, direction: Vector2, id: int)
signal cylinder_cycled
signal toggle_inventory
signal update_health(new_health: int)
signal game_paused(death: bool)

func _process(_delta):
	if not is_dead:
		var movement_direction = Input.get_vector("Left", "Right", "Up", "Down")
		velocity = movement_direction * speed + player_knockback
		if player_knockback.length() > 0:
			player_knockback = player_knockback.move_toward(Vector2.ZERO, _delta * 10000)
		move_and_slide()
		rotate_gun()
		player_direction = (get_global_mouse_position() - position).normalized()
		
		if dice.visible == true:
			dice.position.y -= 25 * _delta
		
		if not mouse_ui_mode:
			# Shoot Input
			if Input.is_action_pressed("Shoot") and can_shoot:
				shoot()
			
			# Blank input, adds knockback for no bullet cost and has a 1.5 second cooldown
			if Input.is_action_pressed("Blank") and can_blank:
				add_shot_knockback(Globals.Bullets.Shotgun, 1500)
				can_blank = false
				$BlankCooldown.start()
		
		# Normal reload and Special reload inputs
		if Input.is_action_just_pressed("Main Reload") and Globals.magazine[active_bullet_pos] == Globals.Bullets.Empty and Globals.ammo[0] > 0:
			reload(0)
		if Input.is_action_just_pressed("Special Reload 1") and Globals.magazine[active_bullet_pos] == Globals.Bullets.Empty and Globals.ammo[bullet_types[1]] > 0:
			reload(bullet_types[1])
		if Input.is_action_just_pressed("Special Reload 2") and Globals.magazine[active_bullet_pos] == Globals.Bullets.Empty and Globals.ammo[bullet_types[2]] > 0:
			reload(bullet_types[2])
		if Input.is_action_just_pressed("Special Reload 3") and Globals.magazine[active_bullet_pos] == Globals.Bullets.Empty and Globals.ammo[bullet_types[3]] > 0:
			reload(bullet_types[3])
			
		
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
	gun_sprite.look_at(get_global_mouse_position())
	var rounded_rotation: int = abs(gun_sprite.rotation_degrees)
	if (rounded_rotation % 360) > 90 and (rounded_rotation % 360) < 270:
		gun_sprite.flip_v = true
	else:
		gun_sprite.flip_v = false

# Starts shot cooldown, sends shoot signal to level manager, rotates cylinder, updates magazine
func shoot():
	can_shoot = false
	$ShootCooldown.start()
	if Globals.magazine[active_bullet_pos] >= 0:
		if gun_sprite.flip_v:
			bullet_fired.emit($GunSprite/BulletOrigin2.global_position, player_direction, Globals.magazine[active_bullet_pos])
		else:
			bullet_fired.emit($GunSprite/BulletOrigin1.global_position, player_direction, Globals.magazine[active_bullet_pos])
		add_shot_knockback(Globals.magazine[active_bullet_pos])
		SfxPlayer.player_shot_sound()
		Globals.magazine[active_bullet_pos] = Globals.Bullets.Empty
	can_reload = false
	cycle_cylinder()

# Loads in a normal or special bullet depending on what button was pressed to call this method
func reload(id: int):
	if can_reload and id != -1:
		Globals.magazine[active_bullet_pos] = id
		Globals.ammo[id] -= 1
		can_reload = false
		cycle_cylinder()

# Moves every bullet in the cyclinder to the left (or right) once
func cycle_cylinder():
	if active_bullet_pos < 5:
		active_bullet_pos += 1
	else:
		active_bullet_pos = 0
	cylinder_cycled.emit()
		
# Prints the name of the bullet type corresponding to the given ID
func print_bullet_name(id: int):
	print(Globals.Bullets.find_key(id))

# Adds knockback to player from shooting. Can be reworked later to change for different bullets
func add_shot_knockback(bullet_id: int = 0, knockback_amount = 750):
	if bullet_id == Globals.Bullets.Shotgun:
		player_knockback = (player_direction * -1) * knockback_amount

# Updates Global script ammo type array to match what the Player has
func update_bullet_types():
	Globals.ammo_types[1] = bullet_types[1]
	Globals.ammo_types[2] = bullet_types[2]
	Globals.ammo_types[3] = bullet_types[3]

# Takes 1 health from the player, currently starts with 6 total
func take_damage(damage):
	if not is_invincible and not is_dead:
		health -= damage
		update_health.emit(health)
		if health == 0:
			player_die()
		else:
			is_invincible = true
			$IFrames.start()
			animations.play("damage")

# Stops player from moving and plays death animation
func player_die():
	is_dead = true
	animations.play("death")

func heal():
	health += 1
	update_health.emit(health)
	animations.play("heal")
	
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
