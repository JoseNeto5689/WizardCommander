extends CharacterBody2D

var direction := Vector2.ZERO
var draggable_has_exited_area := false
const SPEED = 100.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction.normalized() * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().exit_danger()


func _on_area_2d_area_exited(area: Area2D) -> void:
	area.get_parent().enter_danger()
