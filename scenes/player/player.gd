extends CharacterBody2D

var direction := Vector2.ZERO
var draggable_has_exited_area := false
var life = 3
const SPEED = 100.0

@export var kinght_commander_skin : Texture2D
@export var thief_commander_skin : Texture2D
@export var mage_commander_skin : Texture2D
@export var barbarian_commander_skin : Texture2D
@export var archer_commander_skin : Texture2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction.normalized() * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().exit_danger()


func _on_area_2d_area_exited(area: Area2D) -> void:
	area.get_parent().enter_danger()
	
func hit():
	life -= 1
	if life <= 0:
		die()

func die():
	queue_free()


func _on_timer_timeout() -> void:
	$Sprite2D.texture = kinght_commander_skin
	Global.update_commander("knight")
