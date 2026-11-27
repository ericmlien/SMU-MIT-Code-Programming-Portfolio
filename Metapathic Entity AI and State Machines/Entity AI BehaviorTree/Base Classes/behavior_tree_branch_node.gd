# BehaviorTreeBranchNodes are nodes that iterate through their children! They're what form the logic behind the tree.
# For now, we'll have two types: Sequences and Selectors.

# What's a Sequence or Selector? WELL IM GLAD U ASKED
# Both sequences and selectors iterate through their children, executing them one by one in their process().
# As they execute their children, they check each child's result.
# Sequences and Selectors are different only in how they react to their childrens' results.
# These children can be Leaf Nodes (Actions & Queries), or other Branch Nodes (Sequences & Selectors).

# SEQUENCE:
#	If a node returns SUCCESS, move on to the next one
# 	Only returns SUCCESS if and only if ALL of its children return SUCCESS.
# 	If ANY child returns FAILURE, it cuts off early and returns FAILURE.

# SELECTOR:
#	If a node returns FAILURE, move on to the next one
# 	Only returns FAILURE if and only if ALL of its children return FAILURE.
# 	If ANY child returns SUCCESS, cuts off early and returns SUCCESS.

# The root node of Behavior Tree is usually a Selector.
@tool
class_name BehaviorTreeBranchNode
extends BehaviorTreeNode

## Private variable for a behavior tree node like a Sequence or a Selector to iterate through its queries and actions
var _children: Array[BehaviorTreeNode]

## Current active Query or Action to run or is currently running
@export var _current_child: int = 0

## This method will be used on start to get all the children nodes from the inspector and use that to assemble the behavior tree.
func add_child_node(child: BehaviorTreeNode):
	_children.append(child)

## Reset this node and all of its children
func reset() -> void:
	_current_child = 0
	for child in _children:
		child.reset()

func init(agent: NPC) -> void:
	super.init(agent)
	set_children_array()

func set_children_array() -> void:
	var array_string: String = ""
	for child: BehaviorTreeNode in get_children():
		child.init(self.agent)
		add_child_node(child)
		print("Added " + child.get_node_name() + " state to ", behavior_tree_node_name, "'s children array")
		array_string += child.get_node_name() + ", "
	print(behavior_tree_node_name, "'s children array: ", array_string)
