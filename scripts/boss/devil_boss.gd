extends CharacterBody2D

# arms
@onready var tommy_arm: Node2D = $Tommy
@onready var trident_arm: Node2D = $Trident

@onready var phase_1_timer: Timer = $Phase1Timer
@onready var phase_2_timer: Timer = $Phase2Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_player: AnimationPlayer = $DamagePlayer
@onready var trident_animation: AnimationPlayer = $TridentAnimation
@onready var tommy_animation: AnimationPlayer = $TommyAnimation

@onready var tommy_arm_sprite: AnimatedSprite2D = $tommyArm
@onready var trident_arm_sprite: AnimatedSprite2D = $tridentArm
@onready var body_sprite: AnimatedSprite2D = $body

var target:Vector2 = Vector2.ZERO
var origin:Vector2 = Vector2.ZERO
var direction:Vector2 = Vector2.ZERO
var speed : float = 500

# Bullets
var bulletDamage = 3
var bulletSpeed = 500
var despawnTime = 10
@export var bulletScene:PackedScene
var player

var targetDelta = 100
var movementOffset = 0
var movementSize = Globals.room_size * Globals.tile_size / 2
var phase1 = [
	Vector2(1,0),
	Vector2(-1,0)
]
var phase2 = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(-1,0),
	Vector2(0,-1)
]
var phase3 = [
	Vector2(0,1),
	Vector2(0,-1)
]

# States
enum States {
	REST,
	PHASE1,
	PHASE2,
	PHASE3,
	DEATH
}

var currentState = States.PHASE1
var isReadyPhase1 = true
@onready var state_machine_timer: Timer = $StateMachineTimer
var moveToNextState = false
var moveTime = 10

# Health info
@export var hp = 800
var hpStates = [600, 400]

func activate():
	moveToNextState = true

func _ready() -> void:
	#get player
	player = get_tree().get_first_node_in_group("Player")
	origin = global_position
	set_target(origin)

func _physics_process(delta: float) -> void:
	
	# check state
	checkState()
	
	# check health
	checkHealth()
	
	if currentState == States.REST:
		velocity = Vector2.ZERO
		body_sprite.play("throne")
		tommy_arm_sprite.visible = false
		trident_arm_sprite.visible = false
	elif currentState == States.PHASE1:
		phase1_pattern(delta)
	elif currentState == States.PHASE2:
		phase2_pattern(delta)
	elif currentState == States.PHASE3:
		phase3_pattern(delta)
	elif currentState == States.DEATH:
		velocity = Vector2.ZERO
		#do nothing
	
	move_and_slide()

func checkHealth():
	# play sprites for different health stages
	if hp > hpStates[0]:
		pass
	elif hp > hpStates[1]:
		pass
	elif hp > 0:
		pass
	elif hp <= 0:
		on_death()

func checkState():
	# handles enter/exit
	
	if moveToNextState:
		
		moveToNextState = false
		
		if currentState == States.REST:
			# can move to phase 1
			animation_player.play("RESET")
			body_sprite.play("default")
			tommy_arm_sprite.visible = true
			trident_arm_sprite.visible = true
			
			if hp > hpStates[1]:
				currentState = States.PHASE1
				moveTime = 15
			else:
				currentState = States.PHASE2
				moveTime = 15
			
		elif currentState == States.PHASE1:
			# move to rest if hp is good
			if hp > hpStates[0]:
				currentState = States.REST
				animation_player.play("rest")
				moveTime = 10
			else:
				currentState = States.PHASE2
				moveTime = 15
			
		elif currentState == States.PHASE2:
			
			if hp > hpStates[1]:
				currentState = States.REST
				animation_player.play("rest")
				moveTime = 10
			else:
				currentState = States.PHASE3
				moveTime = 15
		
		elif currentState == States.PHASE3:
			
			velocity = Vector2.ZERO
			currentState = States.REST
			animation_player.play("rest")
			moveTime = 10
		
		elif currentState == States.DEATH:
			velocity = Vector2.ZERO
		
		state_machine_timer.wait_time = moveTime
		state_machine_timer.start()

func phase1_pattern(delta):
	if isReadyPhase1:
		isReadyPhase1 = false
		trident_animation.stop()
		trident_animation.play("shoot")
		shoot_arm(trident_arm)
		animation_player.play("shoot")
		phase_1_timer.start()
	
	if global_position.distance_to(target) < targetDelta:
		# set new target
		movementOffset = (movementOffset + 1) % len(phase1)
		set_target(origin + (phase1[movementOffset] * movementSize))
	
	move_to_target(delta)

func phase2_pattern(delta):
	if global_position.distance_to(target) < targetDelta:
		# set new target
		movementOffset = (movementOffset + 1) % len(phase2)
		set_target(origin + (phase2[movementOffset] * movementSize))
	
	if phase_2_timer.is_stopped():
		phase_2_timer.start()
	
	move_to_target(delta)

func phase3_pattern(delta):
	if global_position.distance_to(target) < targetDelta:
		# set new target
		movementOffset = (movementOffset + 1) % len(phase3)
		set_target(origin + (phase3[movementOffset] * movementSize))
		
		# spawn smoke!
		spawn_smoke()
	
	move_to_target(delta)

func spawn_smoke():
	# spawn in fruit
	print("Smoking")
	pass

func take_damage(damage:int):
	hp -= damage
	print("hp: ",hp)
	
	if damage_player.is_playing():
		damage_player.stop()
	
	damage_player.play("damage")

func set_target(target:Vector2):
	self.target = target

func move_to_target(delta):
	#move towards target
	var direction = Vector2.ZERO
	
	direction = global_position.direction_to(target)
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, delta)

func get_shoot_target():
	return player.global_position

func shoot(shoot_from_position:Vector2, pos:Vector2):
	var newBullet:Area2D = bulletScene.instantiate()
	var shoot_target:Vector2 = get_shoot_target()
	
	newBullet.damage = bulletDamage
	newBullet.speed = bulletSpeed
	newBullet.global_position = shoot_from_position
	newBullet.direction = shoot_from_position.direction_to(shoot_target)
	newBullet.rotation = shoot_from_position.angle_to_point(shoot_target) + deg_to_rad(90.0)
	
	SfxPlayer.enemy_shot_sound()
	get_tree().current_scene.add_child(newBullet)
	
	newBullet.set_despawn_timer(despawnTime)

func shoot_arm(arm):
	var pos:Vector2
	
	pos = arm.global_position
	
	for marker:Marker2D in arm.get_children():
		shoot(marker.global_position, pos)

func on_death():
	currentState = States.DEATH
	#animation_player.play("death")
	Globals.change_scene(Globals.Scenes.WIN)

func to_win_room():
	Globals.change_scene_and_reset(Globals.Scenes.WIN)

func _on_phase_1_timer_timeout() -> void:
	isReadyPhase1 = true

func _on_phase_2_timer_timeout() -> void:
	animation_player.play("shoot")
	tommy_animation.stop()
	tommy_animation.play("shoot")
	shoot_arm(tommy_arm)

func _on_state_machine_timer_timeout() -> void:
	moveToNextState = true
