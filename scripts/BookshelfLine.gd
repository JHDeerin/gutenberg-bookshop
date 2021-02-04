extends BookshelfPositions

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_bookshelf_positions():
	var book_transforms = []
	for bookshelf in self.get_children():
		book_transforms += bookshelf.get_bookshelf_positions()
	return book_transforms
