extends OmniLight


export var noise_octaves = 3
export var noise_period = 20
export var flicker_speed = 1.0
export var max_brightness = 1.0
export var min_brightness = 0.5
var noise = OpenSimplexNoise.new()

var _time = 0
var _light
var _original_energy

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.octaves = noise_octaves
	noise.period = noise_period

	_light = self
	_original_energy = _light.light_energy

func _process(delta):
	_time += delta
	var brightness_factor = noise.get_noise_1d(_time * flicker_speed)
	# normalize between 0 and 1
	brightness_factor += 1.0
	brightness_factor /= 2.0
	
	# linearly interpolate between max/min brightness
	brightness_factor = min_brightness + (max_brightness - min_brightness) * brightness_factor

	_light.light_energy = _original_energy * brightness_factor


