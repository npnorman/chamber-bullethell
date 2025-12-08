extends Control

@onready var check_box: CheckBox = $CheckBox
@onready var music_slider: HSlider = $MusicVolumeSlider
@onready var sfx_slider: HSlider = $SFXVolumeSlider

func _ready() -> void:
	check_box.grab_focus()
	check_box.button_pressed = !Settings.isMouse
	sfx_slider.value = SfxPlayer.sfx_volume
	music_slider.value = MusicPlayer.music_volume

func _on_button_pressed() -> void:
	Settings.isMouse = !check_box.button_pressed
	Globals.change_scene(Globals.Scenes.START)

func _on_sfx_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		SfxPlayer.sfx_volume = sfx_slider.value

func _on_music_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		MusicPlayer.music_volume = music_slider.value
