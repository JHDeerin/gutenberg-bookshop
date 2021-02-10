extends Control

var book_display
var book_downloader
var description_label
var pause_menu

var is_book_open = false
var is_game_paused = false

func _ready():
	book_display = $GutenbergBookDisplay
	book_downloader = $BookDownloader
	description_label = $ShortDescription
	pause_menu = $PauseMenu
	self.set_description("")


func set_description(description: String):
	"""
	Set the description text beneath the crosshair
	"""
	description_label.text = description
	
	
func set_book_text(new_text: String):
	"""
	Updates the text of the currently-open book
	TODO: Pass-through method, possibly refactor?
	"""
	book_display.set_book_text(new_text)


func open_book(book_id: int):
	"""
	Opens the book with the given ID and displays its content on the HUD
	"""
	is_book_open = true
	book_display.open_book()
	# TODO: Should this be here, or kept on Player.gd?
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	print("Displaying ", book_id)
	book_downloader.download_ebook_text(book_id)
	
	
func open_text(text: String):
	"""
	Displays a string of text on the HUD that isn't a specific book
	"""
	is_book_open = true
	book_display.open_book()
	self.set_book_text(text)
	# TODO: Should this be here, or kept on Player.gd?
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func close_book():
	book_display.close_book()
	is_book_open = false
	
	
func open_pause_menu():
	is_game_paused = true
	pause_menu.open_pause_menu()
	
	
func close_pause_menu():
	pause_menu.close_pause_menu()
	is_game_paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func flip_book_page(is_flip_direction_right: bool):
	"""
	Flips the page of the currently opened book to the left/right, based on the
	input boolean
	"""
	if is_book_open:
		book_display.flip_page(is_flip_direction_right)


func _on_BookDownloader_update_book_text(new_text):
	self.set_book_text(new_text)


func _on_Player_menu_escape():
	if self.is_book_open:
		self.close_book()
	if self.is_game_paused:
		self.close_pause_menu()


func _on_Player_page_flip_attempt(is_flipping_right):
	if self.is_book_open:
		self.flip_book_page(is_flipping_right)


func _on_Player_game_paused():
	self.open_pause_menu()


func _on_PauseMenu_resume_game():
	if self.is_game_paused:
		self.close_pause_menu()
