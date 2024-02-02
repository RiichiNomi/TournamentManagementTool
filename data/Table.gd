extends Resource
class_name Table

enum { EAST, SOUTH, WEST, NORTH }

var player_ids : Array[int] = []

var final_scores : Array[float] = []
var penalties : Array[float] = []

var left_over_kyotaku : int = 0

func is_complete() -> bool:
  return final_scores.size() == player_ids.size()