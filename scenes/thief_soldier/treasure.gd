extends Node2D

var status = "hided"

@export var animated_sprite_path: NodePath = NodePath("")
@export var animation_name: String = "run"
@export var target_time: float = 2.0
@export var play_on_ready: bool = true
@export var stop_after_duration: bool = false 
@export var restore_speed_after_stop: bool = true

var sprite: AnimatedSprite2D
var _original_speed_scale: float = 1.0

func find_treasure(duration: int):
	if status == "hided":
		play_for_duration("default", duration)
	return false

func start_particles():
	$RightParticles.emitting = true
	$LeftParticles.emitting = true
	
func stop_particles():
	$RightParticles.emitting = false
	$LeftParticles.emitting = false

func _process(_delta: float) -> void:
	if sprite.frame == 1:
		start_particles()
	elif sprite.frame == 6:
		stop_particles()

func _ready() -> void:
	sprite = _find_animated_sprite()
	if not sprite:
		push_warning("AnimatedSprite2D não encontrado. Defina 'animated_sprite_path' ou coloque um AnimatedSprite2D como filho direto.")
		return

	_original_speed_scale = sprite.speed_scale

	if play_on_ready:
		play_for_duration(animation_name, target_time)


func _find_animated_sprite() -> AnimatedSprite2D:
	if animated_sprite_path != NodePath(""):
		if has_node(animated_sprite_path):
			var node = get_node(animated_sprite_path)
			if node is AnimatedSprite2D:
				return node
			else:
				push_warning("O nó apontado por 'animated_sprite_path' não é um AnimatedSprite2D.")
	if has_node("AnimatedSprite2D"):
		var n = get_node("AnimatedSprite2D")
		if n is AnimatedSprite2D:
			return n
	for c in get_children():
		if c is AnimatedSprite2D:
			return c
	return null


func play_for_duration(anim_name: String, duration: float) -> void:
	var frames = sprite.sprite_frames
	if not frames or not frames.has_animation(anim_name):
		push_warning("Animação '%s' não encontrada em sprite_frames." % anim_name)
		return
	var frame_count = frames.get_frame_count(anim_name)
	if frame_count <= 0:
		push_warning("Animação '%s' não possui frames." % anim_name)
		return

	var orig_anim_fps: float = frames.get_animation_speed(anim_name) if frames.has_animation(anim_name) else 1.0
	var fps_needed: float = frame_count / max(duration, 0.0001) 

	if orig_anim_fps <= 0.0:
		orig_anim_fps = 1.0

	sprite.speed_scale = fps_needed / orig_anim_fps
	sprite.animation = anim_name
	sprite.play()

	if stop_after_duration:
		_await_stop_after(duration)


func _await_stop_after(duration: float) -> void:
	var t = get_tree().create_timer(duration)
	await t.timeout
	sprite.stop()
	if restore_speed_after_stop:
		sprite.speed_scale = _original_speed_scale
