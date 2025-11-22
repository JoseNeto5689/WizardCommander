extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_2d_area_entered)
	area_exited.connect(_on_area_2d_area_exited)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.get_parent().name)
	area.get_parent().enter_danger()

func _on_area_2d_area_exited(area: Area2D) -> void:
	area.get_parent().exit_danger()
