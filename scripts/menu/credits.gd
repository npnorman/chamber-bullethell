extends Control

@onready var names: RichTextLabel = $Names
@export var scroll_speed = 1.0
@onready var button: Button = $CenterContainer/Button

func _ready() -> void:
	button.grab_focus()

# scroll credits
func _process(delta: float) -> void:
	if names.get_v_scroll_bar().value >= names.get_v_scroll_bar().max_value - names.get_v_scroll_bar().page:
		names.get_v_scroll_bar().value = 0.0
	names.get_v_scroll_bar().value += scroll_speed

func _on_button_pressed() -> void:
	Globals.change_scene(Globals.Scenes.START)
