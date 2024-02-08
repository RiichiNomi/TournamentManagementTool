extends VBoxContainer
class_name ColumnIdInput

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var one : SpinBox = $One
@onready var two : SpinBox = $Two
@onready var three : SpinBox = $Three
@onready var four : SpinBox = $Four

signal id_changed

func _ready():
	one.value_changed.connect(on_changed.bind(0))
	two.value_changed.connect(on_changed.bind(1))
	three.value_changed.connect(on_changed.bind(2))
	four.value_changed.connect(on_changed.bind(3))

	data_store.players_updated.connect(on_players_updated)
	on_players_updated()

func set_value(index, value):
	match index:
		0:
			one.value = value
		1:
			two.value = value
		2:
			three.value = value
		3:
			four.value = value

func get_value_arr():
	return [one.value, two.value, three.value, four.value]

func on_changed(value, index):
	id_changed.emit(value, index)

func on_players_updated():
	var max_id = 0

	for player_id in data_store.players_by_id:
		if player_id > max_id:
			max_id = player_id
	
	one.max_value = max_id
	two.max_value = max_id
	three.max_value = max_id
	four.max_value = max_id