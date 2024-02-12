extends VBoxContainer
class_name ColumnInput

@onready var data_store = get_node("/root/DataStore")

@onready var one : NumericLineEdit = $One
@onready var two : NumericLineEdit = $Two
@onready var three : NumericLineEdit = $Three
@onready var four : NumericLineEdit = $Four

var column_size = 4

signal row_changed

func _ready():
	one.text_changed.connect(_on_change)
	two.text_changed.connect(_on_change)
	three.text_changed.connect(_on_change)
	four.text_changed.connect(_on_change)

func set_value(index, value):
	match index:
		0:
			one.text = str(value)
			one.placeholder_text = str(value)
		1:
			two.text = str(value)
			two.placeholder_text = str(value)
		2:
			three.text = str(value)
			three.placeholder_text = str(value)
		3:
			four.text = str(value)
			four.placeholder_text = str(value)

func set_score_value(index, value):
	set_value(index, data_store.score_format(value) % [abs(value)])

func get_value(index):
	match index:
		0:
			return one.get_value()
		1:
			return two.get_value()
		2:
			return three.get_value()
		3:
			return four.get_value()

func get_value_arr():
	var values = [one.get_value(), two.get_value(), three.get_value()]
	if column_size == 4:
		values.append(four.get_value())
	return values

func _on_change(_new_text : String):
	row_changed.emit()

func set_column_size(new_size : int):
	if new_size != column_size:
		column_size = new_size
		if column_size == 3:
			four.visible = false
		else:
			four.visible = true