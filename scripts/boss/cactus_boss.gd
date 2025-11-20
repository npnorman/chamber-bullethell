extends CharacterBody2D

# arms
@onready var right_arm: Node2D = $RightArm
@onready var left_arm: Node2D = $LeftArm

@onready var phase_1_timer: Timer = $Phase1Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arms: AnimatedSprite2D = $arms
@onready var body: AnimatedSprite2D = $body
@onready var damage_player: AnimationPlayer = $DamagePlayer

var target:Vector2 = Vector2.ZERO
var origin:Vector2 = Vector2.ZERO
var direction:Vector2 = Vector2.ZERO
var speed : float = 500

# Bullets
var bulletDamage = 1
var bulletSpeed = 100
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

# States
enum States {
	REST,
	PHASE1,
	PHASE2,
	PHASE3
}

var hpStates = [90, 70]

var currentState = States.REST
var isReadyPhase1 = false
@onready var state_machine_timer: Timer = $StateMachineTimer
var moveToNextState = true

# Health info
var hp = 100

func _ready() -> void:
	#get player
	player = get_tree().get_first_node_in_group("Player")
	
	origin = global_position
	set_target(origin + phase2[movementOffset])

func _physics_process(delta: float) -> void:
	
	# check state
	checkState()
	
	# check health
	checkHealth()
	
	if currentState == States.REST:
		velocity = Vector2.ZERO
	elif currentState == States.PHASE1:
		phase1_pattern(delta)
	elif currentState == States.PHASE2:
		phase2_pattern(delta)
	elif currentState == States.PHASE3:
		phase3_pattern(delta)
	
	move_and_slide()

func checkHealth():
	if hp > hpStates[0]:
		body.play("hp1")
	elif hp > hpStates[1]:
		body.play("hp2")
	else:
		body.play("hp3")

var moveTime = 10
func checkState():
	# handles enter/exit
	
	if moveToNextState:
		
		moveToNextState = false
		
		if currentState == States.REST:
			# can move to phase 1
			if hp > hpStates[1]:
				isReadyPhase1 = true
				set_target(origin)
				currentState = States.PHASE1
				animation_player.play("RESET")
				moveTime = 10
			else:
				currentState = States.PHASE2
				moveTime = 20
			
		elif currentState == States.PHASE1:
			# move to rest if hp is good
			if hp > hpStates[0]:
				currentState = States.REST
				animation_player.play("rest")
				moveTime = 5
			else:
				currentState = States.PHASE2
				moveTime = 20
			
		elif currentState == States.PHASE2:
			
			if hp > hpStates[1]:
				currentState = States.REST
				animation_player.play("rest")
				moveTime = 5
			else:
				currentState = States.PHASE3
				moveTime = 20
		
		elif currentState == States.PHASE3:
			
			currentState = States.REST
			animation_player.play("rest")
			moveTime = 5
		
		state_machine_timer.wait_time = moveTime
		state_machine_timer.start()

func phase1_pattern(delta):
	if isReadyPhase1:
		print("shooting")
		isReadyPhase1 = false
		shoot_arm(right_arm)
		shoot_arm(left_arm)
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
		
		shoot_arm(right_arm)
		shoot_arm(left_arm)
		
	move_to_target(delta)

func phase3_pattern(delta):
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

func shoot(shoot_from_position:Vector2):
	var newBullet:Area2D = bulletScene.instantiate()
	var shoot_target:Vector2 = get_shoot_target()
	
	var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	var colors = [Color("Yellow"), Color("8c6e00"), Color("ffc64a")]
	var color_index:int = rng.randi_range(0, len(colors) - 1)
	
	var color:Color = colors[color_index]
	
	newBullet.get_node("Sprite2D").modulate = color
	newBullet.damage = bulletDamage
	newBullet.speed = bulletSpeed
	newBullet.global_position = shoot_from_position
	newBullet.direction = shoot_from_position.direction_to(shoot_target)
	newBullet.rotation = shoot_from_position.angle_to_point(shoot_target) + deg_to_rad(90.0)
	
	SfxPlayer.enemy_shot_sound()
	get_tree().current_scene.add_child(newBullet)
	
	newBullet.set_despawn_timer(despawnTime)

func shoot_arm(arm):
	for marker:Marker2D in arm.get_children():
		shoot(marker.global_position)

func _on_phase_1_timer_timeout() -> void:
	isReadyPhase1 = true

func _on_state_machine_timer_timeout() -> void:
	moveToNextState = true
