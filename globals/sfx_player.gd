extends AudioStreamPlayer

const player_shot = preload("res://sounds/Gunshot2.wav")
const cylinder_click = preload("res://sounds/CylinderClick.wav")

func _play_sound(sound: AudioStreamWAV, volume: float = -10.0) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	
	audio_stream_player.stream = sound
	audio_stream_player.volume_db = volume
	audio_stream_player.play()
	await audio_stream_player.finished
	audio_stream_player.queue_free()
	
func player_shot_sound() -> void:
	_play_sound(player_shot, -8)

func cylinder_click_sound() -> void:
	_play_sound(cylinder_click)
