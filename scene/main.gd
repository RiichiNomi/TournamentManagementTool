extends Control

@onready var new_tournament_button : Button = $HBoxContainer/CenterContainer/NewTournamentButton
@onready var load_tournament_button : Button = $HBoxContainer/CenterContainer/LoadTournamentButton

var TournamentSettingsScene = preload("res://scene/setup/tournament_settings.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	new_tournament_button.pressed.connect(_configure_tournament)
	load_tournament_button.pressed.connect(_load_tournament)

func _configure_tournament():
	get_tree().change_scene_to_packed(TournamentSettingsScene)

func _load_tournament():
	pass