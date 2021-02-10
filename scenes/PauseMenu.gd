extends Control

signal resume_game


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func open_pause_menu():
	self.visible = true


func close_pause_menu():
	self.visible = false


func _on_Resume_pressed():
	emit_signal("resume_game")


func _on_Quit_pressed():
	# Exit the game
	self.get_tree().quit()
