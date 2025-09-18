extends CharacterBody2D

var target:CharacterBody2D
@export var nav_agent:NavigationAgent2D
@export var speed = 300
@export var health = 2

func _ready() -> void:
	target = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta: float) -> void:
	
	decide_nav_route(delta)
	
	move_and_slide()

func decide_nav_route(delta):
	#set target
	nav_agent.target_position = target.global_position
	
	#move towards target
	var direction = Vector2.ZERO
	
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, delta)

func take_damage(damage:int):
	health -= damage
	if health <= 0:
		enemy_die()

func enemy_die():
	# or dead body
	self.queue_free()
