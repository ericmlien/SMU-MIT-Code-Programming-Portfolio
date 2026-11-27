# This Behavior Tree is the BASE CLASS for which interior nodes, sequences, and selectors derive from.

# These all share a base class because when instantiated, the constructor takes in an array of other class members.
# This array could be a simple behavior by itself, or a container like a sequence or selector.
# For this, we need a base class that unifies all of them to be recognized as the same class type!

# Oh yeah. A behavior tree is essentially a step-by-step order of queries and actions.

# BEHAVIOR TREE NODE process(): returns SUCCESS, FAILURE, and IN_PROGRESS.
# Two Types of Leaf Nodes: Can either be a Query or an Action.
# 	Actions can return 3 states: SUCCESS, FAILURE, and IN_PROGRESS.
# 	Queries will just return SUCCESS or FAILURE.

# We organize our behavior of these nodes through Selectors and Sequences 
# See behavior_tree_branch_node.gd for more.
@tool
class_name BehaviorTreeNode
extends Node

## The return result of a BehaviorTreeNode's process() function. Sequences, Selectors, and Leaf Nodes (Actions & Queries) all use this enum.
enum Status {SUCCESS, FAILURE, IN_PROGRESS}

@export var behavior_tree_node_name: String

### Priority for our priority selector, which sorts its children array based on priority from Highest to Lowest. Default is 0.
#@export var priority: int = 0

var agent: NPC = null
var agent_inputs: InputComponent = null

func _behavior_process(delta: float) -> Status:
	return behavior_process(delta)

## Process function for BehaviorTreeNodes. 
## For Sequences and Selectors, this will run their current leaf node's process, which will either be an action or a query
func behavior_process(delta: float) -> Status:
	return Status.SUCCESS

## Reset this node.
func reset() -> void:
	pass

func _init() -> void:
	set_node_name()

func init(agent: NPC) -> void:
	self.agent = agent
	self.agent_inputs = agent.input_component
	setup()

## Function for any nodes that want to gain any information or subscribe to any signals on the NPC on init().
func setup() -> void:
	pass

func set_node_name() -> void:
	behavior_tree_node_name = "Node"

func get_node_name() -> String:
	return behavior_tree_node_name

func has_ai() -> bool:
	return agent is NavigatingNPC

func status_to_string(status: Status) -> String:
	match status:
		Status.SUCCESS:
			return "SUCCESS"
		Status.FAILURE:
			return "FAILURE"
		_: 
			return "IN_PROGRESS"
