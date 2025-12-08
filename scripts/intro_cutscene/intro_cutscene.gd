extends Control

var isSkipping = false
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var mouse_text_1 = "Press TAB to skip"
var mouse_text_2 = "Press TAB to confirm"
var controller_text_1 = "Press (-) to skip"
var controller_text_2 = "Press (-) to confirm"
var text_1 = ""
var text_2 = ""

func _ready() -> void:
	# start music
	MusicPlayer.play_cutscene_music()
	
	if Settings.isMouse:
		text_1 = mouse_text_1
		text_2 = mouse_text_2
	else:
		text_1 = controller_text_1
		text_2 = controller_text_2
	
	rich_text_label.text = text_1

func move_to_starting_scene():
	MusicPlayer.fade_music_out(load("res://sounds/music/Tumbleweeds.ogg"))
	Globals.change_level_and_reset(Globals.Level.SALOON)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Inventory"):
		# skip
		
		if isSkipping == true:
			move_to_starting_scene()
		else:
			isSkipping = true
			rich_text_label.text = text_2
