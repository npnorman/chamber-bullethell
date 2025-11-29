extends CanvasLayer

@onready var menu_container: VBoxContainer= $VBoxContainer
@onready var controls: Button = $VBoxContainer/Controls
@onready var resume: Button = $VBoxContainer/Resume
@onready var main_menu: Button = $VBoxContainer/GoToMenu
@onready var restart: Button = $VBoxContainer/Restart
@onready var death_text: RichTextLabel = $DeathText
@onready var controls_container: Control = $ControlScreen
@onready var exit_controls: Button = $ControlScreen/ExitControls
@onready var seed_text: RichTextLabel = $SeedText

signal game_resumed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	seed_text.text = "[right]  seed: " + str(Globals.current_seed) + "   [/right]"

func _on_resume_pressed() -> void:
	game_resumed.emit()
	get_tree().paused = false

func _on_go_to_menu_pressed() -> void:
	game_resumed.emit()
	Globals.change_scene_and_reset("res://scenes/menu/start_menu.tscn")

func _on_restart_pressed() -> void:
	game_resumed.emit()
	Globals.change_scene_and_reset("res://rooms/TestingRoom.tscn")

func on_death() -> void:
	resume.visible = false
	death_text.visible = true

func on_pause() -> void:
	resume.visible = true
	death_text.visible = false

func _on_controls_pressed() -> void:
	menu_container.visible = false
	controls_container.visible = true

func _on_exit_controls_pressed() -> void:
	menu_container.visible = true
	controls_container.visible = false

func _on_restart_same_seed_pressed() -> void:
	game_resumed.emit()
	# save the seed
	Globals.change_scene_and_reset("res://rooms/TestingRoom.tscn", true, true, false)
