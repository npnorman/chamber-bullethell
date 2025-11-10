extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	anim.play("default")
