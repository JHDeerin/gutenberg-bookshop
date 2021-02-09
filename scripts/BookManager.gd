extends Spatial

export var x_spacing = 0.1
export var y_spacing = 0.32
export var grid_size = 100
export var MAX_NUM_BOOKS = 3500

var book_meshes
var book_collision_shape
var book_selection_script = load("res://scripts/SelectableBook.gd")

var book_metadata = {}
var book_ids
var num_books = 0
# NOTE: Need to store this separately since Godot doesn't record it when num meshes is updated dynamically
var mesh_instance_info = []


# Called when the node enters the scene tree for the first time.
func _ready():
	book_meshes = $MultiMeshInstance
	book_collision_shape = book_meshes.multimesh.mesh.create_convex_shape()
	book_meshes.multimesh.instance_count = 0

	book_metadata = _load_book_metadata()
	book_ids = get_sorted_book_ids()

	var bookshelves = $Bookshelves
	for bookshelf in bookshelves.get_children():
		add_books(bookshelf.get_bookshelf_positions())
	print("Num books: ", num_books)


func add_books(book_transforms, do_rerender=true):
	"""
	Adds a series of new books, then re-renders the MultiMesh
	"""
	var counter = 0
	for book_transform in book_transforms:
		counter += 1
		var is_last_book = counter == book_transforms.size()
		add_book(book_transform, do_rerender and is_last_book)


func add_book(book_transform, do_rerender=true):
	"""
	Adds a new book, then re-renders the MultiMesh
	"""
	if num_books >= MAX_NUM_BOOKS:
		return

	var new_mesh_id = num_books
	var book_id = book_ids[new_mesh_id]
	
	num_books += 1
	book_meshes.multimesh.instance_count = num_books
	_add_book_mesh(new_mesh_id, book_id, book_transform)
	
	if not do_rerender:
		return
	for mesh_id in range(num_books):
		book_meshes.multimesh.set_instance_transform(mesh_id, self.mesh_instance_info[mesh_id]["transform"])
		book_meshes.multimesh.set_instance_color(mesh_id, self.mesh_instance_info[mesh_id]["color"])


func _add_book_mesh(mesh_id, book_id, book_transform):
	"""
	Adds the given book as a static, collidable mesh to the game world 
	"""
	self.book_meshes.multimesh.set_instance_transform(mesh_id, book_transform)

	var collider = CollisionShape.new()
	collider.shape = self.book_collision_shape

	var book_collider_node = StaticBody.new()
	book_collider_node.transform = book_transform
	book_collider_node.add_child(collider)
	book_collider_node.set_script(book_selection_script)
	self.add_child(book_collider_node)

	book_collider_node.set_book_info(book_id, get_book_title(book_id))
	
	# Randomize the book color
	seed(book_id)
	var book_color = Color.from_hsv(randf(), clamp(randf(), 0.0, 0.5), clamp(randf(), 0.5, 1.0))
	self.book_meshes.multimesh.set_instance_color(mesh_id, book_color)
	
	self.mesh_instance_info += [{"transform": book_transform, "color": book_color}]


func _load_book_metadata(metadata_path="res://catalog_short.json"):
	var ebook_metadata_file = File.new()
	ebook_metadata_file.open(metadata_path, File.READ)
	var json_parse = JSON.parse(ebook_metadata_file.get_as_text())

	if json_parse.error == OK:
		return json_parse.result
	else:
		print("Error occurred while parsing ebook metadata JSON")
	return {}


class BookAuthorSorter:
		static func sort(a, b):
			if a["author"] == b["author"]:
				return a["title"] < b["title"]
			return a["author"] < b["author"]


func get_sorted_book_ids():
	"""
	Returns an array of book ID numbers, sorted by the author name
	"""
	var book_id_author = []
	for str_book_id in book_metadata.keys().slice(0, MAX_NUM_BOOKS):
		var id_and_author = {}
		id_and_author["id"] = int(str_book_id)
		id_and_author["author"] = book_metadata[str_book_id]["author"]
		id_and_author["title"] = book_metadata[str_book_id]["full_title"]
		book_id_author.push_back(id_and_author)
		
	book_id_author.sort_custom(BookAuthorSorter, "sort")
	var sorted_book_ids = []
	for item in book_id_author:
		sorted_book_ids.push_back(item["id"])

	return sorted_book_ids


func get_book_title(book_id: int):
	"""
	Return the title of a book given it's collider that's been hit
	"""
	var book_info = self.get_book_info(book_id)
	if not book_info:
		# No Project Gutenberg entry for book
		return "UNKNOWN"

	return book_info["title"]


func get_book_info(book_id: int):
	var str_book_id = str(book_id)
	if book_metadata.has(str_book_id):
		return book_metadata[str_book_id]
	return null
