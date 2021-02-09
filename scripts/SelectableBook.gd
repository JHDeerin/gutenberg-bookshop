class_name SelectableBook
extends SelectableItem

var hud

var book_id = -1
var book_title = ""


func _ready():
	._ready()
	# TODO: Find a less strongly coupled way of doing this?
	# Also, check performance impact?
	hud = get_parent().get_parent().get_node("HUD")
	

func set_book_info(book_id: int, book_title: String):
	self.book_id = book_id
	self.book_title = book_title


func on_item_selected():
	.on_item_selected()
	hud.set_description(self.book_title)
	

func on_item_use():
	.on_item_use()
	hud.open_book(self.book_id)
	# TODO: Determine if this should go here (I think yes, because it's an
	# and not *really* an input?)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
