@icon("res://Assets/Node Icons/BehaviorTree Node Icons/walk_to_player.png")

@tool
class_name WalkToPlayerBehaviorAction
extends BehaviorTreeLeafNode

@export var destination_reached_range: float = 3.0

func set_node_name() -> void:
	behavior_tree_node_name = "WalkToPlayer"

func behavior_process(delta: float) -> Status:
	var lateral_to_player = GameManager.player.global_position - agent.global_position
	
	if has_ai():
		if agent.navi_agent.get_target_position().distance_to(GameManager.player.global_position) > 0.5:
			agent.navi_agent.target_position = GameManager.player.global_position
		
		var lateral_next_ai_point = agent.navi_agent.get_next_path_position()
		var lateral_next_ai_step_direction = lateral_next_ai_point - agent.global_position
		lateral_next_ai_step_direction = lateral_to_agent_up(lateral_next_ai_step_direction)
		
		if lateral_to_player.length() <= destination_reached_range:
			agent_inputs.move_direction(Vector3.ZERO)
			return Status.SUCCESS
		agent_inputs.move_direction(agent.align_to_entity_basis(lateral_next_ai_step_direction).normalized())
	else:
		if lateral_to_player.length() <= destination_reached_range:
			agent_inputs.move_direction(Vector3.ZERO)
			return Status.SUCCESS
		lateral_to_player = lateral_to_agent_up(lateral_to_player)
		agent_inputs.move_direction(agent.align_to_entity_basis(lateral_to_player).normalized())
	
	#print(agent.entity_name, " Current state: ", agent.movement_fsm.current_state.state_name)
	#print(agent.entity_name, ": Move Direction: ", agent.input_component.current_move_direction)
	
	return Status.IN_PROGRESS

#func reset() -> void:
	#super.reset()
	#if agent_inputs:
		#agent_inputs.move_direction(Vector3.ZERO)
