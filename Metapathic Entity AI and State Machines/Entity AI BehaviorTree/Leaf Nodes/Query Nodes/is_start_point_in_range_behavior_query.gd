@tool
class_name IsStartPointInRangeBehaviorQuery
extends BehaviorTreeLeafNode

@export var range: float = 10.0

func set_node_name() -> void:
	behavior_tree_node_name = "IsTooFarFromStartPoint"

func behavior_process(delta: float) -> Status:
	var distance_to_start_point = (agent.start_point - agent.global_position).length()
	
	if distance_to_start_point < range:
		#print(get_node_name(), ": We're still in range of start point!! range: ", range, " distance: ", distance_to_start_point)
		return Status.SUCCESS
	else:
		#print(get_node_name(), ": Got too far from start point!! range: ", range, " distance: ", distance_to_start_point)
		return Status.FAILURE
