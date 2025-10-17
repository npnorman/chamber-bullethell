extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_started = false

func _ready() -> void:
	#start start animation
	animated_sprite_2d.play("start")
	is_started = true
	#followed by default

func put_out():
	animation_player.play("put_out")

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_started:
		is_started = false
		animated_sprite_2d.play("default")
