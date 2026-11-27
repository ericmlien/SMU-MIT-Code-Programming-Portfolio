# Like the AbortConditionNode except if our condition gets FAILURE, we run a second action instead!
# 
# Example of node tree structure:
# SwitchCondition
	# Sequence
		# IsPlayerInRange
		# IsStartPointInRange
	# WalkToPlayer
	# ReturnToStartPoint
# 
# This allows actions, mainly locomotive ones to be switched on a dime based on a condition.
# This will mainly be used for switching between idle and active states.
# Tho honestly the above example is what I was trying to make until I realized I could make this and make it way easier!
# If this ends up not being useful for anything else then idk i owe u a baja blast

# another thing: this condition node will return FAILURE if the condition yields FAILURE.
# 	in other words: if action_if_failure returns SUCCESS or FAILURE, this node returns FAILURE.
#	if action_if_failure returns IN_PROGRESS, it still returns IN_PROGRESS.

@tool
class_name BehaviorTreeSwitchConditionNode
extends BehaviorTreeConditionNode

var action_if_success: BehaviorTreeNode = null
@export var reset_success_action_on_switch: bool = true

var action_if_failure: BehaviorTreeNode = null
@export var reset_failure_action_on_switch: bool = true

func set_node_name() -> void:
	behavior_tree_node_name = "SwitchCondition"

func set_actions() -> void:
	if _children.size() != 3:
		push_error(behavior_tree_node_name, ": node requires exactly 2 children! no more no less no service!")
	action_if_success = _children[1]
	action_if_failure = _children[2]
	if action_if_success == null || action_if_failure == null:
		push_error(behavior_tree_node_name, ": didn't get condition or action nodes!")
	
func _behavior_process(delta: float) -> Status:
	var condition_status = condition._behavior_process(delta)
	#if condition_status != Status.IN_PROGRESS:
		#print (behavior_tree_node_name, ": condition status: ", status_to_string(condition_status))
	
	match condition_status:
		Status.FAILURE:
			if flip_condition_bool(false) && reset_success_action_on_switch:
				action_if_success.reset()
			var result_on_failure = action_if_failure._behavior_process(delta)
			if result_on_failure == Status.IN_PROGRESS:
				return Status.IN_PROGRESS
			return Status.FAILURE
		Status.SUCCESS:
			if flip_condition_bool(true) && reset_failure_action_on_switch:
				action_if_failure.reset()
			return action_if_success._behavior_process(delta)
		_:
			return Status.IN_PROGRESS
