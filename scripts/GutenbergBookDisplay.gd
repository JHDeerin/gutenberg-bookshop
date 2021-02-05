extends Control

var book_text_label
var book_text_scroll
var page_count_label

var book_open_sound
var page_turn_sound


func _ready():
	book_text_scroll = $MarginContainer/ScrollContainer
	book_text_label = $MarginContainer/ScrollContainer/Label
	page_count_label = $PageCount
	
	book_open_sound = $BookOpenSound
	page_turn_sound = $PageTurnSound


func open_book():
	self.visible = true
	book_open_sound.play_random_sound()


func close_book():
	self.visible = false
	book_open_sound.play_random_sound()
	

func set_book_text(new_text: String):
	book_text_label.text = new_text
	update_book_page(book_text_label, page_count_label)


func flip_page(is_flipping_right: bool):
	"""
	Flips the text of the book forwards/backwards to the next page of content
	"""
	if is_flipping_right:
		book_text_label.lines_skipped += book_text_label.max_lines_visible
		book_text_scroll.scroll_vertical = 0
	else:
		book_text_label.lines_skipped -= book_text_label.max_lines_visible
		# Beginning of page if we're already on the first page, else to the end
		book_text_scroll.scroll_vertical = 1e9 if book_text_label.lines_skipped >= 0 else 0
	page_turn_sound.play_random_sound()
	update_book_page(book_text_label, page_count_label)


func update_book_page(book_text: Label, page_count: Label):
	"""
	Update the page of the currently displayed book
	"""
	var max_page = ceil(float(book_text.get_line_count() + 1) / book_text.max_lines_visible)

	book_text.lines_skipped = int(clamp(book_text.lines_skipped,
		0, (max_page-1) * book_text.max_lines_visible))
	var current_page = ceil(float(book_text.lines_skipped + 1) / book_text.max_lines_visible)
	
	page_count.text = "Page %d/%d" % [current_page, max_page]
