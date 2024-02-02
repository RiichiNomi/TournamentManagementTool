extends Resource
class_name Cut

enum ScoreModification { NONE, HALVED, ZERO }

var tables : Array[Table] = []
var score_modification : ScoreModification = ScoreModification.NONE