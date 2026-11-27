class_name InputComponent
extends Node

var current_move_direction: Vector3 = Vector3.ZERO
var last_move_direction: Vector3 = Vector3.FORWARD
var is_movement_enabled: bool = false
var entity: Entity = null
var sprinting: bool = false


signal input_detected()
signal move_input_detected(move_dir: Vector3)
signal move_input_released(last_move_dir: Vector3)
signal jump_input_detected()
signal jump_input_released()
signal attack_input_detected(atk_input: String)
signal attack_input_released(atk_input: String)
signal sprint_input_detected()
signal sprint_input_released()

func move_direction (move_dir: Vector3) -> void:
	last_move_direction = current_move_direction
	current_move_direction = move_dir.normalized()
	#print("Input Component: last_move_direction:", last_move_direction)
	#print("Input Component: current_move_direction:", current_move_direction)
	if (move_dir == Vector3.ZERO):
		move_input_released.emit(last_move_direction)
		return
	move_input_detected.emit(move_dir.normalized())
	input_detected.emit()

func jump() -> void:
	jump_input_detected.emit()
	input_detected.emit()

func release_jump() -> void:
	jump_input_released.emit()
	
func attack(atk_input: String) -> void:
	print("Input Component: attack input detected! id: ", atk_input)
	input_detected.emit()
	if entity.movement_fsm.current_state is HitstunEntityState:
		return
	attack_input_detected.emit(atk_input)

func release_attack(atk_input: String) -> void:
	print("Input Component: attack input released! id: ", atk_input)
	attack_input_released.emit(atk_input)

func sprint() -> void:
	if sprinting == false:
		sprint_input_detected.emit()
	sprinting = true

func release_sprint() -> void:
	if sprinting == true:
		sprint_input_released.emit()
	sprinting = false

func get_move_direction() -> Vector3:
	return current_move_direction

func get_input_move_rotation() -> float:
	return 0.0
	
func get_last_move_direction() -> Vector3:
	return last_move_direction
