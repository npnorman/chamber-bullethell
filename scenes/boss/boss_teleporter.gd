extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var locked = true

func _ready() -> void:
	animated_sprite_2d.play("skull")
	animation_player.play("locked")

func unlock():
	animated_sprite_2d.play("skull")
	locked = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Entered Boss Zone, Locked: ", locked)
