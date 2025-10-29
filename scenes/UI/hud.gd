extends CanvasLayer

var rotation_count: int = 0
var mouse_over_box: bool = false
var mouse_over_trash: bool = false
var dragging_box: bool = false
var drag_distance: float
var drag_dir: Vector2
var new_position: Vector2
var active_box: int
var selected_box: int
@onready var chamber_array: Array[TextureRect] = [$CylinderNode/Chamber1/BulletTexture1, $CylinderNode/Chamber2/BulletTexture2, $CylinderNode/Chamber3/BulletTexture3, $CylinderNode/Chamber4/BulletTexture4, $CylinderNode/Chamber5/BulletTexture5, $CylinderNode/Chamber6/BulletTexture6]
@export var bullet_textures: Array[Resource]
@onready var ammo_counters: Array[Label] = [$SpecialBullets/NormalAmmoBox/BasicAmmo, $SpecialBullets/SpecialAmmoBox1/SpecialAmmo1, $SpecialBullets/SpecialAmmoBox2/SpecialAmmo2, $SpecialBullets/SpecialAmmoBox3/SpecialAmmo3]
@onready var ammo_keys: Array[Label] = [$SpecialBullets/NormalAmmoBox/BasicKey, $SpecialBullets/SpecialAmmoBox1/SpecialKey1, $SpecialBullets/SpecialAmmoBox2/SpecialKey2, $SpecialBullets/SpecialAmmoBox3/SpecialKey3]
@onready var hud_ammo_textures: Array[TextureRect] = [$SpecialBullets/NormalAmmoBox/NormalTexture, $SpecialBullets/SpecialAmmoBox1/SpecialTexture1, $SpecialBullets/SpecialAmmoBox2/SpecialTexture2, $SpecialBullets/SpecialAmmoBox3/SpecialTexture3]
@onready var inventory_array: Array[TextureRect] = [$InventoryAreas/InventoryView/Ammo1, $InventoryAreas/InventoryView/Ammo2, $InventoryAreas/InventoryView/Ammo3, $InventoryAreas/InventoryView/Ammo4]
@onready var inventory = $InventoryAreas
@onready var held_item = $HeldItem
@onready var held_texture = $HeldItem/HeldTexture
@onready var text_panel = $TextPanel
@onready var bullet_text = $TextPanel/TextDescription
@onready var stache_textures: Array[TextureRect] = [$HealthStache/StacheFarLeft/FarLeftTxt, $HealthStache/StacheLeft/LeftTxt, $HealthStache/StacheMiddle/MiddleTxt, $HealthStache/StacheRight/RightTxt, $HealthStache/StacheFarRight/FarRightTxt]
signal rotation_completed
signal ammo_dropped(bullet_id: int, amount: int)

func _ready():
	update_chamber_textures()
	update_counters()
	set_ammo_types()

func toggle_transparency(transparent: bool):
	if transparent:
		$CylinderNode.modulate.a = 0.3
		$SpecialBullets.modulate.a = 0.3
	else:
		$CylinderNode.modulate.a = 1
		$SpecialBullets.modulate.a = 1

func _process(delta: float) -> void:
	if mouse_over_box and inventory.visible and Globals.ammo_types[active_box] != -1:
		match active_box:
			0:
				bullet_text.text = Texts.bullet_texts[0]
				text_panel.position = Vector2(180, 140)
			1:
				bullet_text.text = Texts.bullet_texts[Globals.ammo_types[1]]
				text_panel.position = Vector2(303, 140)
			2:
				bullet_text.text = Texts.bullet_texts[Globals.ammo_types[2]]
				text_panel.position = Vector2(426, 140)
			3:
				bullet_text.text = Texts.bullet_texts[Globals.ammo_types[3]]
				text_panel.position = Vector2(549, 140)
		text_panel.visible = true
	elif text_panel.visible:
		text_panel.visible = false

# Rotates cylinder after receiving signal from level script
func start_rotating():
	match rotation_count:
		0:
			$CylinderNode/CylinderAnimation.play("Rotate_1")
		1:
			$CylinderNode/CylinderAnimation.play("Rotate_2")
		2:
			$CylinderNode/CylinderAnimation.play("Rotate_3")
		3:
			$CylinderNode/CylinderAnimation.play("Rotate_4")
		4:
			$CylinderNode/CylinderAnimation.play("Rotate_5")
		5:
			$CylinderNode/CylinderAnimation.play("Rotate_6")
	rotation_count += 1
	if rotation_count > 5:
		rotation_count = 0

func _on_cylinder_animation_animation_finished(anim_name: StringName) -> void:
	rotation_completed.emit()

# Sets textures for HUD ammo counters and makes the key invisible when no ammo type is there
func set_ammo_types():
	var index: int = 0
	while index < 4:
		if Globals.ammo_types[index] > -1:
			hud_ammo_textures[index].texture = bullet_textures[Globals.ammo_types[index]]
			inventory_array[index].texture = bullet_textures[Globals.ammo_types[index]]
			ammo_keys[index].visible = true
			ammo_counters[index].visible = true
		else: 
			ammo_keys[index].visible = false
			hud_ammo_textures[index].texture = null
			inventory_array[index].texture = null
			ammo_counters[index].visible = false
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

# Changes values in ammo counters after a change is made to data in Globals
func update_counters():
	var index = 0
	for counter: Label in ammo_counters:
		if Globals.ammo_types[index] > -1:
			counter.text = str(Globals.ammo[Globals.ammo_types[index]])
		else:
			counter.text = ''
		index += 1

# toggles visibility of inventory 
func display_inventory() -> void:
	inventory.visible = not inventory.visible
	
func update_health(new_health: int) -> void:
	match new_health:
		0:
			stache_textures[2].visible = false
		1:
			stache_textures[2].modulate = Color(1, 0, 0, 1)
			stache_textures[2].visible = true
		2:
			stache_textures[2].modulate = Color(0, 0, 0, 1)
			stache_textures[1].visible = false
			stache_textures[3].visible = false
		3:
			stache_textures[1].modulate = Color(1, 0, 0, 1)
			stache_textures[3].modulate = Color(1, 0, 0, 1)
			stache_textures[1].visible = true
			stache_textures[3].visible = true
		4:
			stache_textures[1].modulate = Color(0, 0, 0, 1)
			stache_textures[3].modulate = Color(0, 0, 0, 1)
			stache_textures[4].visible = false
			stache_textures[0].visible = false
		5:
			stache_textures[4].modulate = Color(1, 0, 0, 1)
			stache_textures[0].modulate = Color(1, 0, 0, 1)
			stache_textures[4].visible = true
			stache_textures[0].visible = true
		6:
			stache_textures[0].modulate = Color(0, 0, 0, 1)
			stache_textures[4].modulate = Color(0, 0, 0, 1)

# Sets held item texture to that of the box clicked and lets you drag it around. If let go of above the trash icon,
# drops the item to the left of the player
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Shoot") and mouse_over_box:
		if Globals.ammo_types[active_box] >= 0:
			selected_box = active_box
			held_texture.texture = bullet_textures[Globals.ammo_types[selected_box]]
			held_item.visible = true
			held_item.position = get_viewport().get_mouse_position() - Vector2(60, 60)
			dragging_box = true
	elif Input.is_action_pressed("Shoot") and dragging_box:
		held_item.position = get_viewport().get_mouse_position() - Vector2(60, 60)
	elif Input.is_action_just_released("Shoot"):
		dragging_box = false
		held_item.visible = false
		if mouse_over_trash and selected_box > 0:
			ammo_dropped.emit(Globals.ammo_types[selected_box], Globals.ammo[Globals.ammo_types[selected_box]])
			Globals.ammo[Globals.ammo_types[selected_box]] = 0
			Globals.ammo_types[selected_box] = -1
			set_ammo_types()
		selected_box = -1

# One million signals below to inform the script which inventory box the mouse is hovering over
func _on_area_1_mouse_entered() -> void:
	mouse_over_box = true
	active_box = 0
func _on_area_1_mouse_exited() -> void:
	mouse_over_box = false

func _on_area_2_mouse_entered() -> void:
	mouse_over_box = true
	active_box = 1
func _on_area_2_mouse_exited() -> void:
	mouse_over_box = false

func _on_area_3_mouse_entered() -> void:
	mouse_over_box = true
	active_box = 2
func _on_area_3_mouse_exited() -> void:
	mouse_over_box = false

func _on_area_4_mouse_entered() -> void:
	mouse_over_box = true
	active_box = 3
func _on_area_4_mouse_exited() -> void:
	mouse_over_box = false

func _on_drop_area_mouse_entered() -> void:
	mouse_over_trash = true
func _on_drop_area_mouse_exited() -> void:
	mouse_over_trash = false
