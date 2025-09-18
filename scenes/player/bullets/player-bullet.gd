extends Area2D

@export var speed: int = 1500
@export var damage: int = 1
@export var bullet_id: int = 0
var direction: Vector2 = Vector2.UP

func _ready():
	$DespawnTimer.start()
	
func _process(delta):
	position += direction * speed * delta

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		
		self.queue_free()
