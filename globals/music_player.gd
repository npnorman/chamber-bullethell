extends AudioStreamPlayer

func _play_sound(sound: AudioStreamWAV, volume: float = -10.0) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	
	audio_stream_player.stream = sound
	audio_stream_player.volume_db = volume
	audio_stream_player.play()
	await audio_stream_player.finished
	audio_stream_player.queue_free()
