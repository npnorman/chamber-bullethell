extends Area2D

@export var speed: int = 1500
@export var damage: int = 1
@export var bullet_id: int = 0
@export var ricochets: int = 0
var isEnemyBullet:bool = false
var direction: Vector2 = Vector2.UP

func _ready():
	$DespawnTimer.start()
	
func _process(delta):
	position += direction * speed * delta

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and !isEnemyBullet:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		self.queue_free()
		
	if body.is_in_group("Player") and isEnemyBullet:
		print("Enemy Hit Player")
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		self.queue_free()
		
	if ricochets > 0:
		ricochets -= 1
	else:
		queue_free()
