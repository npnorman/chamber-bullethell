extends "res://scripts/enemy.gd"

@export var distance_diagonal_from_player:float = 100

func perpendicular_line_at_player_position(x,m,player_coordinates):
	return m * (x - player_coordinates.x) + player_coordinates.y

func get_shoot_target():
	
	#alternate between -/+ per shot
	distance_diagonal_from_player *= -1
	
	var player_coordinates : Vector2 = target.global_position
	var enemy_coordinates : Vector2 = global_position
	var m_slope = 0
	var b = 0
	
	if player_coordinates.y - enemy_coordinates.y != 0:
		m_slope = -1 * (player_coordinates.x - enemy_coordinates.x) / (player_coordinates.y - enemy_coordinates.y)
	
	var x_t = player_coordinates.x + (distance_diagonal_from_player / sqrt(pow(m_slope,2) + 1))
	var diagonal_target = Vector2(x_t,perpendicular_line_at_player_position(x_t,m_slope,player_coordinates))
	
	return diagonal_target
