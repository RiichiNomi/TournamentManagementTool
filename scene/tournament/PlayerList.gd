extends Tree
class_name PlayerList

@onready var data_store = get_node("/root/DataStore")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_column_title(0, "Player ID")
	set_column_title(1, "Player Name")
	set_column_title(2, "Affiliation")
	set_column_title(3, "Score")

	set_column_custom_minimum_width(0, 0)
	set_column_custom_minimum_width(1, 200)
	set_column_custom_minimum_width(2, 100)
	set_column_custom_minimum_width(3, 0)

func selected_id() -> int:
	var selected = get_selected()
	if selected:
		return int(selected.get_text(0))
	return 0

func render_players() -> void:
	clear()
	create_item()

	var scores = data_store.get_scores()
	for player in data_store.tournament.registered_players:
		var row = create_item()

		row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
		row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
		row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)

		row.set_text(0, str(player.id))
		row.set_text(1, player.name)
		row.set_text(2, player.affiliation)
		row.set_text(3, "%.1f" % [scores.get(player.id, 0)])

		row.set_editable(0, false)
		row.set_editable(1, false)
		row.set_editable(2, false)
		row.set_editable(3, false)