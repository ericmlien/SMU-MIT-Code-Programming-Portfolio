@tool
class_name BehaviorTreeStartTimerNode
extends BehaviorTreeLeafNode

@export var timer_node: BehaviorTreeTimerNode


func set_node_name() -> void:
	behavior_tree_node_name = "StartTimer"

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if timer_node == null:
		return ["This StartTimer node needs a Timer node to start, dummy!"]
	return []

func behavior_process(delta: float) -> Status:
	timer_node.start_timer()
	return Status.SUCCESS
