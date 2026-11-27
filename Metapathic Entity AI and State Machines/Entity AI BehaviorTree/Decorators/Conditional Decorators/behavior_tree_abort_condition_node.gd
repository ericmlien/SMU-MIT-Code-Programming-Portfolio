# This decorator node takes in TWO children and extends ConditionNode.
# The first child is the condition, while the second child is the action(s).
# 
# This node is mainly for when you want an action to immediately abort and return FAILURE upon some condtitions not being met.
# Think of it this way:
	# This action will run as long as the above conditions are true.
	# If the action returns SUCCESS, the whole AbortCondition node will return SUCCESS.
	# If the action returns FAILURE, the whole AbortCondition node will return SUCCESS.
	# However, if the action returns IN_PROGRESS,
		# if the condition node returned SUCCESS, the whole AbortCondition return IN_PROGRESS.
		# if the condition node returned FAILURE, the whole AbortCondition return FAILURE.
#
# Example of node tree structure:
# AbortConditionNode
# 	Sequence: (Condition)
# 		PlayerInRange
# 		InverterNode:
# 			IsTooFarFromStartPoint
# 	WalkToPlayer (Action)
# 
# This example is saying:
	# WHILE the player is within range, 
	# AND I haven't gotten too far from my start_point,
		# Chase the player
	# If any of the above conditions flags as FAILURE, the whole Sequence (Condition) will return FAILURE.
	# While we're chasing the player, the WalkToPlayer node's status will be IN_PROGRESS.
	# If we are currently chasing the player and the Sequence (Condition) returns FAILURE,
		# We abort the action, and instead of returning IN_PROGRESS, 
		# The AbortConditionNode cuts the action off prematurely and return FAILURE.

# You might be thinking- why do we need this? WELL IM GLAD YOU ASKED!
# Our Sequence and Selector Nodes are great for organizing behaviors, but they have one flaw:
	# The IN_PROGRESS status!
# Take our WalkToPlayer Node for example:
	# We start walking to the player, and we CONTINUE to do this until we reach our destination
# Our Sequences and Selector nodes iterate through their children using the child_count variable.
# The child_count doesn't change if that node returns IN_PROGRESS.
# Meaning, if we rawdog a WalkToPlayer action inside a Selector or Sequence,
# If we never reach our destination, the Selector/Sequence is locked into running that behavior.
# The AbortCondition node allows us to check conditions every _behavior_process(delta).
# Now, thanks to the ConditioNode the Sequence/Selector thinks its running just one action,
	# But in reality, its a bunch of conditions and an action in a trenchcoat

@tool
class_name BehaviorTreeAbortConditionNode
extends BehaviorTreeConditionNode

var action: BehaviorTreeNode = null

func set_node_name() -> void:
	behavior_tree_node_name = "AbortCondition"

func set_actions() -> void:
	if _children.size() != 2:
		push_error(behavior_tree_node_name, ": this node requires exactly 2 children! no more no less no service!")
	action = _children[1]
	if action == null:
		push_error(behavior_tree_node_name, ": didn't get an action node!")
	
func _behavior_process(delta: float) -> Status:
	var condition_status = condition._behavior_process(delta)
	match condition_status:
		Status.FAILURE:
			if flip_condition_bool(true):
				action.reset()
			return condition_status
		Status.SUCCESS:
			flip_condition_bool(false)
			return action._behavior_process(delta)
		_:
			return Status.IN_PROGRESS
