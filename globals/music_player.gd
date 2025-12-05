extends AudioStreamPlayer

const cutscene_music = preload("res://sounds/music/cupcakes_vinegar-sour_mood.mp3")
const saloon_music = preload("res://sounds/music/Cowagunga.ogg")
const desert_music = preload("res://sounds/music/Tumbleweeds.ogg")

var fade_in_progress: bool = false
#func _play_sound(sound, volume: float = -10.0) -> void:
	#var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	#add_child(audio_stream_player)
	#
	#audio_stream_player.stream = sound
	#audio_stream_player.volume_db = volume
	#audio_stream_player.play()
	#await audio_stream_player.finished
	#audio_stream_player.queue_free()
#
#func _play_sound_cutoff(sound, volume: float = -10.0) -> void:
	#var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	#add_child(audio_stream_player)
	#
	#audio_stream_player.stream = sound
	#audio_stream_player.volume_db = volume
	#audio_stream_player.play()
	#
	#cutscene_music_players.push_back(audio_stream_player)
#
#var cutscene_music_players = []
#
#func player_cutscene_music() -> void:
	#_play_sound_cutoff(cutscene_music, -5)
#
#func stop_cutscene_music():
	#if len(cutscene_music_players) > 0:
		#var mp = cutscene_music_players.pop_front()
		#mp.stop()
		#mp.queue_free()

func _play_music(music: AudioStream, volume: float = -5.0) -> void:
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()

func play_cutscene_music() -> void:
	_play_music(cutscene_music)

func play_saloon_music() -> void:
	_play_music(saloon_music, -10)
	
func play_desert_music() -> void:
	_play_music(desert_music, -14)

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
	tween.tween_property(self, "volume_db", volume, 2)
	
