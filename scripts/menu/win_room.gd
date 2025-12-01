extends Control

@onready var go_to_menu: Button = $VBoxContainer/GoToMenu

func _ready() -> void:
	go_to_menu.grab_focus()

func _on_go_to_menu_pressed() -> void:
	Globals.change_scene(Globals.Scenes.START)
