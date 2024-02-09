class_name Cut

enum ScoreModification { NONE, HALVED, ZERO }

var player_count : int = 8
var score_modification : ScoreModification = ScoreModification.NONE
var start_round : int = 1
var end_round : int = 1

var tiebreak_priority = []

func get_score_modification_string() -> String:
    match score_modification:
        ScoreModification.NONE:
            return "None"
        ScoreModification.HALVED:
            return "Halved"
        ScoreModification.ZERO:
            return "Zero"
    return ""

func serialize() -> Dictionary:
    return {
        "player_count": player_count,
        "score_modification": score_modification,
        "start_round": start_round,
        "end_round": end_round,
        "tiebreak_priority": tiebreak_priority
    }

func deserialize(data: Dictionary):
    player_count = data["player_count"]
    score_modification = data["score_modification"]
    start_round = data["start_round"]
    end_round = data["end_round"]
    tiebreak_priority = data["tiebreak_priority"]