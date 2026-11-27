@tool
class_name IsPlayerInRangeBehaviorQuery
extends BehaviorTreeLeafNode

@export var range: float = 10.0

func set_node_name() -> void:
	behavior_tree_node_name = "IsPlayerInRange"

func behavior_process(delta: float) -> Status:
	if !GameManager.player:
		return Status.FAILURE
	
	var distance_to_player = (GameManager.player.global_position - agent.global_position).length()
	
	if distance_to_player < range:
		#print("IsPlayerInRangeQuery: Player is within range! range: ", range, "distance: ", distance_to_player)
		return Status.SUCCESS
	else:
		#print("IsPlayerInRangeQuery: Player is NOT within range! range: ", range, "distance: ", distance_to_player)
		return Status.FAILURE
