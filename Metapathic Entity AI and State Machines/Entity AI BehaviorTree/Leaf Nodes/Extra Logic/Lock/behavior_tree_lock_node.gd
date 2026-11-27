@icon("res://Assets/Node Icons/BehaviorTree Node Icons/check_car_lock.png")
@tool
class_name BehaviorTreeLockNode
extends BehaviorTreeNode

@export var locked_in: bool = false

func set_node_name() -> void:
	behavior_tree_node_name = "Lock"

func lock_in() -> void:
	if !locked_in:
		print(behavior_tree_node_name, ": is now locked in!")
	locked_in = true

func lock_out() -> void:
	if locked_in:
		print(behavior_tree_node_name, ": is now locked out!")
	locked_in = false

func behavior_process(delta: float) -> Status:
	#print(behavior_tree_node_name, ": locked_in: ", locked_in)
	if locked_in:
		return Status.SUCCESS
	return Status.FAILURE
