extends AudioStreamPlayer

const cutscene_music = preload("res://sounds/music/cupcakes_vinegar-sour_mood.mp3")
const saloon_music = preload("res://sounds/music/Cowagunga.ogg")
const desert_music = preload("res://sounds/music/Tumbleweeds.ogg")
const hell_music = preload("res://sounds/music/A Hell of a Deal.ogg")

var fade_in_progress: bool = false
var music_volume: int = 0

func _play_music(music: AudioStream, volume: float = -5.0) -> void:
	if stream == music:
		return
	stream = music
	volume_db = volume + music_volume
	play()

func play_cutscene_music() -> void:
	_play_music(cutscene_music)

func play_saloon_music() -> void:
	_play_music(saloon_music, -10)
	
func play_desert_music() -> void:
	_play_music(desert_music, -14)
	
func play_hell_music() -> void:
	_play_music(hell_music, -10)

func stop_music() -> void:
	stop()

func fade_music_out(music: AudioStream = null, volume: int = -10) -> void:
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -50, 2)
	if music == null:
		tween.finished.connect(stop_music)
	if music != null:
		await tween.finished
		fade_music_in(music, -10)

func fade_music_in(music: AudioStream, volume: int = -10):
	_play_music(music)
	var tween = create_tween()
	tween.tween_property(self, "volume_db", volume + music_volume, 2)
