extends Control

@onready var check_box: CheckBox = $CheckBox

func _ready() -> void:
	check_box.grab_focus()
	check_box.button_pressed = !Settings.isMouse

func _on_button_pressed() -> void:
	Settings.isMouse = !check_box.button_pressed
	Globals.change_scene(Globals.Scenes.START)
