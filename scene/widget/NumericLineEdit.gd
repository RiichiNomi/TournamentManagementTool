extends LineEdit
class_name NumericLineEdit

var last_text = ""

func _ready():
    last_text = placeholder_text
    text_changed.connect(_on_text_changed)

func _on_text_changed(new_text):
    if not new_text.is_valid_float() and new_text != "":
        text = last_text
        set_caret_column(text.length())
    else:
        last_text = text

func set_default(default):
    text = str(default)
    placeholder_text = str(default)
    last_text = str(default)

func get_value() -> float:
    return text.to_float()