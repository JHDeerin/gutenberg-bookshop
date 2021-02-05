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


func _process(_delta):
	if self.visible:
		update_book_page(book_text_label, page_count_label)


func open_book():
	self.visible = true
	book_open_sound.play_random_sound()


func close_book():
	self.visible = false
	book_open_sound.play_random_sound()


func flip_page(is_flipping_right: bool):
	"""
	Flips the text of the book forwards/backwards to the next page of content
	"""
	# TODO: Refactor this so these actions are being done on the object itself?
	if is_flipping_right:
		book_text_label.lines_skipped += book_text_label.max_lines_visible
		book_text_scroll.scroll_vertical = 0
	else:
		book_text_label.lines_skipped -= book_text_label.max_lines_visible
		# Beginning of page if we're already on the first page, else to the end
		book_text_scroll.scroll_vertical = 1e9 if book_text_label.lines_skipped >= 0 else 0
	page_turn_sound.play_random_sound()


func update_book_page(book_text_label: Label, page_count_label: Label):
	"""
	Update the page of the currently displayed book
	"""
	var max_page = ceil(float(book_text_label.get_line_count() + 1) / book_text_label.max_lines_visible)

	book_text_label.lines_skipped = int(clamp(book_text_label.lines_skipped,
		0, (max_page-1) * book_text_label.max_lines_visible))
	var current_page = ceil(float(book_text_label.lines_skipped + 1) / book_text_label.max_lines_visible)
	
	page_count_label.text = "Page %d/%d" % [current_page, max_page]
