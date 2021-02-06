extends Control

var book_display
var book_downloader
var description_label

func _ready():
	book_display = $GutenbergBookDisplay
	book_downloader = $BookDownloader
	description_label = $ShortDescription


func set_description(description: String):
	description_label.text = description


func _process(_delta):
	if not book_display.visible:
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		book_display.close_book()
	
	if Input.is_action_just_pressed("ui_right"):
		book_display.flip_page(true)
	if Input.is_action_just_pressed("ui_left"):
		book_display.flip_page(false)


func display_book(book_id: int):
	book_display.open_book()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	print("Displaying ", book_id)
	book_downloader.download_ebook_text(book_id)


func close_book():
	book_display.close_book()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
