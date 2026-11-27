@tool
class_name MoveStateData
extends StateData

@export_group("Move State Vars!")
@export var move_speed: float
@export var move_acceleration: float
@export var move_gravity_multiplier: float

func set_state_name() -> void:
	state_name = "Move"
