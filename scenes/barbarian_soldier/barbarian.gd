extends CharacterBody2D

var targets = []

@export var SPEED := 50
@export var attack_scene : PackedScene
@onready var nav_agent := $NavigationAgent2D
@export var life = 2

signal dying(body: Node2D)

var is_a_close_enemy := false 
var direction := Vector2.ZERO
var incombat_enemy : Node2D
var can_move := true
var spawn_point : Vector2
var going_home = false

func get_nearest_available_direction(body: CharacterBody2D, desired_dir: Vector2, distance: float = 8.0) -> Vector2:
	var directions = [
		Vector2(0, -1),                       
		Vector2(1, -1).normalized(),          
		Vector2(1, 0),                        
		Vector2(1, 1).normalized(),           
		Vector2(0, 1),                        
		Vector2(-1, 1).normalized(),          
		Vector2(-1, 0),                       
		Vector2(-1, -1).normalized()          
	]
	var available = []
	for dir in directions:
		var motion = dir * distance
		if not body.test_move(body.transform, motion):
			available.append(dir)
	if available.is_empty():
		return Vector2.ZERO
	var desired = desired_dir.normalized()
	var best_dir = available[0]
	var best_dot = -1.0
	for dir in available:
		var dot = desired.dot(dir)
		if dot > best_dot:
			best_dot = dot
			best_dir = dir
	return best_dir

func hit():
	life -= 1
	if life <= 0:
		die()

func die():
	dying.emit(self)
	queue_free()

func _ready() -> void:
	spawn_point = Vector2(global_position)

func _physics_process(delta: float) -> void:
	if incombat_enemy != null:
		if (incombat_enemy.global_position as Vector2).distance_to(global_position) >= $Range/CollisionShape2D.shape.radius:
				enemy_ran_away(true)
	if spawn_point.round().distance_to(global_position.round()) < 5 and spawn_point.round().distance_to(global_position.round()) != 0 and incombat_enemy == null and targets.is_empty() and going_home == false:
		global_position = spawn_point
		direction = Vector2.ZERO
	if (is_a_close_enemy and can_move) or (not is_a_close_enemy and can_move and targets.is_empty() and global_position != spawn_point):
		direction = to_local(nav_agent.get_next_path_position()).normalized()
		direction = get_nearest_available_direction(self, direction, 8)
		velocity = direction * SPEED
		move_and_collide(velocity * delta)

	
func enemy_died(enemy: Enemy):
	if enemy == incombat_enemy:
		incombat_enemy = null
	if enemy in targets:
		targets.erase(enemy)
	
	if incombat_enemy == null and is_a_close_enemy == false:
		nav_agent.target_position = spawn_point
	
func select_target(target: Node2D):
	nav_agent.target_position = target.global_position

func _on_range_body_entered(body: Node2D) -> void:
	targets.append(body)

func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)
	
func get_closer_target_position():
	var targets_distances = {}
	var distances = []
	for target : CharacterBody2D in targets:
		targets_distances[target] = target.position.distance_to(position)
		distances.append(target.position.distance_to(position))
	distances.sort()
	if targets_distances.size() <= 0:
		return null
	return targets_distances.find_key(distances[0])

func _on_timer_timeout() -> void:
	find_enemy()
	if targets.is_empty():
		nav_agent.target_position = spawn_point

func find_enemy():
	var enemy = get_closer_target_position()
	if enemy:
		is_a_close_enemy = true
		select_target(enemy)
	else:
		is_a_close_enemy = false
		
func enter_combat(target : Node2D):
	can_move = false
	incombat_enemy = target

func exit_combat(body : Node2D):
	can_move = true
	if incombat_enemy and dying.is_connected(incombat_enemy.exit_combat):
		dying.disconnect(incombat_enemy.exit_combat)
	nav_agent.target_position = spawn_point
	direction = Vector2.ZERO
	incombat_enemy = null
	find_enemy()
		

func enemy_ran_away(teleported: bool):
	can_move = true
	direction = Vector2.ZERO
	if incombat_enemy.has_method("exit_combat") and dying.is_connected(incombat_enemy.exit_combat):
		dying.disconnect(incombat_enemy.exit_combat)
	incombat_enemy = null
	is_a_close_enemy = false
	nav_agent.target_position = spawn_point
	if not teleported:
		find_enemy()

func _on_melee_range_body_entered(body: Node2D) -> void:
	if body.has_method("enter_combat"):
		if incombat_enemy == null:
			body.enter_combat(self)
	if incombat_enemy == null:
		enter_combat(body)
	if not body.dying.is_connected(exit_combat) and not dying.has_connections():
		body.dying.connect(exit_combat)
		
func _on_melee_range_body_exited(body: Node2D) -> void:
	if body == incombat_enemy:
		enemy_ran_away(false)

func _on_attack_frequency_timeout() -> void:
	if incombat_enemy != null:
		var attack = attack_scene.instantiate()
		var last_position: Vector2 = incombat_enemy.global_position - global_position
		attack.rotation = (last_position.angle()) + 3*PI/2
		attack.position = last_position
		add_child(attack)


func _on_navigation_agent_2d_target_reached() -> void:
	pass
