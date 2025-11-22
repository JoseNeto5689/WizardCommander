extends RayCast2D

var unable_to_shoot := false
signal can_shoot

func _process(_delta: float) -> void:
	if is_colliding() and not unable_to_shoot:
		var collider = get_collider()
		if collider is CollisionObject2D:
			var layer = collider.collision_layer
			if layer == 4:
				can_shoot.emit()
				unable_to_shoot = true
				target_position = Vector2.ZERO
				enabled = false
	if target_position == Vector2.ZERO:
		unable_to_shoot = false
		enabled = true
