@tool
class_name ToggleSprintBehaviorAction
extends BehaviorTreeLeafNode

@export var sprint_on: bool = true

func set_node_name() -> void:
	behavior_tree_node_name = "ToggleSprint"

func behavior_process(delta: float) -> Status:
	agent_inputs.sprint() if sprint_on else agent_inputs.release_sprint()
	return Status.SUCCESS
