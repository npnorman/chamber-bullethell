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
		chest_opened.emit(bullet_id, self.global_position)
		opened = true
