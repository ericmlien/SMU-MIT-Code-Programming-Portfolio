@tool
class_name RandomJumpEveryFrameBehaviorAction
extends BehaviorTreeLeafNode

@export var chance: float = 0.005
@export var destination_reached_range: float = 3.0

func set_node_name() -> void:
	behavior_tree_node_name = "RandomJumpEveryFrame"

func enter() -> void:
	agent.mark_as_busy()

func behavior_process(delta: float) -> Status:
	var lateral_to_player = Vector3.ZERO
	if has_ai():
		agent.ai_agent.set_target_position(GameManager.player.position)
		lateral_to_player = Vector3(agent.ai_agent.get_next_target_position().x, 0.0, agent.ai_agent.get_next_target_position().z)
	else:
		var lateral_player_position = Vector3(GameManager.player.position.x, 0.0, GameManager.player.position.z)
		var lateral_agent_position = Vector3(agent.position.x, 0.0, agent.position.z)
		lateral_to_player = lateral_player_position - lateral_agent_position
	
	var roll: float = randf()
	
	if roll <= chance:
		agent_inputs.jump()
	
	if lateral_to_player.length() <= destination_reached_range:
		agent_inputs.move_direction(Vector3.ZERO)
		return Status.SUCCESS
	
	agent_inputs.move_direction(lateral_to_player.normalized())
	
	return Status.IN_PROGRESS
 
func reset() -> void:
	super.reset()
	if agent_inputs:
		agent_inputs.move_direction(Vector3.ZERO)
