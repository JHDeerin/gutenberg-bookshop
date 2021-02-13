extends Control

signal resume_game
signal update_mouse_sensitivity(new_sensitivity)


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


func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))


func _on_SensitivitySlider_value_changed(value):
	emit_signal("update_mouse_sensitivity", value)
