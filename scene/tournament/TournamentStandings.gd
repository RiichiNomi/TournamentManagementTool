extends MarginContainer
class_name TournamentStandings

@onready var player_table = $Standings/PlayerListContainer/PlayerList
@onready var hanchan_table = $Standings/HanchanHistoryContainer/HanchanHistory

@onready var data_store = get_node("/root/DataStore")

# Called when the node enters the scene tree for the first time.
func _ready():
	player_table.set_column_title(0, "Player ID")
	player_table.set_column_title(1, "Player Name")
	player_table.set_column_title(2, "Affiliation")
	player_table.set_column_title(3, "Score")

	player_table.set_column_custom_minimum_width(0, 0)
	player_table.set_column_custom_minimum_width(1, 200)
	player_table.set_column_custom_minimum_width(2, 100)
	player_table.set_column_custom_minimum_width(3, 0)

	render()

	data_store.standings_updated.connect(_on_standings_updated)
	player_table.item_selected.connect(_on_player_selected)

func render() -> void:
	render_players()
	render_hanchan()

func render_players() -> void:
	player_table.clear()
	player_table.create_item()

	var scores = data_store.get_scores()
	for player in data_store.tournament.registered_players:
		var row = player_table.create_item()

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

func render_hanchan() -> void:
	hanchan_table.clear()
	hanchan_table.create_item()

	var selected_row = player_table.get_selected()
	var hanchan_history = []
	if selected_row:
		var selected_id = int(player_table.get_selected().get_text(0))
		hanchan_history = data_store.get_hanchan_history_for_player(selected_id)
	else:
		hanchan_history = data_store.get_hanchan_history()

	for table in hanchan_history:
		# TODO show this in the tree
		pass

func _on_standings_updated() -> void:
	render()

func _on_player_selected() -> void:
	render_hanchan()