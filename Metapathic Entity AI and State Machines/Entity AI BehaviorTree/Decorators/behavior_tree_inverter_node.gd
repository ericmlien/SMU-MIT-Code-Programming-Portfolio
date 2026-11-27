# The Inverter Node takes in another BehaviorTreeNode as its child.
# This only takes in exactly ONE child node.
# If the child's _behavior_process(delta) status returns SUCCESS, 
	# the inverter returns FAILURE 
	# and vice versa if the _behavior_process(delta) status returns FAILURE
# If the child's status is IN_PROGRESS, 
	# then the inverter's _behavior_process(delta) still returns IN_PROGRESS

@tool
class_name BehaviorTreeInverterNode
extends BehaviorTreeBranchNode

var child: BehaviorTreeNode = null

func init(npc: NPC) -> void:
	super.init(npc)
	set_child()

func set_node_name() -> void:
	behavior_tree_node_name = "Inverter"

func set_child() -> void:
	child = _children[0]
	if child == null:
		push_error("InverterNode: This node needs a child RAHHHH")
	print(behavior_tree_node_name, "'s child to invert: ", child.get_node_name())

func behavior_process(delta: float) -> Status:
	var result = child._behavior_process(delta)
	var inverted_result: Status
	match result:
		Status.SUCCESS:
			inverted_result = Status.FAILURE
		Status.IN_PROGRESS:
			inverted_result = Status.IN_PROGRESS
		_:
			inverted_result = Status.SUCCESS
	#print(get_node_name(), " is inverting: ", child.get_node_name(), " from: ", status_to_string(result), " to: ", status_to_string(inverted_result))
	return inverted_result
