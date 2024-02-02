extends Resource
class_name Tournament

var name : String = ""
var registered_players : Array[Player] = []
var settings : TournamentSettings = TournamentSettings.new()
var tables : Array[Table] = []
var cuts : Array[Cut] = []

func calculate_scores() -> Dictionary:
	var scores = {}
	return scores
