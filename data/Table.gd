extends Resource
class_name Table

enum Wind { EAST, SOUTH, WEST, NORTH }

var round_id : int = 0
var cut_id : int = -1

var player_ids : Array[int] = []
var player_seats : Array[Wind] = []

var final_scores : Array[float] = []
var penalties : Array[float] = []

var left_over_kyotaku : float = 0

func is_complete() -> bool:
  return final_scores.size() == player_ids.size()

func score_table(settings : TournamentSettings) -> Dictionary:
  var scores = {}
  var net = []

  # Calculate net score relative to return points
  var max = -100000
  for score in final_scores:
    var net_score = score - settings.return_points * settings.score_per_thousand_points / 1000
    if net_score > max:
      max = net_score
    net.append(net_score)

  # Adjust for kyotaku based on settings
  if settings.riichi_sticks_strategy == TournamentSettings.RiichiSticksStrategy.FIRST:
    var tied_first = 0
    for net_score in net:
      if net_score == max:
        tied_first += 1

    for index in range(net.size()):
      if net[index] == max:
        net[index] += left_over_kyotaku / tied_first
  
  # Determine rankings and apply uma. Technically if someone scores under -100000 we could run into
  # issues here, but if that happens we have bigger problems to worry about.
  var first_score = -100000
  var first = []

  var second_score = -100000
  var second = []

  var third_score = -100000
  var third = []

  var fourth_score = -100000
  var fourth = []

  var at_or_above_start = 0

  for index in range(net.size()):
    if net[index] >= 0:
      at_or_above_start += 1
    if net[index] > first_score:
      # Shift all of the other rankings down by one
      fourth_score = third_score
      fourth = third

      third_score = second_score
      third = second

      second_score = first_score
      second = first

      first_score = net[index]
      first = [index]
    elif net[index] == first_score:
      first.append(index)
    elif net[index] > second_score:
      # Shift all of the other rankings down by one
      fourth_score = third_score
      fourth = third

      third_score = second_score
      third = second

      second_score = net[index]
      second = [index]
    elif net[index] == second_score:
      second.append(index)
    elif net[index] > third_score:
      # Shift all of the other rankings down by one
      fourth_score = third_score
      fourth = third

      third_score = net[index]
      third = [index]
    elif net[index] == third_score:
      third.append(index)
    else:
      fourth_score = net[index]
      fourth = [index]
  
  if settings.uma_type == TournamentSettings.UmaType.FIXED:
    if settings.tiebreak_strategy == TournamentSettings.TiebreakStrategy.WIND_ORDER:
      pass
    elif settings.tiebreak_strategy == TournamentSettings.TiebreakStrategy.SPLIT:
      pass
  elif settings.uma_type == TournamentSettings.UmaType.FLOATING:
    pass

  # Apply penalties

  return scores