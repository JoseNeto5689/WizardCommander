extends Enemy

@onready var nav_agent := $NavigationAgent2D
@export var attack_scene : PackedScene


func _physics_process(_delta: float) -> void:
	if can_move:
		direction = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = direction * SPEED
		move_and_slide()
	
	
func select_target():
	nav_agent.target_position = target.global_position
	
func enter_combat(target : Node2D):
	can_move = false
	incombat_enemy = target

func exit_combat():
	can_move = true
	incombat_enemy = null

func _on_timer_timeout() -> void:
	select_target()
	
func hit():
	life -= 1
	if life <= 0:
		die()

func die():
	queue_free()

func _on_attack_frequency_timeout() -> void:
	if incombat_enemy != null:
		var attack = attack_scene.instantiate()
		var last_position: Vector2 = incombat_enemy.global_position - global_position
		attack.rotation = (last_position.angle()) + 3*PI/2
		attack.position = last_position
		add_child(attack)


func _on_tree_exited() -> void:
	dying.emit(self)
