extends VBoxContainer
class_name ColumnLabel

@onready var one : Label = $One
@onready var two : Label = $Two
@onready var three : Label = $Three
@onready var four : Label = $Four

func set_text(index, value):
	match index:
		0:
			one.text = value
		1:
			two.text = value
		2:
			three.text = value
		3:
			four.text = value