extends Node2D

@export var level = Globals.Level.HELL
@export var isWin = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if isWin:
			Globals.change_scene_and_reset(Globals.Scenes.WIN)
		else:
			Globals.change_level(level)
