extends CharacterBody2D

@export var speed: int = 1000
@export var damage: int = 4
@export var bullet_id: int = 1
@export var ricochets: int = 5
var direction: Vector2 = Vector2.UP

@onready var despawn_timer: Timer = $DespawnTimer

func _ready():
	$DespawnTimer.start()

func _physics_process(delta):
	velocity = speed * direction
	var collision_check = move_and_slide()
	
	for i in get_slide_collision_count():
		var collider: KinematicCollision2D = get_slide_collision(i)
		var collision_normal: Vector2 = collider.get_normal()
		if ricochets >= 1:
			var reflected_direction: Vector2 = velocity.bounce(collision_normal).normalized()
			direction = reflected_direction
			self.rotation_degrees = rad_to_deg(reflected_direction.angle()) + 90
			damage *= 2
			ricochets -= 1
		else:
			queue_free()
		break
	
func _on_despawn_timer_timeout() -> void:
	self.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
