extends VBoxContainer
class_name ColumnPicker

@onready var one : OptionButton = $One
@onready var two : OptionButton = $Two
@onready var three : OptionButton = $Three
@onready var four : OptionButton = $Four

signal row_changed

func _ready():
	one.item_selected.connect(_on_wind_changed)
	two.item_selected.connect(_on_wind_changed)
	three.item_selected.connect(_on_wind_changed)
	four.item_selected.connect(_on_wind_changed)

func set_value(index, value):
	match index:
		0:
			one.selected = value
		1:
			two.selected = value
		2:
			three.selected = value
		3:
			four.selected = value

func get_value(index):
	match index:
		0:
			return one.selected
		1:
			return two.selected
		2:
			return three.selected
		3:
			return four.selected

func get_value_arr():
	return [one.selected, two.selected, three.selected, four.selected]

func _on_wind_changed(_selected):
	row_changed.emit()