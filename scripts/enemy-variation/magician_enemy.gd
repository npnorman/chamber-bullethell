extends "res://scripts/enemy.gd"

var can_shoot: bool = false
var in_teleport: bool = false
var teleport_distance : float = 100.0
@onready var smoke_particles: CPUParticles2D = $SmokeParticles
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var teleport_timer: Timer = $TeleportTimer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	target = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta: float) -> void:
	if is_active and !is_dead:
		# call timer
		# shoot
		if global_position.distance_to(target.global_position) < teleport_distance:
			
			if in_teleport == false:
				in_teleport = true
				teleport()

func take_damage(damage:int):
	super.take_damage(damage)
	
	if in_teleport == false and health > 0:
		in_teleport = true
		set_particle_gradient("#ff7878","#6b0c0c")
		smoke_particles.color_initial_ramp.remove_point(1)
		smoke_particles.color_initial_ramp.add_point(1,Color("#ff7878"))
		smoke_particles.color_initial_ramp.remove_point(0)
		smoke_particles.color_initial_ramp.add_point(0,Color("#6b0c0c"))
		teleport()

func set_particle_gradient(color1,color2):
	#set particles back
	smoke_particles.color_initial_ramp.remove_point(1)
	smoke_particles.color_initial_ramp.add_point(1,Color(color1))
	smoke_particles.color_initial_ramp.remove_point(0)
	smoke_particles.color_initial_ramp.add_point(0,Color(color2))

func teleport():
	# spawn smoke
	smoke_particles.emitting = true
	
	# toggle collider,sprite,bullets (disable)
	toggle_invisible(false)
	
	# wait x seconds
	teleport_timer.start()


func _on_teleport_timer_timeout() -> void:
	
	# get current room center
	var center:Vector2 = Globals.current_room_center
	
	# pick a random spot room radius away from center
	var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	var room_radius:float = ((Globals.tile_size * Globals.room_size) / 2) - Globals.tile_size * 2
	var xr:float = rng.randf_range(-room_radius,room_radius)
	var yr:float = rng.randf_range(-room_radius,room_radius)
	
	global_position = center + Vector2(xr,yr)
	
	set_particle_gradient("#5d5d5d","#ffffff")
	
	# play smoke
	smoke_particles.emitting = true
	
	# toggle collider,sprite,bullets (enable)
	toggle_invisible(true)
	
	in_teleport = false

func toggle_invisible(isEnabled:bool):
	if isEnabled:
		animated_sprite_2d.play("idle")
		collision_shape_2d.disabled = false
		cpu_particles_2d.emitting = true
		is_active = true
	else:
		animated_sprite_2d.play("death")
		cpu_particles_2d.emitting = false
		collision_shape_2d.disabled = true
		is_active = false

func _on_reroute_timer_timeout() -> void:
	# reroute navagent
	if !is_dead and is_active:
		can_shoot = true
		animated_sprite_2d.play("intoHat")
		
		# random
		var times = [-wiggle,wiggle]
		var rng = RandomNumberGenerator.new()
		var wiggle = times[rng.randi_range(0,times.size()-1)]
		reroute_timer.wait_time = wait_time + wiggle

func shoot():
	super.shoot()
	
	can_shoot = false
	animated_sprite_2d.play("resetHat")

func _on_animated_sprite_2d_animation_finished() -> void:
	if can_shoot == true:
		shoot()
