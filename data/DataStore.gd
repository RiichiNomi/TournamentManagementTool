extends Node

var tournament : Tournament = Tournament.new()

var players_by_id : Dictionary = {}

var scores : Dictionary = {}

signal standings_updated
signal players_updated

func update_table() -> void:
    # TODO: implement this placeholder
    scores = tournament.calculate_scores()
    standings_updated.emit()

func update_inactive_players(new_inactive_players : Array) -> void:
    for player in tournament.inactive_players:
        if players_by_id.has(player.id):
            players_by_id.erase(player.id)
    tournament.inactive_players = new_inactive_players
    for player in tournament.inactive_players:
        players_by_id[player.id] = player

func activate_player(player_id : int) -> void:
    tournament.inactive_players = tournament.inactive_players.filter(func find_player(player):
        return player.id != player_id)
    tournament.registered_players.append(players_by_id[player_id])
    tournament.registered_players.sort_custom(func comp(a, b):
        return a.id < b.id)
    players_updated.emit()

func deactivate_player(player_id : int) -> void:
    tournament.registered_players = tournament.registered_players.filter(func find_player(player):
        return player.id != player_id)
    tournament.inactive_players.append(players_by_id[player_id])
    tournament.inactive_players.sort_custom(func comp(a, b):
        return a.id < b.id)
    players_updated.emit()

func get_scores() -> Dictionary:
    return scores

func get_hanchan_history() -> Array:
    return tournament.tables

func get_hanchan_history_for_player(player_id : int) -> Array:
    var relevant_tables = []
    for table in tournament.tables:
        if table.player_ids.has(player_id):
            relevant_tables.append(table)
    return relevant_tables

func get_player(player_id : int) -> Player:
    return players_by_id[player_id]

func load_tournament(new_tournament : Tournament) -> void:
    tournament = new_tournament

    players_by_id = {}

    for player in tournament.registered_players:
        players_by_id[player.id] = player
    
    scores = tournament.calculate_scores()