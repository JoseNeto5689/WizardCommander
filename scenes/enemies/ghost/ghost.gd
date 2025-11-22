extends Enemy

func _physics_process(_delta: float) -> void:
	if can_move:
		direction = (target.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()

func random_point_at_distance(origin: Vector2, distance: float) -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * distance
	return origin + offset

func enter_combat(target: Node2D):
	can_move = false

func hit():
	life -= 1
	can_move = true
	dying.emit(self)
	global_position = random_point_at_distance(target.global_position, global_position.distance_to(target.global_position))
	if life <= 0:
		die()
