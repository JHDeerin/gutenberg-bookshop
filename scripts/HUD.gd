extends Control

var book_display
var book_downloader
var description_label
var is_book_open = false

func _ready():
	book_display = $GutenbergBookDisplay
	book_downloader = $BookDownloader
	description_label = $ShortDescription


func set_description(description: String):
	"""
	Set the description text beneath the crosshair
	"""
	description_label.text = description


func open_book(book_id: int):
	"""
	Opens the book with the given ID and displays its content on the HUD
	"""
	is_book_open = true
	book_display.open_book()
	
	print("Displaying ", book_id)
	book_downloader.download_ebook_text(book_id)


func close_book():
	book_display.close_book()
	is_book_open = false
	

func flip_book_page(is_flip_direction_right: bool):
	"""
	Flips the page of the currently opened book to the left/right, based on the
	input boolean
	TODO: Possibly refactor since this is just a pass-through function atm?
	"""
	if is_book_open:
		book_display.flip_page(is_flip_direction_right)
