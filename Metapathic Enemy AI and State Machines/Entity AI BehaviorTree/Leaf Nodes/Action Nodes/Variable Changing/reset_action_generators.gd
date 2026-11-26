@tool
class_name ResetActionGeneratorsBehaviorAction
extends BehaviorTreeLeafNode

func set_node_name() -> void:
	behavior_tree_node_name = "ResetActionGenerators"

func behavior_process(delta: float) -> Status:
	agent.action_manager.reset_generators()
	return Status.SUCCESS
