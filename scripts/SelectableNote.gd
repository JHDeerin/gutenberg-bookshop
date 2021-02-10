extends SelectableItem

export(NodePath) var hud_path
export(String, MULTILINE) var note_text = ""

var hud

var note_name = "Hey There!"


func _ready():
	._ready()
	# TODO: Find a less strongly coupled way of doing this?
	hud = get_node(hud_path)


func on_item_selected():
	.on_item_selected()
	hud.set_description(self.note_name)
	

func on_item_use():
	.on_item_use()
	hud.open_text(self.note_text)
