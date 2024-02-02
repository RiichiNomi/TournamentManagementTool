extends Node

var tournament : Tournament = Tournament.new()

var players_by_id : Dictionary = {}

func load_tournament(new_tournament : Tournament) -> void:
    tournament = new_tournament

    players_by_id = {}

    for player in tournament.registered_players:
        players_by_id[player.id] = player