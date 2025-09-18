extends Area2D

@export var speed: int = 1500
@export var bullet_id: int = 0
var direction: Vector2 = Vector2.UP

func _ready():
	$DespawnTimer.start()
	
func _process(delta):
	position += direction * speed * delta

func _on_despawn_timer_timeout() -> void:
	queue_free()
