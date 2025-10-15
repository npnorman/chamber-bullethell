extends Node

var bullet_texts: Array[String] = ['', '', '', '', '', '', '']

func _ready() -> void:
	bullet_texts[Globals.Bullets.Normal] = "[color=yellow]Basic Bullet[/color] \nThis is your trusty standard bullet! While this bullet may not have any special effects, it is so widely used that it is accepted as currency just about anywhere!"
	bullet_texts[Globals.Bullets.Ricochet] = "[color=blue]Rick O'Shay Round[/color] \nThis bullet may seem similar to basic bullets, but its power greatly increases if it hits an enemy after bouncing off of a wall!"
	bullet_texts[Globals.Bullets.Shotgun] = "[color=red]Shotgun Shell[/color] \nThis powerful round has six times the bullets per bullet! It may be inaccurate at long ranges, but it can quickly take out enemies you dare to come close to."
	
