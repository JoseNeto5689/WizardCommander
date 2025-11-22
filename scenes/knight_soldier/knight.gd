extends Node2D

var targets = []
@export var projectile_scene : PackedScene
var hit_box_scene : PackedScene = preload("res://scenes/knight_soldier/hit_box.tscn")


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
	print(enemy)
	if enemy == null:
		return
	var last_position: Vector2 = enemy.global_position - global_position
	#var future_position: Vector2 = last_position + (enemy.direction.normalized()*enemy.SPEED/4)
	var hit_box = hit_box_scene.instantiate()
	hit_box.rotation = (last_position.angle()) + 3*PI/2
	#var distance = last_position.normalized() * $Range/CollisionShape2D.shape.radius
	#hit_box.position += distance
	if last_position < to_local(global_position):
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
	hit_box.position = last_position
	add_child(hit_box)
