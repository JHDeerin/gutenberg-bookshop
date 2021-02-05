extends Control

var book_display
var book_downloader
var book_text_label
var book_text_scroll
var description_label
var page_count_label

var book_open_sound
var page_turn_sound

var is_book_visible = false

func _ready():
	book_display = $GutenbergBookDisplay
	book_downloader = get_parent().get_node("BookManagement/HTTPRequest")
	book_text_scroll = $GutenbergBookDisplay/MarginContainer/ScrollContainer
	book_text_label = $GutenbergBookDisplay/MarginContainer/ScrollContainer/Label
	description_label = $ShortDescription
	page_count_label = $GutenbergBookDisplay/PageCount
	
	book_open_sound = $BookOpenSound
	page_turn_sound = $PageTurnSound


func set_description(description: String):
	description_label.text = description


func _process(_delta):
	if is_book_visible and Input.is_action_just_pressed("ui_cancel"):
		close_book()
	book_display.visible = is_book_visible
	
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		return
		
	if Input.is_action_just_pressed("ui_right"):
		flip_page(true)
	if Input.is_action_just_pressed("ui_left"):
		flip_page(false)
	update_book_page(book_text_label, page_count_label)

# TODO: All the functions beneath should be moved to the book display (except
# possibly the book downloading action)

func display_book(book_id: int):
	is_book_visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	print("Displaying ", book_id)
	book_open_sound.play_random_sound()
	book_downloader.download_ebook_text(book_id)


func close_book():
	is_book_visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
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
		book_text_scroll.scroll_vertical = 1e9
	page_turn_sound.play_random_sound()


func update_book_page(book_text_label: Label, page_count_label: Label):
	"""
	TODO: This should be done on the book text node itself
	"""
	book_text_label.lines_skipped = int(clamp(book_text_label.lines_skipped, 0, book_text_label.get_line_count()))
	var current_page = (book_text_label.lines_skipped / book_text_label.max_lines_visible) + 1
	var max_page = (book_text_label.get_line_count() / book_text_label.max_lines_visible) + 1
	page_count_label.text = "Page %d/%d" % [current_page, max_page]
	
