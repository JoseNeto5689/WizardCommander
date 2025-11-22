extends CharacterBody2D

class_name Enemy

@export var target : Node2D
@export var SPEED := 0
@export var life = 2

signal dying(body: Node2D)
var direction := Vector2.ZERO

var incombat_enemy : Node2D
var can_move := true
	
func hit():
	life -= 1
	if life <= 0:
		die()

func die():
	queue_free()

func _on_tree_exited() -> void:
	dying.emit(self)
	
func is_in_combat():
	if incombat_enemy == null:
		return false
	return true
