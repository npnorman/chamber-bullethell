extends CanvasLayer

@export var is_rotating: bool = false
@onready var basic_back: Resource = preload("res://sprites/basic_back.png")
@onready var ricochet_back: Resource = preload("res://sprites/ricochet_back.png")
@onready var shotgun_back: Resource = preload("res://sprites/shotgun_back.png")
@onready var chamber_array: Array[TextureRect] = [$CylinderNode/Chamber1/BulletTexture1, $CylinderNode/Chamber2/BulletTexture2, $CylinderNode/Chamber3/BulletTexture3, $CylinderNode/Chamber4/BulletTexture4, $CylinderNode/Chamber5/BulletTexture5, $CylinderNode/Chamber6/BulletTexture6]
@onready var bullet_textures: Array[Resource] = [basic_back, ricochet_back, shotgun_back]
@onready var ammo_counters: Array[Label] = [$SpecialBullets/NormalAmmoBox/BasicAmmo, $SpecialBullets/SpecialAmmoBox1/SpecialAmmo1, $SpecialBullets/SpecialAmmoBox2/SpecialAmmo2, $SpecialBullets/SpecialAmmoBox3/SpecialAmmo3]
@onready var ammo_keys: Array[Label] = [$SpecialBullets/SpecialAmmoBox1/SpecialKey1, $SpecialBullets/SpecialAmmoBox2/SpecialKey2, $SpecialBullets/SpecialAmmoBox3/SpecialKey3]
@onready var hud_ammo_textures: Array[TextureRect] = [$SpecialBullets/SpecialAmmoBox1/SpecialTexture1, $SpecialBullets/SpecialAmmoBox2/SpecialTexture2, $SpecialBullets/SpecialAmmoBox3/SpecialTexture3]

signal rotation_completed

func _ready():
	update_chamber_textures()
	update_counters()
	set_ammo_types()

func _process(_delta):
	if is_rotating:
		$CylinderNode.rotation_degrees += 6
		if roundi($CylinderNode.rotation_degrees) % 60 == 0:
			is_rotating = false
			rotation_completed.emit()

# Rotates cylinder after receiving signal from level script
func start_rotating():
	is_rotating = true

# Sets textures for HUD ammo counters and makes the key invisible when no ammo type is there
func set_ammo_types():
	var index: int = 1
	for special_ammo: TextureRect in hud_ammo_textures:
		if Globals.ammo_types[index] > 0:
			special_ammo.texture = bullet_textures[Globals.ammo_types[index]]
			ammo_keys[index - 1].visible = true
		else: 
			ammo_keys[index - 1].visible = false
		index += 1

# Called after shooting/reloading, changes each chambers' textures based on global magazine array
func update_chamber_textures():
	var index: int = 0
	for texture: TextureRect in chamber_array:
		if Globals.magazine[index] >= 0:
			texture.texture = bullet_textures[Globals.magazine[index]]
			texture.visible = true
		else:
			texture.visible = false
		index += 1

func update_counters():
	var index: int = 0
	for counter: Label in ammo_counters:
		if Globals.ammo_types[index] > -1:
			counter.text = str(Globals.ammo[Globals.ammo_types[index]])
		else:
			counter.text = ''
		index += 1
