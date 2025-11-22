extends Node2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO
@export var points_of_damage := 0
@export var penetration := 3



func launch(dir: Vector2, parent_position) -> void:
	direction = dir.normalized()
	look_at(dir + parent_position)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func damage():
	return points_of_damage


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hit()
	penetration -= 1
	if penetration <= 0:
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()


func _on_property_list_changed() -> void:
	pass # Replace with function body.
