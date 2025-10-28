extends Area2D

var moving_up: bool = true
@export var active_texture: int = 0
@export var bullet_id: int
@export var amount: int
@export var pickup_textures: Array[Resource]
@onready var sprite: Sprite2D = $Sprite2D

signal ammo_changed(new_ammo_type: bool, slot: int, bullet_id: int)

func _ready() -> void:
	sprite.texture = pickup_textures[active_texture]

# When entering the area, gives ammo to correspond type if you have it already. If you don't and
# have an open slot, fills the slot with the new ammo type. Otherwise, does nothing
func _on_body_entered(body: Node2D) -> void:
	if Globals.ammo_types.has(bullet_id):
		var pickup_check: bool = increase_ammo()
		if pickup_check:
			ammo_changed.emit(false, 0, 0)
			queue_free()
	elif Globals.ammo_types.has(-1):
		var empty_slot: int
		empty_slot = Globals.ammo_types.find(-1)
		Globals.ammo_types[empty_slot] = bullet_id
		Globals.ammo[bullet_id] += amount
		ammo_changed.emit(true, empty_slot, bullet_id)
		queue_free()

# Adds pickup amount to the contained ammo type in the Global script
func increase_ammo() -> bool:
	if (Globals.ammo[bullet_id] + amount) == Globals.ammo_max[bullet_id]:
		return false
	if (Globals.ammo[bullet_id] + amount) <= Globals.ammo_max[bullet_id]:
		Globals.ammo[bullet_id] = Globals.ammo[bullet_id] + amount
		return true
	else: Globals.ammo[bullet_id] = Globals.ammo_max[bullet_id]
	return true

# Sprite will bob up and down, I tried doing a tween for this and couldn't get it to work
func _process(_delta):
	if moving_up:
		$Sprite2D.position.y += 5 * _delta
		if $Sprite2D.position.y >= 5:
			moving_up = false
	else:
		$Sprite2D.position.y -= 5 * _delta
		if $Sprite2D.position.y <= -5:
			moving_up = true
