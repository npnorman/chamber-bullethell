extends Area2D

func _on_body_entered(body: Node2D) -> void:
	get_parent().get_parent().spawn_player_in_boss_room()
