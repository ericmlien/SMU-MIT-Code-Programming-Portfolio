# BehaviorTreeLeafNodes are the actual Queries & Actions that our AI behavior will use!

# Two Types of Leaf Nodes: Can either be a Query or an Action.
# 	Actions can return 3 states: SUCCESS, FAILURE, and IN_PROGRESS.
# 	Queries will just return SUCCESS or FAILURE.
@tool
class_name BehaviorTreeLeafNode
extends BehaviorTreeNode

## Tracks if this Leaf Node just started! 
## Useful for when you want to do get some data at the start of the process
## For example, getting the position of something at the start of the action or query.
var just_started: bool = true

func reset() -> void:
	if !just_started:
		exit()
	just_started = true

func _behavior_process(delta: float) -> Status:
	if just_started:
		enter()
	just_started = false
	var status: Status = behavior_process(delta)
	if status == Status.FAILURE || status == Status.SUCCESS:
		exit()
	return status

## If you want to get any information or do anything in the start of your action, override this funcdion!
func enter() -> void:
	pass

## If you want to do anything in the end of your action, override this funcdion!
func exit() -> void:
	just_started = true
	pass

func set_node_name() -> void:
	behavior_tree_node_name = "Leaf"

func lateral_to_agent_up(vector: Vector3) -> Vector3:
	return vector - vector.dot(agent.up_direction) * agent.up_direction

func vertical_to_agent_up(vector: Vector3) -> Vector3:
	return vector.dot(agent.up_direction) * agent.up_direction
