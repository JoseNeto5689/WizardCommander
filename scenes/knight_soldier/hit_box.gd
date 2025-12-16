extends Node2D

signal enemy_hited

func _on_area_2d_body_entered(body: Node2D) -> void:
	body.hit()
	enemy_hited.emit()

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func select_target_layer(layer, status):
	$Area2D.set_collision_mask_value(layer, status)
