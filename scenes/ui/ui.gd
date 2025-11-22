extends CanvasLayer

func _ready() -> void:
	change_money_value(Global.money)

func change_money_value(value: int):
	var text = str(value)
	var zeros = 4 - text.length()
	for i in range(zeros):
		text = text.insert(0, "0")
	$UI/Hud/Money/Label.text = text
