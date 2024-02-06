extends Resource
class_name Tournament

var name : String = ""
var registered_players : Array[Player] = []
var inactive_players : Array[Player] = []
var settings : TournamentSettings = TournamentSettings.new()
var tables : Array[Table] = []
var cuts : Array[Cut] = []

var next_round : int = 1

func calculate_scores() -> Dictionary:
	var scores = {}

	for table in tables:
		var table_scores = table.score_table(settings)
		for player in table_scores:
			scores[player] = scores.get(player, 0) + table_scores[player]

	return scores
