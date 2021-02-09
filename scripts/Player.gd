extends KinematicBody

export var MOUSE_SENSITIVITY = 0.5

export var SPEED = 0.5
export var SPRINT_SPEED = 3.0
export var GRAVITY = 3.0
export var READING_DISTANCE = 2.0

var move_dir = Vector3(0.0, 0, 0)
var falling_speed = 0.0
var is_sprinting = false

var ray
var camera
var hud


# Called when the node enters the scene tree for the first time.
func _ready():
	camera = $Camera
	ray = $Camera/RayCast
	ray.cast_to = Vector3(0.0, -1.0 * READING_DISTANCE, 0.0)
	
	# TODO: Remove these dependencies
	hud = get_parent().get_node("HUD")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	handle_user_input(delta)
	update_player_position(delta)
	handle_item_selection(delta)


func handle_user_input(_delta):
	move_dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	move_dir += -cam_xform.basis.z * input_movement_vector.y
	move_dir += cam_xform.basis.x * input_movement_vector.x
	
	move_dir.y = 0
	move_dir = move_dir.normalized()
	
	is_sprinting =  Input.is_action_pressed("sprint")
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			if hud.is_book_open:
				hud.close_book()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and Input.is_action_just_pressed("use_item"):
		if ray.is_colliding() and ray.get_collider() is SelectableItem:
			var item = ray.get_collider()
			item.on_item_use()
		
	if hud.is_book_open:
		if Input.is_action_just_pressed("ui_right"):
			hud.flip_book_page(true)
		if Input.is_action_just_pressed("ui_left"):
			hud.flip_book_page(false)


func update_player_position(delta):
	var move_speed = SPRINT_SPEED if is_sprinting else SPEED
	falling_speed += GRAVITY * delta
	if self.is_on_floor():
		falling_speed = 0.0
	var gravity = falling_speed * Vector3(0, -1, 0)
	self.move_and_slide(move_dir * move_speed + gravity, Vector3(0, 1, 0), true)


func handle_item_selection(_delta):
	"""
	Checks if the player is pointing at an item within touching range, and
	calls the selection method on that item
	TODO: Refactor this to avoid the dependencies on HUD?
	"""
	hud.set_description("")
	if ray.is_colliding() and ray.get_collider() is SelectableItem:
		var item = ray.get_collider()
		item.on_item_selected()


func _input(event):
	if not (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		return

	camera.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
	self.rotate_y(deg2rad(-event.relative.x * MOUSE_SENSITIVITY))

	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -80, 80)
