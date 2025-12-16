extends Node

var money = 10

var commander := ""
signal commander_updated(commander_name: String)

signal money_updated(value: int)

func update_money(num: int):
	if num == 0:
		return
	money += num
	money_updated.emit(money)
	
func update_commander(new_commander: String):
	commander = new_commander
	commander_updated.emit(commander)
