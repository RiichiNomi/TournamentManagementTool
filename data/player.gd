class_name Player

var id : int = 0
var name : String = "Freed Jyanshi"
var affiliation : String = "Riichi Nomi NYC"

func serialize() -> Dictionary :
    return {
        "id": id,
        "name": name,
        "affiliation": affiliation
    }

func deserialize(data : Dictionary) :
    id = data["id"]
    name = data["name"]
    affiliation = data["affiliation"]