extends Spatial

class_name BookshelfPositions

export var num_rows = 6
export var books_per_row = 10
export var book_spacing = 0.1
export var row_spacing = 0.5
export var book_stick_out_jitter = 0.02

var book_positions = []

func _ready():
	pass
	
func get_bookshelf_positions():
	var book_start_pos = $BookStartPosition.global_transform
	book_positions = []
	for y in num_rows:
		for x in books_per_row:
			var z_offset = 2.0 * book_stick_out_jitter * randf() - book_stick_out_jitter
			book_positions += [book_start_pos.translated(Vector3(x*book_spacing, -y*row_spacing, z_offset))]
	return book_positions
