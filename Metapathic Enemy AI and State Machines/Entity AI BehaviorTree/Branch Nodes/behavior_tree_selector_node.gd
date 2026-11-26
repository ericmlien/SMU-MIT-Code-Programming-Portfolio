@icon("res://Assets/Node Icons/BehaviorTree Node Icons/selector.png")

# SELECTOR:
#	If a node returns FAILURE, move on to the next one
# 	Only returns FAILURE if and only if ALL of its children return FAILURE.
# 	If ANY child returns SUCCESS, cuts off early and returns SUCCESS.

@tool
class_name BehaviorTreeSelectorNode
extends BehaviorTreeBranchNode

func set_node_name() -> void:
	behavior_tree_node_name = "Selector"

func behavior_process(delta: float) -> Status:
	if _current_child >= _children.size():
		_current_child = 0
		return Status.FAILURE
		
	var current_child_status: Status = _children[_current_child]._behavior_process(delta)
	
	if current_child_status == Status.SUCCESS:
		_current_child = 0
		return Status.SUCCESS
	
	if current_child_status == Status.FAILURE:
		_current_child += 1
	
	return Status.IN_PROGRESS
