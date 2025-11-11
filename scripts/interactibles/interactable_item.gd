extends RigidBody2D

var sound_ready: bool = true

@onready var timer: Timer = $Timer

#func _on_body_entered(body: Node) -> void:
	#if sound_ready:
		#timer.start()
		#SfxPlayer.beer_sound()
		#sound_ready = false
#
#func _on_timer_timeout() -> void:
	#sound_ready = true
