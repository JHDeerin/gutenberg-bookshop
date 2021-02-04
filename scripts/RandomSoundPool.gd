extends AudioStreamPlayer

export(Array, Resource) var sounds
export var pitch_variance = 0.2
export var volume_variance_db = 1.0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _loaded_sounds = []


# Called when the node enters the scene tree for the first time.
func _ready():
	for sound in sounds:
		_loaded_sounds.append(sound)

func play_random_sound():
	if _loaded_sounds.size() == 0:
		return

	self.stream = _loaded_sounds[randi() % _loaded_sounds.size()]
	self.stream.loop = false
	self.pitch_scale = 1.0 + pitch_variance * (2.0*randf() - 1.0)
	self.volume_db = 0.0 + volume_variance_db * (2.0*randf() - 1.0)
	
	self.play()
