extends Control

@onready var texture_rect: TextureRect = $TextureRect
@export var dollar:Texture2D
@export var skull:Texture2D

func set_icon(texture:String):
	if texture == "dollar":
		texture_rect.texture = dollar
	elif texture == "skull":
		texture_rect.texture = skull
