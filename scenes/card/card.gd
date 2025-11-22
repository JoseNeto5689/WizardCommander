@tool
extends Node2D

signal clicked

@export var card_image : CompressedTexture2D : set = _set_card_image
@onready var sprite = $Sprite2D

func _set_card_image(image: CompressedTexture2D):
	card_image = image
	if sprite:
		sprite.texture = image
		
func _ready() -> void:
	sprite.texture = card_image

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked.emit()
