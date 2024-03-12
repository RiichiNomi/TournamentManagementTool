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
	var tables = []

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
		players.shuffle()
	else:
		var byes_num = players.size() % table_size
		players.shuffle()

		byes.append_array(players.slice(players.size() - byes_num))

		players.resize(players.size() - byes_num)
	
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
			
			var next_table = Table.new()

			next_table.player_ids.append_array(next_players)
			
			if pairing_settings.assign_seat_winds:
				next_table.player_seats.append(Table.Wind.EAST)
				next_table.player_seats.append(Table.Wind.SOUTH)
				next_table.player_seats.append(Table.Wind.WEST)
				if table_size == 4:
					next_table.player_seats.append(Table.Wind.NORTH)
			
			tables.append(next_table)
	else:
		var index = 0
		while index < players.size():
			var next_table = Table.new()
			next_table.player_ids.append(players[index])
			next_table.player_ids.append(players[index + 1])
			next_table.player_ids.append(players[index + 2])
			if table_size == 4:
				next_table.player_ids.append(players[index + 3])
			
			if pairing_settings.assign_seat_winds:
				next_table.player_seats.append(Table.Wind.EAST)
				next_table.player_seats.append(Table.Wind.SOUTH)
				next_table.player_seats.append(Table.Wind.WEST)
				if table_size == 4:
					next_table.player_seats.append(Table.Wind.NORTH)
			tables.append(next_table)
			index += table_size

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
	
	var swiss_tables = []
	
	var start_index = 0
	for block in pairing_settings.swiss_blocks:
		var block_players = tables_per_block * table_size

		var block_tables = []

		for table_index in range(tables_per_block):
			var table_players = []
			table_players.append(players[start_index + table_index])
			table_players.append(players[start_index + table_index + (tables_per_block)])
			table_players.append(players[start_index + table_index + (tables_per_block * 2)])

			if table_size == 4:
				table_players.append(players[start_index + table_index + (tables_per_block * 3)])
			
			block_tables.append(table_players)

		# Only try to resolve duplicate pairings within a single swiss block
		if pairing_settings.avoid_duplicates:
			var prior_pairings : Dictionary = _prior_pairings()

			for table_index in range(block_tables.size()):
				var has_played = []
				for player_index in range(block_tables[table_index].size()):
					var player_id = block_tables[table_index][player_index]

					if has_played.has(block_tables[table_index][player_index]):
						for offset in range(1, max(table_index, block_tables.size() - table_index)):
							if table_index + offset < block_tables.size() and _check_and_swap(
									block_tables[table_index],
									block_tables[table_index + offset],
									player_index,
									prior_pairings):
								break
							if table_index - offset >= 0 and _check_and_swap(
									block_tables[table_index],
									block_tables[table_index - offset],
									player_index,
									prior_pairings):
								break
					elif prior_pairings.has(player_id):
						has_played.append_array(prior_pairings[player_id])

		start_index += block_players

		swiss_tables.append_array(block_tables)

		if larger_blocks_left > 0:
			larger_blocks_left -= 1
			if larger_blocks_left == 0:
				tables_per_block -= 1
	
	var tables = []

	for table in swiss_tables:
		var next_table = Table.new()

		if pairing_settings.assign_seat_winds:
			table.shuffle()

		next_table.player_ids.append_array(table)
		if pairing_settings.assign_seat_winds:
			next_table.player_seats.append(Table.Wind.EAST)
			next_table.player_seats.append(Table.Wind.SOUTH)
			next_table.player_seats.append(Table.Wind.WEST)
			if table_size == 4:
				next_table.player_seats.append(Table.Wind.NORTH)
		tables.append(next_table)

	pairings_tree.render(tables, byes)

func _check_and_swap(table_one, table_two, swap_index, prior_pairings):
	var table_one_played = []
	var table_two_played = []

	for player_index in range(swap_index - 1):
		table_one_played.append_array(prior_pairings[table_one[player_index]])
		table_two_played.append_array(prior_pairings[table_two[player_index]])
	
	if not table_one_played.has(table_two[swap_index]) and not table_two_played.has(table_one[swap_index]):
		var temp = table_one[swap_index]
		table_one[swap_index] = table_two[swap_index]
		table_two[swap_index] = temp
		return true

	return false

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