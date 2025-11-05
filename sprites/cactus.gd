extends Node2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	var sprite: AnimatedSprite2D = get_child(0)
	var area_collider: CollisionShape2D = get_child(3).get_child(0)
	var bullet_collider: CollisionShape2D = get_child(2).get_child(0)
	if sprite.frame < 5:
		sprite.frame += 1
		area_collider.shape.size.y -= 6
		area_collider.position.y += 3
		bullet_collider.shape.size.y -= 6
		bullet_collider.position.y += 3
