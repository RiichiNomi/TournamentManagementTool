extends Node

var tournament : Tournament = Tournament.new()

var players_by_id : Dictionary = {}

var scores : Dictionary = {}

signal standings_updated

func update_table() -> void:
    # TODO: implement this placeholder
    scores = tournament.calculate_scores()
    standings_updated.emit()

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

func load_tournament(new_tournament : Tournament) -> void:
    tournament = new_tournament

    players_by_id = {}

    for player in tournament.registered_players:
        players_by_id[player.id] = player
    
    scores = tournament.calculate_scores()