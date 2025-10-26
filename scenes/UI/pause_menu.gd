extends CanvasLayer

@onready var resume: Button = $VBoxContainer/Resume
@onready var main_menu: Button = $VBoxContainer/GoToMenu
@onready var restart: Button = $VBoxContainer/Restart
@onready var death_text: Label = $DeathText

signal game_resumed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_resume_pressed() -> void:
	game_resumed.emit()
	get_tree().paused = false

func _on_go_to_menu_pressed() -> void:
	game_resumed.emit()
	Globals.change_scene("res://scenes/menu/start_menu.tscn")

func _on_restart_pressed() -> void:
	game_resumed.emit()
	Globals.change_scene("res://rooms/TestingRoom.tscn")

func on_death() -> void:
	resume.visible = false
	death_text.visible = true

func on_pause() -> void:
	resume.visible = true
	death_text.visible = false
