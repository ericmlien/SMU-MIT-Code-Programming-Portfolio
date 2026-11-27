@tool
class_name WalkToRandomPointInRange
extends BehaviorTreeLeafNode

@export var range: float = 10.0
@export var min_distance: float = 3.0
@export var destination_reached_range: float = 1.0
@export var use_start_point: bool = false
var destination: Vector3 = Vector3.ZERO

func set_node_name() -> void:
	behavior_tree_node_name = "WalkToRandomPointInRange"

func get_random_point(range: float) -> Vector3:
	var radius = randf_range(min_distance, range) * sqrt(randf())
	var angle = randf() * TAU
	var random_point = agent.align_to_entity_up_direction_horizontal(Vector3(cos(angle) * radius, 0.0, sin(angle) * radius))
	
	return agent.start_point + random_point if use_start_point else agent.global_position + random_point

func enter() -> void:
	destination = get_random_point(range)
	if has_ai():
		agent.navi_agent.target_position = destination

func behavior_process(delta: float) -> Status:
	var lateral_to_point = destination - agent.global_position
	
	if has_ai():
		var lateral_next_ai_point = agent.navi_agent.get_next_path_position()
		var lateral_next_ai_step_direction = lateral_next_ai_point - agent.global_position
		lateral_next_ai_step_direction = agent.align_to_entity_up_direction_horizontal(lateral_next_ai_step_direction)
		
		if lateral_to_point.length() <= destination_reached_range:
			agent_inputs.move_direction(Vector3.ZERO)
			return Status.SUCCESS
		agent_inputs.move_direction(agent.align_to_entity_basis(lateral_next_ai_step_direction).normalized())
	else:
		if lateral_to_point.length() <= destination_reached_range:
			agent_inputs.move_direction(Vector3.ZERO)
			return Status.SUCCESS
		
		agent_inputs.move_direction(agent.align_to_entity_basis(lateral_to_point).normalized())
	return Status.IN_PROGRESS

func reset() -> void:
	super.reset()
	if agent_inputs:
		agent_inputs.move_direction(Vector3.ZERO)
