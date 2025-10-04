extends Area2D

@export var bullet_id: int
@export var amount: int
var has_ammo: bool = true
var moving_up: bool = true

signal ammo_changed

func _on_body_entered(body: Node2D) -> void:
	if Globals.ammo_types.has(bullet_id):
		if has_ammo:
			increase_ammo()
			has_ammo = false
		ammo_changed.emit()
		queue_free()

func increase_ammo():
	if (Globals.ammo[bullet_id] + amount) <= Globals.ammo_max[bullet_id]:
		Globals.ammo[bullet_id] = Globals.ammo[bullet_id] + amount
	else: Globals.ammo[bullet_id] = Globals.ammo_max[bullet_id]

func _process(_delta):
	if moving_up:
		$Sprite2D.position.y += 5 * _delta
		if $Sprite2D.position.y >= 5:
			moving_up = false
	else:
		$Sprite2D.position.y -= 5 * _delta
		if $Sprite2D.position.y <= -5:
			moving_up = true
