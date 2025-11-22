extends Node2D

var targets = []
@export var projectile_scene : PackedScene
var future_position = Vector2.ZERO

func _on_range_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)
	
func get_closer_target_position():
	var targets_distances = {}
	var distances = []
	for target : CharacterBody2D in targets:
		targets_distances[target] = target.position.distance_to(position)
		distances.append(target.position.distance_to(position))
	distances.sort()
	if targets_distances.size() <= 0:
		return null
	return targets_distances.find_key(distances[0])

func _on_timer_timeout() -> void:
	var enemy = get_closer_target_position()
	if enemy == null:
		return
	var last_position = enemy.global_position - global_position
	future_position = last_position + (enemy.direction.normalized()*enemy.SPEED/4)
	var raycast := $RayCast2D
	raycast.target_position = future_position
	
func _on_ray_cast_2d_can_shoot() -> void:
	var projectile = projectile_scene.instantiate()
	add_child(projectile)
	if future_position < to_local(global_position) :
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
	projectile.launch(future_position.normalized(), global_position)
