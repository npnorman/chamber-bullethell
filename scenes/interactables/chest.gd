extends Area2D

var opened: bool = false
@export var bullet_id: int

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal chest_opened(bullet_id: int, chest_position: Vector2)

func _ready() -> void:
	sprite.play("default")

func _on_body_entered(body: Node2D) -> void:
	if not opened:
		sprite.play("opening")
		get_tree().current_scene.spawn_pickup(bullet_id, Globals.ammo_max[bullet_id], global_position)
		opened = true
