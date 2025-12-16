extends Node2D

@export var monster : PackedScene
@export var target : Node2D
@export var interval := 0

func _ready() -> void:
	$Timer.wait_time = interval

func _on_timer_timeout() -> void:
	var monster_instantiated : Enemy = monster.instantiate()
	monster_instantiated.target = target
	add_child(monster_instantiated)
