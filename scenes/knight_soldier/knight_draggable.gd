extends Node2D

var selected := true
var type := ""
var inside_dangerous_area = 1

func enter_danger():
	inside_dangerous_area += 1

func exit_danger():
	inside_dangerous_area -= 1

func select():
	selected = true

func _on_area_2d_body_entered(_body: Node2D) -> void:
	inside_dangerous_area += 1


func _on_area_2d_body_exited(_body: Node2D) -> void:
	inside_dangerous_area -= 1

func _process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 20 * delta)
