@tool
extends BehaviorTreeLeafNode
class_name UnlockLookOverrideBehaviorAction

func set_node_name() -> void:
	behavior_tree_node_name = "UnlockLookOverride"

func behavior_process(delta: float) -> Status:
	agent.unlock_move_look_direction()
	return Status.SUCCESS
