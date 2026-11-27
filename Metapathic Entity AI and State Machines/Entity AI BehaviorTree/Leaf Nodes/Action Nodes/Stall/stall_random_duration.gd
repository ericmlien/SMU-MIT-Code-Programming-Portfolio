@tool
class_name StallRandomDurationBehaviorAction
extends StallBehaviorAction

@export var min_wait_time: float = 0.0
@export var max_wait_time: float = 1.0

func set_node_name() -> void:
	behavior_tree_node_name = "StallRandomDuration"

func _validate_property(property: Dictionary):
	if property.name == "wait_time":
		property.usage &= ~PROPERTY_USAGE_EDITOR

func get_wait_time() -> float:
	return randf_range(min_wait_time, max_wait_time)
