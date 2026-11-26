@icon("res://Assets/Node Icons/BehaviorTree Node Icons/return_to_start_point.png")

@tool
class_name ReturnToStartPointBehaviorAction
extends BehaviorTreeLeafNode

@export var destination_reached_range: float = 1.0

func set_node_name() -> void:
	behavior_tree_node_name = "ReturnToStartPoint"

func enter() -> void:
	if has_ai():
		agent.navi_agent.set_target_position(agent.start_point)

func behavior_process(delta: float) -> Status:
	var lateral_to_start_point: Vector3
	
	if has_ai():
		var lateral_next_ai_step = agent.navi_agent.get_next_path_position()
		lateral_to_start_point = lateral_next_ai_step - agent.global_position
		
		if agent.navi_agent.is_target_reached():
			agent_inputs.move_direction(Vector3.ZERO)
			return Status.SUCCESS
		
		lateral_to_start_point = lateral_to_agent_up(lateral_to_start_point)
		agent_inputs.move_direction(agent.align_to_entity_basis(lateral_to_start_point.normalized()))
		
	else:
		lateral_to_start_point = agent.start_point - agent.global_position
		
		if lateral_to_start_point.length() <= destination_reached_range:
			agent_inputs.move_direction(Vector3.ZERO)
			return Status.SUCCESS
		
		lateral_to_start_point = lateral_to_agent_up(lateral_to_start_point)
		agent_inputs.move_direction(agent.align_to_entity_basis(lateral_to_start_point.normalized()))
	
	#print(agent.entity_name, " RETURN TO START POINT")
	#print(agent.entity_name, " Current state: ", agent.movement_fsm.current_state.state_name)
	#print(agent.entity_name, ": Move Direction: ", agent.input_component.current_move_direction)
	
	return Status.IN_PROGRESS

#func reset() -> void:
	#super.reset()
	#if agent_inputs:
		#agent_inputs.move_direction(Vector3.ZERO)
