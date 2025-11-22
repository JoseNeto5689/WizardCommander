@tool
extends Button
signal clicked(has_clicked: bool)

@export var card_image : CompressedTexture2D : set = _set_card_image
@onready var sprite = $TextureRect

func _set_card_image(image: CompressedTexture2D):
	card_image = image
	if sprite:
		sprite.texture = image
		
func _ready() -> void:
	sprite.texture = card_image


func _on_button_down() -> void:
	clicked.emit(true)


func _on_button_up() -> void:
	clicked.emit(false)
