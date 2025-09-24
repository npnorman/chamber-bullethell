extends Area2D

@export var speed: int = 1000
@export var damage: int = 1
@export var bullet_id: int = 0
@export var ricochets: int = 0
var direction: Vector2 = Vector2.UP
var collision_normal: Vector2
var can_collide: bool = true

@onready var raycast: RayCast2D = $RayCast2D

func _ready():
	$DespawnTimer.start()
	
func _process(delta):
	position += direction * speed * delta
	if raycast.is_colliding():
		collision_normal = raycast.get_collision_normal()

func _on_despawn_timer_timeout() -> void:
	self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if can_collide:
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			
			self.queue_free()
			
		elif body.is_in_group("Player"):
			print("Enemy Hit Player")
			if body.has_method("take_damage"):
				body.take_damage(damage)
				
			self.queue_free()
			
		elif ricochets > 0:
			self.direction = direction.bounce(collision_normal).normalized()
			self.rotation_degrees = rad_to_deg(self.direction.angle()) + 90
			ricochets -= 1
			can_collide = false
			$CollisionTimer.start()
		else:
			self.queue_free()

func _on_collision_timer_timeout() -> void:
	can_collide = true
