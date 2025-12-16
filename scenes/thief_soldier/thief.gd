extends CharacterBody2D

@onready var timer := $Timer
@onready var progress_bar := $ProgressBar
@onready var nav_agent := $NavigationAgent2D

@export var validade := false

@export var SPEED := 0

var spawn_point: Vector2 = Vector2.ZERO
var direction := Vector2.ZERO
var target_treasure = null
var can_move = false
var treasures = []
var target_reached = null

func _ready() -> void:
	spawn_point = global_position
	select_target(spawn_point)
	await get_tree().create_timer(3).timeout
	get_treasures()
	go_to_treasure()
	
func get_treasures():
	treasures = get_tree().get_nodes_in_group("treasure")
	var new_list = []
	for item in treasures:
		if not item.choosed:
			new_list.append(item)
	treasures = new_list
	
func go_to_treasure():
	if treasures.is_empty():
		select_target(spawn_point)
		can_move = true
	else:
		target_treasure = treasures[0]
		target_treasure.choosed = true
		tree_exited.connect(target_treasure.stop_animation)
		timer.wait_time = target_treasure.duration
		select_target(target_treasure.global_position)
		can_move = true

func update_facing(next_direction: Vector2) -> void:
	if next_direction.x > 0:
		$Sprite2D.flip_h = false
	elif next_direction.x < 0:
		$Sprite2D.flip_h = true


func _physics_process(delta: float) -> void:
	progress_bar.value = get_percentage()
	if can_move:
		direction = to_local(nav_agent.get_next_path_position()).normalized()
		direction = get_nearest_available_direction(self, direction, 8)
		update_facing(direction)
		velocity = direction * SPEED
		move_and_collide(velocity * delta)
	
func get_percentage() -> int:
	return abs(int(100-(timer.time_left/timer.wait_time)*100))
	
func get_nearest_available_direction(body: CharacterBody2D, desired_dir: Vector2, distance: float = 8.0) -> Vector2:
	if global_position.distance_to(nav_agent.target_position) < 3:
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

func select_target(pos: Vector2):
	if pos != null:
		nav_agent.target_position = pos
	else:
		nav_agent.target_position = spawn_point

func _on_navigation_agent_2d_target_reached() -> void:
	if nav_agent.target_position == spawn_point:
		can_move = false
		target_reached = nav_agent.target_position
		return
	
	if nav_agent.target_position != target_reached :
		can_move = false
		progress_bar.visible = true
		target_reached = nav_agent.target_position
		$Timer.wait_time = target_treasure.duration
		timer.start()
		target_treasure.play_for_duration("default")
		return

func _on_timer_timeout() -> void:
	if global_position != spawn_point and target_treasure != null:
		await get_tree().create_timer(0.5).timeout
		can_move = true
		progress_bar.hide()
		get_treasures()
		go_to_treasure()


func _on_auto_destruct_timeout() -> void:
	if validade:
		queue_free()
