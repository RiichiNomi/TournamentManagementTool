extends VBoxContainer
class_name GoogleSheetsHandler

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var api_key_field : LineEdit = $Control/ApiKeyContainer/LineEdit
@onready var spreadsheet_id_field : LineEdit = $Control/SpreadsheetIdContainer/LineEdit

@onready var export_button : Button = $Control/Buttons/ExportButton
@onready var import_button : Button = $Control/Buttons/ImportButton

@onready var error_label : Label = $Error/Label
@onready var error_button : Button = $Error/Button

@onready var hide_handler_button : Button = $Control/DoneButton

@onready var error_block : VBoxContainer = $Error
@onready var control_block : VBoxContainer = $Control

signal hide_sheets_handler

func _ready():
	api_key_field.text = data_store.tournament.settings.sheets_api_key
	spreadsheet_id_field.text = data_store.tournament.settings.sheets_id

	export_button.pressed.connect(_on_export_pressed)
	import_button.pressed.connect(_on_import_pressed)

	hide_handler_button.pressed.connect(_on_hide_handler)

	error_button.pressed.connect(_on_error_button_clicked)

func _on_export_pressed():
	pass

func _on_import_pressed():
	pass

func _on_hide_handler():
	hide_sheets_handler.emit()

func _on_error_button_clicked():
	error_block.visible = false
	control_block.visible = true