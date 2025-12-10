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

const player_death = preload("res://sounds/Player_Death.wav")
const enemy_death = preload("res://sounds/Enemy_Death.wav")
const boss_death = preload("res://sounds/Boss_Death.wav")
const step_high = preload("res://sounds/Step_High.wav")
const step_low = preload("res://sounds/Step_Low.wav")
const miss = preload("res://sounds/Miss.wav")
const success = preload("res://sounds/Success.wav")
const victory_tune = preload("res://sounds/Victory_Tune.wav")
const loss_tune = preload("res://sounds/Loss_Tune.wav")
const ammo_get = preload("res://sounds/Ammo_Get.wav")
const chest_open = preload("res://sounds/Chest_Open.wav")


var sfx_volume: int = 0
var step_type: int = 0

func _play_sound(sound: AudioStreamWAV, volume: float = -10.0) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	
	audio_stream_player.process_mode = Node.PROCESS_MODE_ALWAYS
	audio_stream_player.stream = sound
	audio_stream_player.volume_db = volume + sfx_volume
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

func player_death_sound() -> void:
	_play_sound(player_death, -10)

func enemy_death_sound() -> void:
	_play_sound(enemy_death, -20)

func boss_death_sound() -> void:
	_play_sound(boss_death, -10)

func miss_sound() -> void:
	_play_sound(miss, -15)

func success_sound() -> void:
	_play_sound(success, -25)

func victory_tune_sound() -> void:
	_play_sound(victory_tune)

func loss_tune_sound() -> void:
	_play_sound(loss_tune)

func ammo_get_sound() -> void:
	_play_sound(ammo_get)

func chest_open_sound() -> void:
	_play_sound(chest_open)

func step_sound() -> void:
	if step_type == 0:
		_play_sound(step_high)
		step_type = 1
	else:
		_play_sound(step_low)
		step_type = 0
