extends Node2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO
@export var points_of_damage := 0


func launch(dir: Vector2, parent_position) -> void:
	direction = dir.normalized()
	look_at(dir + parent_position)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func damage():
	return points_of_damage


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hit()
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
