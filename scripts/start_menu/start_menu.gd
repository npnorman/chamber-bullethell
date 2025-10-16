extends Node2D

func start_button():
	Globals.change_scene("res://rooms/TestingRoom.tscn")

func settings_button():
	pass

func end_game_button():
	get_tree().quit()

func _on_start_button_pressed() -> void:
	start_button()

func _on_settings_button_pressed() -> void:
	settings_button()

func _on_exit_button_pressed() -> void:
	end_game_button()
