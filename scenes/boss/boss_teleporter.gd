extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skull_animation_player: AnimationPlayer = $SkullAnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var locked_barrier: CollisionPolygon2D = $LockedBarrier/CollisionPolygon2D

var locked = true

func _ready() -> void:
	animated_sprite_2d.play("eyes")
	animation_player.play("locked")

func _process(delta: float) -> void:
	if locked and Globals.isBossTPUnlocked:
		locked = false
		unlock()

func unlock():
	animated_sprite_2d.play("skull")
	skull_animation_player.play("skull")
	locked_barrier.disabled = true
	locked = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if locked == false:
		get_parent().get_parent().get_parent().get_parent().spawn_player_in_boss_room()
