@tool
class_name StallAndTurnBehaviorAction
extends StallBehaviorAction

@export var thing_to_look_at: Vector3
@export var look_at_speed_radians: float = 1.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if thing_to_look_at == null:
		return ["This StallAndTurnBehaviorAction needs a thing to turn towards!"]
	return []


#OOPS UNFINISHED COME BACK LATER!!!!
func behavior_process(delta: float) -> Status:
	
	if stall_timer_finished:
		return Status.SUCCESS
	
	return Status.IN_PROGRESS
	
	
	
