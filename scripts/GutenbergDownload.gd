extends HTTPRequest


var book_display
var _possible_urls
var _current_url_index

var _last_loaded_book_id = null
var _currently_loading_book_id = null


func _ready():
	self.connect("request_completed", self, "_handle_book_download")
	# TODO: Pass this responsibility to someone else?
	book_display = get_parent().get_node("GutenbergBookDisplay")

func get_ebook_zip_urls(ebook_id):
	var BASE_URL = "https://www.gutenberg.org"
	var INTERMEDIATE_ROUTES = [
		"cache/epub",
		"files"
	]
	var NAME_PREFIXES = [
		"",
		"pg"
	]
	var NAME_SUFFIXES = [
		"",
		"-0",
		"-8"
	]

	var possible_urls = []
	for route in INTERMEDIATE_ROUTES:
		for pre in NAME_PREFIXES:
			for suf in NAME_SUFFIXES:
				possible_urls += ["%s/%s/%d/%s%d%s.txt" % [BASE_URL, route, ebook_id, pre, ebook_id, suf]]
	return possible_urls


func download_ebook_text(ebook_id):
	"""
	Downloads the given ebook, and returns the text of it
	"""
	if ebook_id == _last_loaded_book_id:
		return

	_currently_loading_book_id = ebook_id
	_possible_urls = get_ebook_zip_urls(ebook_id)

	book_display.set_book_text("Loading...")
	# Try all known possible URL combinations
	for i in _possible_urls.size():
		_current_url_index = i
		var url = _possible_urls[_current_url_index]
		var error = self.request(url)
		if error == OK:
			# TODO: Refactor out break?
			return
		print("ERROR: Code %d with %s!" % [error, url])
	# TODO: How to return when work is done in callback?
	# Should return before this point if download is made
	book_display.set_book_text("Failed to download book :(")
	
	
func remove_project_gutenberg_headers_footers(ebook_text):
	"""
	Returns the Ebook text with Project gutenberg's boilerplate headers and
	footers removed
	"""
	var possible_text_beginnings = [
		"*** START OF",
		"***START OF",
	]
	var possible_text_endings = [
		"*** END OF",
		"***END OF"
	]

	var text_beginning = -1
	for possible_beginning in possible_text_beginnings:
		if not text_beginning == -1:
			continue
		text_beginning = ebook_text.find(possible_beginning)
		if not text_beginning == -1:
			# jump to the next newline
			text_beginning = ebook_text.find("\n", text_beginning) + 1
	text_beginning = max(0, text_beginning)
	
	var text_ending = -1
	for possible_ending in possible_text_endings:
		if not text_ending == -1:
			continue
		text_ending = ebook_text.find(possible_ending, text_beginning)
	text_ending = min(text_ending, ebook_text.length())

	return ebook_text.substr(text_beginning, text_ending - text_beginning).strip_edges()


func _handle_book_download(result, response_code, headers, body):
	if not result == RESULT_SUCCESS:
		print("Error %d (code %d) occurred while downloading book text :(" % [result, response_code])
		book_display.set_book_text("ERROR")
		_make_new_request()
		return
	
	# TODO: Figure out how to get headers as a dictionary?
	var content_type = ""
	for header_content in headers:
		header_content = header_content.to_lower()
		if header_content.begins_with("content-type"):
			content_type = header_content.trim_prefix("content-type:").strip_edges()

	if not content_type.begins_with("text/plain"):
		print("'%s' content type is '%s' instead of 'text/plain' " % [_possible_urls[_current_url_index], content_type])
		_make_new_request()
		return

	var book_text = body.get_string_from_ascii().strip_edges(false, true)
	if book_text.ends_with(".gzip") or book_text.ends_with(".utf8"):
		print("'%s' did not return a .txt file" % _possible_urls[_current_url_index])
		_make_new_request()
		return

	book_text = remove_project_gutenberg_headers_footers(book_text)
	book_display.set_book_text(book_text)
	
	_last_loaded_book_id = _currently_loading_book_id
	_currently_loading_book_id = null

func _make_new_request():
	_current_url_index += 1
	if _current_url_index < _possible_urls.size():
		var new_url = _possible_urls[_current_url_index]
		self.request(new_url)
		return

	print("No correct url found for %d!" % _currently_loading_book_id)
	_currently_loading_book_id = null
	book_display.set_book_text("Failed to download book :(")

