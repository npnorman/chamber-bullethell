extends AudioStreamPlayer

const player_shot = preload("res://sounds/Gunshot2.wav")
const cylinder_click = preload("res://sounds/CylinderClick.wav")
const beer = preload("res://sounds/BEER.wav")
const heal = preload("res://sounds/Heal.wav")
const blank = preload("res://sounds/Blank.wav")
const railgun = preload("res://sounds/Railgun.wav")
const cactus = preload("res://sounds/Cactus_Dmg.wav")
const player_damage = preload("res://sounds/Hit (Damage).wav")
const enemy_damage = preload("res://sounds/Hit2.wav")
const other_hit = preload("res://sounds/Hit3.wav")
const explosion = preload("res://sounds/Explosion3.wav")
const splash = preload("res://sounds/Splash.wav")
const enemy_shot = preload("res://sounds/Shot4.wav")

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
	
func beer_sound() -> void:
	_play_sound(beer)
	
func heal_sound() -> void:
	_play_sound(heal, -15)

func blank_sound() -> void:
	_play_sound(blank, -15)

func railgun_sound() -> void:
	_play_sound(railgun, -15)

func cactus_sound() -> void:
	_play_sound(cactus)

func player_damage_sound() -> void:
	_play_sound(player_damage)

func enemy_damage_sound() -> void:
	_play_sound(enemy_damage)
	
func other_hit_sound() -> void:
	_play_sound(other_hit, -15)

func explosion_sound() -> void:
	_play_sound(explosion)

func splash_sound() -> void:
	_play_sound(splash)
	
func enemy_shot_sound() -> void:
	_play_sound(enemy_shot, -20)
