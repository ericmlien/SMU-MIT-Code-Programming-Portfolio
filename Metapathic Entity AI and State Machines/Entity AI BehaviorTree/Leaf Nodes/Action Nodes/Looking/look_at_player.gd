@tool
class_name LookAtPlayerAction
extends BehaviorTreeLeafNode

@export var lock_vertical_rotation: bool = true
@export var max_turn_angle: float = 180.0

func set_node_name() -> void:
	behavior_tree_node_name = "LookAtPlayer"

func behavior_process(delta: float) -> Status:
	var to_player = GameManager.player.global_position - agent.mesh_holder.global_position
	if lock_vertical_rotation:
		to_player = agent.align_to_entity_up_direction_horizontal(to_player)
	
	var current_forward = -agent.mesh_holder.global_transform.basis.z
	if lock_vertical_rotation:
		current_forward = agent.align_to_entity_up_direction_horizontal(current_forward)
	
	var turn_angle = current_forward.signed_angle_to(to_player.normalized(), agent.up_direction)
	
	var max_turn_angle_radians = deg_to_rad(max_turn_angle)
	turn_angle = clamp(turn_angle, -max_turn_angle_radians, max_turn_angle_radians)
	
	var look_direction = current_forward.rotated(agent.up_direction, turn_angle).normalized()
	
	agent.override_move_look_direction(look_direction)
	#agent.mesh_holder.look_at(agent.mesh_holder.global_position + look_direction, agent.up_direction)
	return Status.SUCCESS

#var to_player = GameManager.player.global_position
#var agent_horizontal_to_player = agent.align_to_entity_up_direciton_horizontal(to_player)
#var agent_vertical_to_player = agent.align_to_entity_up_direciton_vertical(to_player)
#if lock_vertical_rotation:
	#agent_vertical_to_player = Vector3.ZERO
#agent.mesh_holder.look_at(agent_horizontal_to_player + agent_vertical_to_player, agent.up_direction)
