extends Node2D

@export var mage_scene : PackedScene
@export var mage_draggable : PackedScene

@export var knight_scene : PackedScene
@export var knight_draggable : PackedScene

@export var barbarian_scene : PackedScene
@export var barbarian_draggable : PackedScene

@export var archer_scene : PackedScene
@export var archer_draggable : PackedScene

@export var thief_scene : PackedScene
@export var thief_draggable : PackedScene

@export var knight_cost := 0
@export var barbarian_cost := 0
@export var mage_cost := 0
@export var archer_cost := 0
@export var thief_cost := 0

var actual_soldier = null
var current_class = ""

func _ready() -> void:
	Global.money_updated.connect($UI.change_money_value)
	Global.commander_updated.connect(commander_update)

func commander_update(commander_name: String):
	var soldiers = get_tree().get_nodes_in_group("soldier")
	for soldier in soldiers:
		soldier.upgrade_by_commander()
	print(soldiers)

func update_money(value: int) -> bool:
	if Global.money - value < 0:
		return false
	Global.update_money(-value)
	return true

func spawn_draggable_soldier(soldier_draggable_scene: PackedScene):
	var soldier = soldier_draggable_scene.instantiate()
	soldier.global_position = get_global_mouse_position()
	add_child(soldier)
	actual_soldier = soldier
	soldier.select()
	
func spawn_soldier(soldier_scene: PackedScene):
	var soldier = soldier_scene.instantiate()
	soldier.position = Vector2i(get_global_mouse_position())
	$Soldiers.add_child(soldier)
	
func clear_actual_soldier():
	actual_soldier.queue_free()
	actual_soldier = null
	
func _unhandled_input(event: InputEvent) -> void:
	if actual_soldier != null and event.is_action_released("click"):
		if actual_soldier.inside_dangerous_area != 0 or current_class == "":
			clear_actual_soldier()
			return
		
		match current_class:
			"mage":
				spawn_soldier(mage_scene)
			"knight":
				spawn_soldier(knight_scene)
		current_class = ""
		clear_actual_soldier()
		
func spawn_mage_draggable() -> void:
	spawn_draggable_soldier(mage_draggable)
	current_class = "mage"


func spawn_knight_draggable() -> void:
	spawn_draggable_soldier(knight_draggable)
	current_class = "knight"
	
func spawn_archer_draggable() -> void:
	spawn_draggable_soldier(archer_draggable)
	current_class = "archer"
	
func spawn_thief_draggable() -> void:
	spawn_draggable_soldier(thief_draggable)
	current_class = "thief"
	
func spawn_barbarian_draggable() -> void:
	spawn_draggable_soldier(barbarian_draggable)
	current_class = "barbarian"

func spawn_from_draggable():
	if actual_soldier != null:
		if actual_soldier.inside_dangerous_area != 0 or current_class == "":
			clear_actual_soldier()
			return
		match current_class:
			"mage":
				if update_money(mage_cost):
					spawn_soldier(mage_scene)
			"knight":
				if update_money(knight_cost):
					spawn_soldier(knight_scene)
			"barbarian":
				if update_money(barbarian_cost):
					spawn_soldier(barbarian_scene)
			"thief":
				if update_money(thief_cost):
					spawn_soldier(thief_scene)
			"archer":
				if update_money(archer_cost):
					spawn_soldier(archer_scene)	
			
		current_class = ""
		clear_actual_soldier()


func _on_knight_card_clicked(has_clicked: bool) -> void:
	if has_clicked == true:
		spawn_knight_draggable()
	else:
		spawn_from_draggable()


func _on_mage_card_clicked(has_clicked: bool) -> void:
	if has_clicked == true:
		spawn_mage_draggable()
	else:
		spawn_from_draggable()
		
		
func _on_barbarian_card_clicked(has_clicked: bool) -> void:
	if has_clicked == true:
		spawn_barbarian_draggable()
	else:
		spawn_from_draggable()

func _on_archer_card_clicked(has_clicked: bool) -> void:
	if has_clicked == true:
		spawn_archer_draggable()
	else:
		spawn_from_draggable()


func _on_thief_card_clicked(has_clicked: bool) -> void:
	if has_clicked == true:
		spawn_thief_draggable()
	else:
		spawn_from_draggable()

func _process(_delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var soldiers = get_tree().get_nodes_in_group("soldier")
	for enemy: Enemy in enemies:
		for soldier in soldiers:
			if not enemy.dying.is_connected(soldier.enemy_died):
				enemy.dying.connect(soldier.enemy_died)
