extends "res://scripts/enemy.gd"

var counter: int = 0
var angle_variation: int = 0
@onready var count_timer: Timer = $CountTimer

func _ready() -> void:
	count_timer.start()

func _physics_process(delta: float) -> void:
	pass

func _on_count_timer_timeout() -> void:
	if is_active:
		counter += 1
		count_timer.start()

func enemy_die():
	super.enemy_die()
	count_timer.stop()
	spawn_bullets(counter)
	
func spawn_bullets(counter: int):
	print(counter)
	
	var index = 0
	var full_stacks: int = counter / 3
	var remainder_stacks = counter % 3
	var ring_one_count: int = (full_stacks * 4) + (4 if (remainder_stacks > 0) else 0)
	var ring_two_count: int = (full_stacks * 4) + (4 if (remainder_stacks > 1) else 0)
	var ring_three_count: int = (full_stacks * 4) + (4 if (remainder_stacks > 2) else 0)
	var ring_counts: Array[int] = [ring_one_count, ring_two_count, ring_three_count]
	print(ring_counts)
	
	for ring_count in ring_counts:
		var angle_increment: int = 360 / ring_count
		print(angle_increment)
		var ring_index = 0
		var angle = 90 + angle_variation
		while ring_index < ring_count:
			var newBullet: Area2D = bulletScene.instantiate()
			newBullet.get_node("Sprite2D").modulate = Color("green")
			newBullet.damage = bulletDamage
			newBullet.speed = bulletSpeed
			newBullet.global_position = global_position
			newBullet.rotation_degrees = angle + 90
			newBullet.direction = Vector2.from_angle(deg_to_rad(angle))
			angle += angle_increment
			print(newBullet.rotation_degrees, newBullet.direction, newBullet.global_position)
			get_tree().current_scene.add_child(newBullet)
			ring_index += 1
		angle_variation += 20
		ring_index = 0
		SfxPlayer.enemy_shot_sound()
		print("Awaiting...")
		await get_tree().create_timer(0.25).timeout
	
func _on_reroute_timer_timeout() -> void:
	pass
