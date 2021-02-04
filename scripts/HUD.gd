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
	
func display_book(book_id: int):
	is_book_visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	print("Displaying ", book_id)
	book_open_sound.play_random_sound()
	book_downloader.download_ebook_text(book_id)
	
func set_description(description: String):
	description_label.text = description

func _process(_delta):
	if is_book_visible and Input.is_action_just_pressed("ui_cancel"):
		is_book_visible = false
		book_open_sound.play_random_sound()
	book_display.visible = is_book_visible
	
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		return
		
	if Input.is_action_just_pressed("ui_right"):
		# TODO: Refactor this so these actions are being done on the object itself?
		book_text_label.lines_skipped += book_text_label.max_lines_visible
		book_text_scroll.scroll_vertical = 0
		page_turn_sound.play_random_sound()
		
	if Input.is_action_just_pressed("ui_left"):
		# TODO: Refactor this so these actions are being done on the object itself
		book_text_label.lines_skipped -= book_text_label.max_lines_visible
		book_text_scroll.scroll_vertical = 1e9
		page_turn_sound.play_random_sound()

	book_text_label.lines_skipped = int(clamp(book_text_label.lines_skipped, 0, book_text_label.get_line_count()))
	var current_page = (book_text_label.lines_skipped / book_text_label.max_lines_visible) + 1
	var max_page = (book_text_label.get_line_count() / book_text_label.max_lines_visible) + 1
	page_count_label.text = "Page %d/%d" % [current_page, max_page]
		
