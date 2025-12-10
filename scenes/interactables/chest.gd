extends Area2D

var opened: bool = false
@export var bullet_id: = Globals.Bullets.Normal
@export var bullet_amount : int = 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: CPUParticles2D = $CPUParticles2D

signal chest_opened(bullet_id: int, chest_position: Vector2)

func _ready() -> void:
	var rand_bullet = randi_range(1, 6)
	if bullet_id == 0:
		bullet_id = rand_bullet
	sprite.play("default")
	
	if bullet_amount == 0:
		bullet_amount = Globals.ammo_shop_amount[bullet_id]

func _on_body_entered(body: Node2D) -> void:
	if not opened:
		sprite.play("opening")
		SfxPlayer.chest_open_sound()
		particles.emitting = true
		var pickup_position: Vector2 = global_position + Vector2(0, 10)
		get_tree().current_scene.spawn_pickup(bullet_id, bullet_amount, pickup_position)
		opened = true
