extends HBoxContainer
class_name RoundManagement

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var pairings_pane : VBoxContainer = $PairingsContainer
@onready var pairings_tree : PairingsList = $PairingsContainer/PairingsListContainer/PairingsList
@onready var players_pane : VBoxContainer = $ActivePlayersContainer

@onready var confirm_pane : HBoxContainer = $ControlsContainer/ConfirmRound
@onready var start_round_button : Button = $ControlsContainer/ConfirmRound/StartRoundButton
@onready var cancel_button : Button = $ControlsContainer/ConfirmRound/CancelRoundButton

@onready var settings_pane : RoundManagementSettings = $ControlsContainer/Settings
@onready var create_pairings_button : Button = $ControlsContainer/CreatePairingsButton

func _ready():
	create_pairings_button.pressed.connect(_on_create_pairings)

	cancel_button.pressed.connect(_on_cancel)
	start_round_button.pressed.connect(_on_accept_pairing)

func _on_create_pairings() -> void:
	var pairing_settings : RoundManagementSettings.RoundPairingSettings = settings_pane.get_settings()

	randomize()

	if data_store.tournament.settings.pairing_system == TournamentSettings.PairingSystem.RANDOM:
		_create_random_pairings(pairing_settings)
	elif data_store.tournament.settings.pairing_system == TournamentSettings.PairingSystem.PROGRESSIVE_SWISS:
		_create_swiss_pairings(pairing_settings)
	
	pairings_pane.visible = true
	players_pane.visible = false

	settings_pane.visible = false
	confirm_pane.visible = true
	create_pairings_button.visible = false

func _on_cancel():
	_reset_ui()

func _on_accept_pairing():
	var pairing_settings : RoundManagementSettings.RoundPairingSettings = settings_pane.get_settings()

	data_store.add_round(pairings_tree.export_tables())

	data_store.start_round(pairing_settings.time_per_round_minutes * 60)

	_reset_ui()

func _reset_ui():
	pairings_pane.visible = false
	players_pane.visible = true

	settings_pane.visible = true
	confirm_pane.visible = false
	create_pairings_button.visible = true

func _create_random_pairings(pairing_settings : RoundManagementSettings.RoundPairingSettings):
	var player_objects = data_store.tournament.registered_players.duplicate()
	var players = []

	for player in player_objects:
		players.append(player.id)

	var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

	var byes = []

	if pairing_settings.assign_subs and players.size() % table_size != 0:
		var subs_needed = table_size - (players.size() % table_size)
		for i in range(subs_needed):
			players.append(0)
	else:
		var byes_num = players.size() % table_size
		players.shuffle()

		byes.append_array(players.slice(players.size() - byes_num))

		players.resize(players.size() - byes_num)

	var tables = _pairings_to_tables(pairing_settings, _create_pairings_for_block(pairing_settings, players))

	pairings_tree.render(tables, byes)
	
func _create_swiss_pairings(pairing_settings : RoundManagementSettings.RoundPairingSettings):
	var player_objects = data_store.tournament.registered_players.duplicate()

	var players = []
	var scores = data_store.get_scores()

	for player in player_objects:
		players.append(player.id)

	players.sort_custom(func(a, b): return scores.get(a, 0) > scores.get(b, 0))

	var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

	var byes_num = players.size() % table_size

	var byes = []

	if pairing_settings.assign_subs and byes_num != 0:
		var subs_needed = table_size - byes_num
		for i in range(subs_needed):
			players.append(0)
	else:
		byes.append_array(players.slice(players.size() - byes_num))
		players.resize(players.size() - byes_num)

	var tables_num = players.size() / table_size

	var tables_per_block = tables_num / pairing_settings.swiss_blocks
	var larger_blocks_left = 0
	if tables_num % pairing_settings.swiss_blocks != 0:
		tables_per_block += 1
		larger_blocks_left = tables_num % pairing_settings.swiss_blocks
	
	var pairings = []
	
	var start_index = 0
	for block in pairing_settings.swiss_blocks:
		var block_players = tables_per_block * table_size

		var block_tables = _create_pairings_for_block(
				pairing_settings, players.slice(start_index, start_index + block_players))

		start_index += block_players

		pairings.append_array(block_tables)

		if larger_blocks_left > 0:
			larger_blocks_left -= 1
			if larger_blocks_left == 0:
				tables_per_block -= 1
	
	var tables = _pairings_to_tables(pairing_settings, pairings)

	pairings_tree.render(tables, byes)

func _create_pairings_for_block(pairing_settings, players):
	var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

	var tables = []

	players.shuffle()

	if pairing_settings.avoid_duplicates:
		var prior_pairings : Dictionary = _prior_pairings()
		
		# We don't actually guarantee that there aren't duplicates, but for events where the
		# number of rounds is small relative to the number of players this is good enough
		while players.size() > 0:
			var next_player = players.pop_front()
			var next_players = []
			next_players.append(next_player)
			var has_played = []
			if prior_pairings.has(next_player):
				has_played.append_array(prior_pairings[next_player])

			var index = 0
			while index < players.size():
				if not has_played.has(players[index]):
					next_players.append(players[index])
					if prior_pairings.has(players[index]):
						has_played.append_array(prior_pairings[players[index]])
					players.remove_at(index)
					index -= 1
				if next_players.size() == table_size:
					break
				index += 1
			
			while next_players.size() < table_size:
				next_players.append(players.pop_front())
			tables.append(next_players)
	else:
		var index = 0
		while index < players.size():
			var next_players = []
			next_players.append(players[index])
			next_players.append(players[index + 1])
			next_players.append(players[index + 2])
			if table_size == 4:
				next_players.append(players[index + 3])
			tables.append(next_players)
			index += table_size
	
	return tables

func _pairings_to_tables(pairing_settings, pairings):
	var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

	var tables = []
	for pairing in pairings:
		var next_table = Table.new()

		next_table.player_ids.append_array(pairing)
		
		if pairing_settings.assign_seat_winds:
			next_table.player_seats.append(Table.Wind.EAST)
			next_table.player_seats.append(Table.Wind.SOUTH)
			next_table.player_seats.append(Table.Wind.WEST)
			if table_size == 4:
				next_table.player_seats.append(Table.Wind.NORTH)
		
		tables.append(next_table)
	
	return tables

func _prior_pairings():
	var prior_pairings : Dictionary = {}
	for table in data_store.tournament.tables:
		for player_id in table.player_ids:
			if not prior_pairings.has(player_id):
				prior_pairings[player_id] = []
			
			for opponent in table.player_ids:
				if (opponent != player_id
						and not prior_pairings[player_id].has(opponent)
						and not prior_pairings.has(opponent)):
					prior_pairings[player_id].append(opponent)
	return prior_pairings