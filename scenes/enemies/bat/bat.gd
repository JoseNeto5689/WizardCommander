extends Enemy

@onready var nav_agent := $NavigationAgent2D
@export var attack_scene : PackedScene

var targets = []
var target_player = null


func find_target():
	if not targets.is_empty():
		target_player = targets[0]
		nav_agent.target_position = target_player.global_position
		
	else:
		nav_agent.target_position = target.global_position


func _physics_process(_delta: float) -> void:
	if can_move:
		direction = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = direction * SPEED
		move_and_slide()
	
	
func enter_combat(target : Node2D):
	can_move = false
	incombat_enemy = target

func exit_combat():
	can_move = true
	incombat_enemy = null
	
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
		return
	if target_player != null and global_position.distance_to(target_player.global_position) <= $CheckPlayersCloseRange/CollisionShape2D.shape.radius * 2:
		var attack = attack_scene.instantiate()
		attack.select_target_layer(1, true)
		var last_position: Vector2 = target_player.global_position - global_position
		attack.rotation = (last_position.angle()) + 3*PI/2
		attack.position = last_position
		add_child(attack)


func _on_tree_exited() -> void:
	dying.emit(self)


func _on_check_players_area_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_check_players_area_body_exited(body: Node2D) -> void:
	targets.erase(body)


func _on_find_player_timeout() -> void:
	find_target()


func _on_check_players_close_range_body_entered(body: Node2D) -> void:
	if body == target_player:
		can_move = false


func _on_check_players_close_range_body_exited(body: Node2D) -> void:
	if body == target_player:
		can_move = true
