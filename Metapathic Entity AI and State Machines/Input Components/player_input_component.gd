class_name PlayerInputComponent
extends InputComponent

enum InputSource {KEYBOARD, CONTROLLER}
var activeInputSoure = InputSource.KEYBOARD
signal InputSourceChanged(source)

var parent_character: CharacterBody3D

signal dash_input_detected()
signal slide_input_detected()
signal slide_input_released()

var camera_rotation: float
var wall_ray: RayCast3D
var ledge_ray: RayCast3D
var input_buffer : Dictionary[String, int]
var input_buffer_frame_length : int = 15		# zero indexed, so 10 frames

func init(character: CharacterBody3D, wall: RayCast3D, ledge: RayCast3D) -> void:
	parent_character = character
	wall_ray = wall
	ledge_ray = ledge
	
func _ready() -> void:
	ControllerManager.ControllerConnected.connect(_on_Controller_Connected)
	ControllerManager.ControllerDisconnected.connect(_on_Controller_Disconnected)
	
func _detect_Initial_Input_Source():
	if ControllerManager.activeController != -1:
		_setInputSource(InputSource.KEYBOARD)
	else:
		_setInputSource(InputSource.CONTROLLER)

func _process(delta: float) -> void:
	var move_direction: Vector3
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	move_direction = move_direction.normalized()
	if move_direction.normalized() != current_move_direction:
		if move_direction.is_zero_approx():
			move_direction = Vector3.ZERO
		move_direction(move_direction)
		
func _physics_process(delta: float) -> void:
	for key : String in input_buffer.keys():
		if input_buffer[key] > input_buffer_frame_length:
			input_buffer.erase(key)
		else:
			input_buffer[key] += 1

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("jump")):
		jump() 
	elif (event.is_action_released("jump")):
		release_jump()
	
	if (event.is_action_pressed("dash")):
		dash()
	
	if (event.is_action_pressed("slide")):
		slide() 
	elif (event.is_action_released("slide")):
		release_slide()
	
	if (event.is_action_pressed("light attack")):
		attack("light attack")
	
	elif (event.is_action_released("light attack")):
		release_attack("light attack")
		
	if (event.is_action_pressed("heavy attack")):
		attack("heavy attack")
	
	elif (event.is_action_released("heavy attack")):
		release_attack("heavy attack")

func get_input_move_rotation() -> float:
	return camera_rotation

func dash() -> void:
	dash_input_detected.emit()
	input_detected.emit()
	
func slide() -> void:
	slide_input_detected.emit()
	input_detected.emit()

func release_slide() -> void:
	slide_input_released.emit()
	
func do_wall_jump(wall_normal: Vector3) -> void:
	parent_character.velocity.y = maxf(0.0, parent_character.velocity.y) + parent_character.player_move_data.wall_jump_vertical_velocity
	parent_character.velocity += wall_normal * parent_character.player_move_data.wall_jump_normal_velocity

func _on_player_camera_holder_set_cam_rotation(cam_rotation: float) -> void:
	camera_rotation = cam_rotation
	
# get the most recent thing put into the input buffer then get rid
# of everything from the buffer
func get_most_recent_button_from_buffer() -> String:
	var min_val = 10000
	var min_key = ""
	for key in input_buffer.keys():
		if input_buffer[key] < min_val:
			min_val = input_buffer[key]
			min_key = key
	
	input_buffer.clear()
	attack(min_key)
	return min_key
	
func _setInputSource(source: InputSource):
	if activeInputSoure != source:
		activeInputSoure = source
		print("Input source has changed to: ", source)
		InputSourceChanged.emit(source)

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		_setInputSource(InputSource.KEYBOARD)
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_setInputSource(InputSource.CONTROLLER)
		
func _on_Controller_Connected(id):
	_setInputSource(InputSource.CONTROLLER)

func _on_Controller_Disconnected(id):
	_setInputSource(InputSource.KEYBOARD)
	
func RumbleController(intensity = 0.5, duration = 0.5, id = -1):
	if activeInputSoure == InputSource.CONTROLLER:
		ControllerManager.RumbleController(intensity)
