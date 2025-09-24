extends CanvasLayer

@export var is_rotating: bool = false
@onready var basic_back: Resource = preload("res://sprites/basic_back.png")
@onready var ricochet_back: Resource = preload("res://sprites/ricochet_back.png")
@onready var shotgun_back: Resource = preload("res://sprites/shotgun_back.png")
@onready var chamber_array: Array[TextureRect] = [$CylinderNode/Chamber1/BulletTexture1, $CylinderNode/Chamber2/BulletTexture2, $CylinderNode/Chamber3/BulletTexture3, $CylinderNode/Chamber4/BulletTexture4, $CylinderNode/Chamber5/BulletTexture5, $CylinderNode/Chamber6/BulletTexture6]

@onready var bullet_textures: Array[Resource] = [basic_back, ricochet_back, shotgun_back]

func _ready():
	update_chamber_textures()

func _process(_delta):
	if is_rotating:
		$CylinderNode.rotation_degrees += 5
		if roundi($CylinderNode.rotation_degrees) % 60 == 0:
			is_rotating = false

func start_rotating():
	is_rotating = true

func update_chamber_textures():
	var index: int = 0
	for texture: TextureRect in chamber_array:
		if Globals.magazine[index] >= 0:
			texture.texture = bullet_textures[Globals.magazine[index]]
			print(Globals.magazine[index])
			texture.visible = true
		else:
			texture.visible = false
		index += 1
