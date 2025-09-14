extends CharacterBody2D

var can_shoot: bool = true
var player_direction: Vector2
var speed: int = 150

signal bullet_fired(pos: Vector2, direction)

func _process(_delta):
	var movement_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = movement_direction * speed
	move_and_slide()
	rotate_gun()
	player_direction = (get_global_mouse_position() - position).normalized()
	if Input.is_action_pressed("Shoot") and can_shoot and Globals.ammo > 0:
		shoot()

# This function will aim the revolver to where the mouse is and can rotate the 
# sprite vertically depending on which direction it is facing
func rotate_gun():
	$GunSprite.look_at(get_global_mouse_position())
	var rounded_rotation: int = abs($GunSprite.rotation_degrees)
	if (rounded_rotation % 360) > 90 and (rounded_rotation % 360) < 270:
		$GunSprite.flip_v = true
	else:
		$GunSprite.flip_v = false

# Reduces ammo counter, starts cooldown, and sends shoot signal
func shoot():
	Globals.ammo -= 1
	can_shoot = false
	$ShootCooldown.start()
	if $GunSprite.flip_v:
		bullet_fired.emit($GunSprite/BulletOrigin2.global_position, player_direction)
	else:
		bullet_fired.emit($GunSprite/BulletOrigin1.global_position, player_direction)

# Cooldown between shots
func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true
