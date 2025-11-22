extends Node

var money = 10

signal money_updated(value: int)

func update_money(num: int):
	if num == 0:
		return
	money += num
	money_updated.emit(money)
