extends Resource
class_name TournamentSettings

enum GameType { YONMA, SANMA }
enum UmaType { FIXED, FLOATING }
enum PairingSystem { RANDOM, PROGRESSIVE_SWISS }
enum TiebreakStrategy { WIND_ORDER, SPLIT }

var game_type : GameType = GameType.YONMA

var uma_type : UmaType = UmaType.FIXED

var fixed_uma : Array[float] = [30, 10, -10, -30]

var floating_uma_1 : Array[float] = [15, 5, -5, -15]
var floating_uma_2 : Array[float] = [15, 5, 0, -20]
# Unused if the game type is yonma
var floating_uma_3 : Array[float] = [20, 0, -5, -15]


var start_points : float = 25000
var return_points : float = 30000
var oka : Array[float] = [20, 0, 0, 0]
var pairing_system : PairingSystem = PairingSystem.RANDOM
var time_per_round_minutes : float = 75
var score_per_thousand_points : float = 1.0

var shuugi : bool = false
var start_shuugi : float = 10
var end_shuugi : float = 10
var score_per_shuugi : float = 0.5

func get_game_type_string() -> String:
    match game_type:
        GameType.YONMA:
            return "Yonma"
        GameType.SANMA:
            return "Sanma"
        _:
            return "Unknown"

func get_uma_type_string() -> String:
    match uma_type:
        UmaType.FIXED:
            return "Fixed"
        UmaType.FLOATING:
            return "Floating"
        _:
            return "Unknown"

func get_pairing_system_string() -> String:
    match pairing_system:
        PairingSystem.RANDOM:
            return "Random"
        PairingSystem.PROGRESSIVE_SWISS:
            return "Progressive Swiss"
        _:
            return "Unknown"