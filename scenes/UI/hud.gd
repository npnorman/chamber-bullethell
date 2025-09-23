extends CanvasLayer

@export var is_rotating: bool = false

func _process(_delta):
	if is_rotating:
		$CylinderNode/CylinderContainer.rotation_degrees += 5
		if roundi($CylinderNode/CylinderContainer.rotation_degrees) % 60 == 0:
			is_rotating = false

func start_rotating():
	is_rotating = true
