extends Area2D

@export var speed: int = 1000
var direction: Vector2 = Vector2.UP

func _ready():
	$DespawnTimer.start()
	
func _process(delta):
	position += direction * speed * delta

func _on_despawn_timer_timeout() -> void:
	queue_free()
