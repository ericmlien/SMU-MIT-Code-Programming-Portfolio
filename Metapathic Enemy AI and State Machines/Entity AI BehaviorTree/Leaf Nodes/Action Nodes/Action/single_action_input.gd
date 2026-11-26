@tool
class_name SingleActionInputBehaviorAction
extends BehaviorTreeLeafNode

@export var action_name: String

func set_node_name() -> void:
	behavior_tree_node_name = "Single_Action_Input"

func behavior_process(delta: float) -> Status:
	print(agent.entity_name, ": can attack: ", agent.can_act())
	agent_inputs.attack(action_name)
	agent_inputs.release_attack(action_name)
	return Status.SUCCESS
