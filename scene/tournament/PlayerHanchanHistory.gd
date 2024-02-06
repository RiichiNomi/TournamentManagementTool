extends Tree
class_name PlayerHanchanHistory

@onready var data_store = get_node("/root/DataStore")

var shuugi
var player_inspected : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	shuugi = data_store.tournament.settings.shuugi
	if shuugi:
		columns = 5

		set_column_title(0, "Player ID")
		set_column_title(1, "Player Name")
		set_column_title(2, "Points")
		set_column_title(3, "Shuugi")
		set_column_title(4, "Score")

		set_column_custom_minimum_width(0, 0)
		set_column_custom_minimum_width(1, 200)
		set_column_custom_minimum_width(2, 0)
		set_column_custom_minimum_width(3, 0)
		set_column_custom_minimum_width(4, 0)
	else:
		columns = 4

		set_column_title(0, "Player ID")
		set_column_title(1, "Player Name")
		set_column_title(2, "Points")
		set_column_title(3, "Score")

		set_column_custom_minimum_width(0, 0)
		set_column_custom_minimum_width(1, 200)
		set_column_custom_minimum_width(2, 0)
		set_column_custom_minimum_width(3, 0)
	
	render()

func inspect_player(player_id : int) -> void:
	player_inspected = player_id
	render()

func render() -> void:
	clear()
	create_item()

	var hanchan_history = []
	if player_inspected == 0:
		hanchan_history = data_store.get_hanchan_history()
	else:
		hanchan_history = data_store.get_hanchan_history_for_player(player_inspected)

	for table in hanchan_history:
		var table_scores = table.score_table(data_store.tournament.settings)

		var table_row : TreeItem = create_item()
		table.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		if table.round_id == 0:
			table_row.set_text(0, "Table %d" % table.table_id)
		else:
			table_row.set_text(0, "Round %d, Table %d" % [table.table_id, table.round_id])
		table_row.set_editable(0, false)
		
		for index in range(table.player_ids.size()):
			var player_row = table_row.create_child()
			var player_data = data_store.get_player_data(table.player_ids[index])

			player_row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
			player_row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			player_row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
			player_row.set_cell_mode(3, TreeItem.CELL_MODE_STRING)
			if shuugi:
				player_row.set_cell_mode(4, TreeItem.CELL_MODE_STRING)
			
			player_row.set_text(0, str(player_data.player_id))
			player_row.set_text(1, player_data.name)
			player_row.set_text(2, str(table.final_scores[index]))
			var player_score = table_scores[player_data.player_id]
			var score_string = "%.1f" % [player_score] if player_score >= 0 else "(%.1f)" % [abs(player_score)]
			if shuugi:
				player_row.set_text(3, str(table.final_shuugi[index]))
				player_row.set_text(4, score_string)
			else:
				player_row.set_text(3, score_string)
			
			player_row.set_editable(0, false)
			player_row.set_editable(1, false)
			player_row.set_editable(2, false)
			player_row.set_editable(3, false)
			if shuugi:
				player_row.set_editable(4, false)