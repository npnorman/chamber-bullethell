extends Node2D

func start_button():
	Globals.change_scene(Globals.Scenes.CUSTOM,"res://scenes/menu/intro_cutscene.tscn")

func settings_button():
	Globals.change_scene(Globals.Scenes.SETTINGS)

func end_game_button():
	get_tree().quit()

func credits_button():
	Globals.change_scene(Globals.Scenes.CREDITS)

func _on_start_button_pressed() -> void:
	start_button()

func _on_settings_button_pressed() -> void:
	settings_button()

func _on_exit_button_pressed() -> void:
	end_game_button()

func _on_credits_button_pressed() -> void:
	credits_button()
