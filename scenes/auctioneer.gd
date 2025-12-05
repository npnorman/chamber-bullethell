extends "res://scripts/enemy.gd"

var counter: int = 0
var angle_variation: int = 0
var counting_started: bool = false
@onready var count_timer: Timer = $CountTimer
@onready var count_label: RichTextLabel = $CountLabel
var original_position: Vector2

func _ready() -> void:
	original_position = count_label.global_position

func _physics_process(delta: float) -> void:
	if is_active and not counting_started:
		count_timer.start()
		counting_started = true

func _on_count_timer_timeout() -> void:
	if count_label.visible == false:
		count_label.visible = true
	if is_active:
		var tween = create_tween()
		counter += 1
		count_label.text = str(counter)
		tween.tween_property($CountLabel, "position", Vector2(-23, -70), 0.5).from(Vector2(-23,-48))
		tween.tween_property($CountLabel, "modulate", Color(1, 1, 1, 0), 0.5).from(Color(1, 1, 1, 1))
		count_timer.start()
		

func enemy_die():
	if not is_dead:
		get_tree().current_scene.spawn_pickup(Globals.Bullets.Normal, 3, global_position)
	is_dead = true
	animated_sprite_2d.play("death")
	animation_player.play_section("death", 0, 0.5)
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
	
	for ring_count in ring_counts:
		if ring_count != 0:
			var angle_increment: int = 360 / ring_count
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
				get_tree().current_scene.add_child(newBullet)
				ring_index += 1
			angle_variation += angle_increment / 2
			ring_index = 0
			index += 1
			SfxPlayer.enemy_shot_sound()
			await get_tree().create_timer(0.5).timeout
	queue_free()
	
func _on_reroute_timer_timeout() -> void:
	pass
