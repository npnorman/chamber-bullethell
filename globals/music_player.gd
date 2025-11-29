extends AudioStreamPlayer

const cutscene_music = preload("res://sounds/cupcakes_vinegar-sour_mood.mp3")

func _play_sound(sound, volume: float = -10.0) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	
	audio_stream_player.stream = sound
	audio_stream_player.volume_db = volume
	audio_stream_player.play()
	await audio_stream_player.finished
	audio_stream_player.queue_free()

func _play_sound_cutoff(sound, volume: float = -10.0) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	
	audio_stream_player.stream = sound
	audio_stream_player.volume_db = volume
	audio_stream_player.play()
	
	cutscene_music_players.push_back(audio_stream_player)

var cutscene_music_players = []

func player_cutscene_music() -> void:
	_play_sound_cutoff(cutscene_music, -5)

func stop_cutscene_music():
	if len(cutscene_music_players) > 0:
		var mp = cutscene_music_players.pop_front()
		mp.stop()
		mp.queue_free()
