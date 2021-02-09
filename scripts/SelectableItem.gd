class_name SelectableItem
extends Spatial


var _collider_id
var _is_selected = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_collider_id = self.get_instance_id()


func on_item_selected():
	"""
	Handle the case where the player has selected this item in the world
	"""
	pass
	

func on_item_use():
	"""
	Handle the case when the player tries to use this item, assuming it's
	currently selected
	"""
	pass
