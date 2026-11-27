# This node is a decorator that a Selector or a Sequence can treat like a single node,
	# but in reality, it's multiple nodes in a trenchcoat!
# More specificlally, this allows some actions to be checked with conditions every frame, 
	# instead than getting stuck in IN_PROGRESS.
# This is just the base class that other condition nodes inherit from. 
# It's got a condition getter function and a function to check the condition's most-recent-status switch.
# flip_condition_bool() allows you to pass in a boolean and set condition_success to that boolean.
	# if condition_success is already equal to that boolean, it returns false, meaning we didn't have to switch.
	# if condition_success was not equal to that boolean, it returns true, meaning we successfully flipped condition_success.
# The main reason to use this function is that sometimes we only want to check if the outcome of the condition changes,
	# instead of doing things based on the condition status every frame, 
	# we can do things only when the outcome actually changes.
	
class_name BehaviorTreeConditionNode
extends BehaviorTreeBranchNode

var condition: BehaviorTreeNode = null
var condition_success: bool = true

func set_node_name() -> void:
	behavior_tree_node_name = "Condition"

func init(agent: NPC) -> void:
	super.init(agent)
	set_condition()
	set_actions()

func set_condition() -> void:
	if _children.size() < 1:
		push_error(behavior_tree_node_name, ": this node requires at least one child!")
	condition = _children[0]
	if condition == null:
		push_error(behavior_tree_node_name, ": didn't get a condition node!")

func set_actions() -> void:
	pass

func flip_condition_bool(to_set: bool) -> bool:
	if condition_success != to_set:
		condition_success = !condition_success
		return true
	return false
