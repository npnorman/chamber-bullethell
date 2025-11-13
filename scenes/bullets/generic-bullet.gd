extends Area2D
class_name Bullet

@export var speed: int = 1000
@export var damage: int = 4
@export var bullet_id: int = 0
@export var ricochets: int = 0
var direction: Vector2 = Vector2.UP
var collision_normal: Vector2
var collision_point: Vector2
var distance_to_point: Vector2
var can_collide: bool = true
var found_angle: bool = false

@onready var raycast: RayCast2D = $RayCast2D
@onready var despawn_timer: Timer = $DespawnTimer

func _ready():
	$DespawnTimer.start()
	
func _process(delta):
	var velocity: Vector2 = direction * speed * delta
	position += velocity
	raycast.target_position.y = (velocity.length() * -1) * 2
	if raycast.is_colliding() and not found_angle:
		collision_normal = raycast.get_collision_normal()
		collision_point = raycast.get_collision_point()
		found_angle = true
	if raycast.is_colliding():
		if ricochets == 0:
			speed = 0
			self.position = collision_point
	
func _on_despawn_timer_timeout() -> void:
	self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if can_collide:
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			
			self.queue_free()
			
		elif body.is_in_group("Player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				
			self.queue_free()
			
		elif ricochets > 0:
			self.position = collision_point
			self.direction = self.direction.bounce(collision_normal).normalized()
			self.rotation_degrees = rad_to_deg(self.direction.angle()) + 90
			ricochets -= 1
			if bullet_id == Globals.Bullets.Ricochet:
				damage *= 2
			can_collide = false
			found_angle = false
			$CollisionTimer.start()
		else:
			self.queue_free()

func _on_collision_timer_timeout() -> void:
	can_collide = true

func set_despawn_timer(seconds:float):
	despawn_timer.wait_time = seconds
	despawn_timer.start()
