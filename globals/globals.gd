extends Node

signal stat_changed

var ammo: int = 30:
	get:
		return ammo
	set(value):
		ammo = value
		# This signal will be used to change the UI number in the future
		stat_changed.emit()
