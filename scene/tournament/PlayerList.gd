extends Tree
class_name PlayerList

@onready var data_store : DataStore = get_node("/root/DataStore")

func _ready():
	set_column_title(0, "Player ID")
	set_column_title(1, "Player Name")
	set_column_title(2, "Affiliation")
	set_column_title(3, "Score")

	set_column_custom_minimum_width(0, 0)
	set_column_custom_minimum_width(1, 200)
	set_column_custom_minimum_width(2, 100)
	set_column_custom_minimum_width(3, 0)

	data_store.players_updated.connect(render_players)
	render_players()

	empty_clicked.connect(_empty_clicked)
	nothing_selected.connect(_clear_selection)

func selected_id() -> int:
	var selected = get_selected()
	if selected:
		return int(selected.get_text(0))
	return 0

func _empty_clicked(_position, _mouse_button_index):
	deselect_all()

func _clear_selection():
	deselect_all()

func render_players() -> void:
	clear()
	create_item()

	var scores = data_store.get_scores()
	for player in data_store.tournament.registered_players:
		var row = create_item()

		row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
		row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
		row.set_cell_mode(3, TreeItem.CELL_MODE_STRING)

		row.set_text(0, str(player.id))
		row.set_text(1, player.name)
		row.set_text(2, player.affiliation)
		row.set_text(3, "%.1f" % [scores.get(player.id, 0)])

		row.set_editable(0, false)
		row.set_editable(1, false)
		row.set_editable(2, false)
		row.set_editable(3, false)