extends Bullet

var area_damage: int = 4
var explosive: bool

func _ready():
	$DespawnTimer.start()
	if bullet_id == Globals.Bullets.Railgun:
		$Sprite2D.visible = false
		speed = 0
		railgun()

func _on_body_entered(body: Node2D) -> void:
	if can_collide:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		if explosive:
			explode()
		elif ricochets == 0:
			self.queue_free()
		else:
			self.position = collision_point
			self.direction = self.direction.bounce(collision_normal).normalized()
			self.rotation_degrees = rad_to_deg(self.direction.angle()) + 90
			ricochets -= 1
			if bullet_id == Globals.Bullets.Ricochet:
				damage *= 2
			can_collide = false
			found_angle = false
			$CollisionTimer.start()

func explode() -> void:
	speed = 0
	$PointLight2D.visible = false
	$Explosion.visible = true
	$Sprite2D.visible = false
	$Explosion/ExplosionParticles.emitting = true
	$DespawnTimer.stop()
	$DespawnTimer.wait_time = 1
	$DespawnTimer.start()
	var bodies_hit = $Explosion.get_overlapping_bodies()
	for body in bodies_hit:
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				body.take_damage(area_damage)

func railgun() -> void:
	$PointLight2D.visible = false
	var exceptions: Array[Object]
	$RailCast.visible = true
	$RailCast.force_raycast_update()
	var railgun_end: float = ($RailCast.get_collision_point() - $RailCast.global_position).length()
	if railgun_end == 0:
		railgun_end = -($RailCast.target_position.y)
	$RailCast.target_position.y = (railgun_end * -1)
	$RailCast/Line2D.points[1].y = (railgun_end * -1)
	$RailCast.set_collision_mask_value(3, true)
	$RailCast.set_collision_mask_value(4, true)
	$RailCast.set_collision_mask_value(1, false)
	$RailCast.force_raycast_update()
	while $RailCast.is_colliding():
		var collider: Object = $RailCast.get_collider()
		if collider.has_method("take_damage"):
			collider.take_damage(damage)
		exceptions.append(collider)
		$RailCast.add_exception(collider)
		$RailCast.force_raycast_update()
	for object in exceptions:
		$RailCast.remove_exception(object)
	var tween = create_tween()
	var end_color = Color(0,1,1,0)
	tween.tween_property($RailCast, "modulate", end_color, 0.5).set_trans(Tween.TRANS_EXPO)
