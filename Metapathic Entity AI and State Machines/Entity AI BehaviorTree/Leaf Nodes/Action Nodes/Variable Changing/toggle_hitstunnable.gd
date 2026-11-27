@tool
class_name ToggleHitstunnableBehaviorAction
extends BehaviorTreeLeafNode

@export var is_hitstunnable: bool = true

func set_node_name() -> void:
	behavior_tree_node_name = "ToggleHitstunnable"

func behavior_process(delta: float) -> Status:
	agent.hitstunnable = is_hitstunnable
	return Status.SUCCESS
