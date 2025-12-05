extends CanvasLayer

var can_exit = false

@onready var menu_container: VBoxContainer= $VBoxContainer
@onready var controls: Button = $VBoxContainer/Controls
@onready var resume: Button = $VBoxContainer/Resume
@onready var main_menu: Button = $VBoxContainer/GoToMenu
@onready var restart: Button = $VBoxContainer/Restart
@onready var death_text: RichTextLabel = $DeathText
@onready var controls_container: Control = $ControlScreen
@onready var exit_controls: Button = $ControlScreen/ExitControls
@onready var seed_text: RichTextLabel = $SeedText
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal game_resumed

# for easter egg
var current_key_index = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	seed_text.text = "[right]  seed: " + str(Globals.current_seed) + "   [/right]"

func _input(event: InputEvent) -> void:
	# check for code
	var code = ["Up","Up","Down","Down","Left","Right","Left","Right","B","A","Start"]
	
	if event.is_action(code[current_key_index]) and event.is_echo() == false and event.is_pressed() == false:
		current_key_index += 1
		if current_key_index >= len(code):
			current_key_index = 0
			animation_player.play("easter_egg")
			
	elif event.is_action(code[current_key_index]) and event.is_echo() == false and event.is_pressed():
		pass
		
	else:
		current_key_index = 0

func set_focus(death:bool):
	if death:
		restart.grab_focus()
	else:
		resume.grab_focus()

func _on_resume_pressed() -> void:
	resume_game()

func resume_game():
	game_resumed.emit()
	get_tree().paused = false
	can_exit = false

func _on_go_to_menu_pressed() -> void:
	game_resumed.emit()
	Globals.change_scene_and_reset(Globals.Scenes.START)

func _on_restart_pressed() -> void:
	game_resumed.emit()
	
	Globals.change_level_and_reset()

func on_death() -> void:
	resume.visible = false
	death_text.visible = true

func on_pause() -> void:
	resume.visible = true
	death_text.visible = false

func _on_controls_pressed() -> void:
	menu_container.visible = false
	controls_container.visible = true
	exit_controls.grab_focus()

func _on_exit_controls_pressed() -> void:
	menu_container.visible = true
	controls_container.visible = false
	controls.grab_focus()

func _on_restart_same_seed_pressed() -> void:
	game_resumed.emit()
	# save the seed
	Globals.change_level_and_reset(Globals.current_level,true,true,false)
