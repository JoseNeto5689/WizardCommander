extends Node2D

var status = "hided"
var target_time: float = 2.0
var frame_count = 0
var orig_anim_fps = 0
var choosed := false
var thief : CharacterBody2D = null

@export var duration := 0.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func set_thief(body: CharacterBody2D):
	thief = body
	print(thief)

func find_treasure():
	if status == "hided":
		play_for_duration("default")
		return duration
	continue_animation()
	return $Timer.time_left

func _ready() -> void:
	$Timer.wait_time = duration

func stop_animation():
	choosed = false
	stop_particles()
	sprite.pause()
	$Timer.paused = true
	duration = $Timer.time_left

func continue_animation():
	sprite.pause()

func play_for_duration(anim_name: String) -> void:
	var frames = sprite.sprite_frames
	if not frames or not frames.has_animation(anim_name):
		push_warning("Animação '%s' não encontrada em sprite_frames." % anim_name)
		return
	frame_count = frames.get_frame_count(anim_name)
	if frame_count <= 0:
		push_warning("Animação '%s' não possui frames." % anim_name)
		return

	orig_anim_fps = frames.get_animation_speed(anim_name) if frames.has_animation(anim_name) else 1.0
	var fps_needed: float = frame_count / max(duration, 0.0001) 

	if orig_anim_fps <= 0.0:
		orig_anim_fps = 1.0
	
	sprite.speed_scale = fps_needed / orig_anim_fps
	sprite.animation = anim_name
	$Timer.start()
	sprite.play()
		
func start_particles():
	$RightParticles.emitting = true
	$LeftParticles.emitting = true
	
func stop_particles():
	$RightParticles.emitting = false
	$LeftParticles.emitting = false

func _process(_delta: float) -> void:
	match sprite.frame:
		0:
			status = "hided"
		1:
			status = "opening 1"
			start_particles()
		2:
			status = "opening 2"
		3:
			status = "opening 3"
		4:
			status = "opening 4"
		5:
			status = "opening 5"
		6: 
			status = "opening 6"
			stop_particles()
		7: 
			status = "opened"
		
