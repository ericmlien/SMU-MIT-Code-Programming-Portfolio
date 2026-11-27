@icon("res://Assets/Node Icons/BehaviorTree Node Icons/sequence.png")

# SEQUENCE:
#	If a node returns SUCCESS, move on to the next one
# 	Only returns SUCCESS if and only if ALL of its children return SUCCESS.
# 	If ANY child returns FAILURE, it cuts off early and returns FAILURE.

@tool
class_name BehaviorTreeSequenceNode
extends BehaviorTreeBranchNode

func set_node_name() -> void:
	behavior_tree_node_name = "Sequence"

func behavior_process(delta: float) -> Status:
	if _current_child >= _children.size():
		_current_child = 0
		return Status.SUCCESS
		
	var current_child_status: Status = _children[_current_child]._behavior_process(delta)
	
	if current_child_status == Status.FAILURE:
		_current_child = 0
		return Status.FAILURE
	
	if current_child_status == Status.SUCCESS:
		_current_child += 1
	
	return Status.IN_PROGRESS
