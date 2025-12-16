extends CharacterBody2D

@onready var nav_agent := $NavigationAgent2D
@export var life = 8
@export var SPEED := 50
@export var attack_scene : PackedScene

var spawn_point: Vector2 = Vector2.ZERO
var targets = []
var actual_targets = []
var enemy_in_combat : Enemy
var direction = Vector2.ZERO
var can_move := true

func _ready() -> void:
	spawn_point = global_position
	select_target(null)

func _physics_process(delta: float) -> void:
	if can_move:
		direction = to_local(nav_agent.get_next_path_position()).normalized()
		direction = get_nearest_available_direction(self, direction, 8)
		velocity = direction * SPEED
		move_and_collide(velocity * delta)
		
	if not actual_targets.is_empty():
		start_combat()

func upgrade_by_commander():
	$AttackFrequency.wait_time = 0.3

func hit():
	life -= 1
	if life <= 0:
		die()
		
func die():
	queue_free()

func get_nearest_available_direction(body: CharacterBody2D, desired_dir: Vector2, distance: float = 8.0) -> Vector2:
	if global_position.distance_to(nav_agent.target_position) < 5:
		return Vector2.ZERO
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

func select_target(target: Node2D):
	if target != null:
		nav_agent.target_position = target.global_position
	else:
		nav_agent.target_position = spawn_point
	
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

func start_combat():
	enemy_in_combat = actual_targets.get(0)
	if enemy_in_combat == null:
		return
	if not enemy_in_combat.dying.is_connected(end_combat):
		can_move = false
		enemy_in_combat.enter_combat(self)
		enemy_in_combat.dying.connect(end_combat)
		$AttackFrequency.start()

func end_combat(enemy: Enemy):
	select_target(null)
	can_move = true
	if enemy_in_combat == enemy:
		enemy_in_combat = null

func _on_check_path_timeout() -> void:
	var enemy = get_closer_target_position()
	select_target(enemy)

func _on_attack_frequency_timeout() -> void:
	if enemy_in_combat != null:
		var last_position: Vector2 = enemy_in_combat.global_position - global_position
		var attack = attack_scene.instantiate()
		attack.rotation = (last_position.angle()) + 3*PI/2
		attack.position = last_position
		add_child(attack)


func _on_range_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)


func _on_melee_range_body_entered(body: Node2D) -> void:
	actual_targets.append(body)


func _on_melee_range_body_exited(body: Node2D) -> void:
	actual_targets.erase(body)
	if body == enemy_in_combat:
		end_combat(body)


func _on_navigation_agent_2d_target_reached() -> void:
	call_deferred("reach")
	
func reach():
	global_position = nav_agent.target_position
