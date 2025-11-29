extends Control

var isSkipping = false
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	# start music
	MusicPlayer.player_cutscene_music()

func move_to_starting_scene():
	MusicPlayer.stop_cutscene_music()
	Globals.change_level_and_reset(Globals.Level.DESERT)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Inventory"):
		# skip
		
		if isSkipping == true:
			move_to_starting_scene()
		else:
			isSkipping = true
			rich_text_label.text = "Press TAB to confirm"
