@tool
class_name StallBehaviorAction
extends BehaviorTreeTimerBaseNode

func set_node_name() -> void:
	behavior_tree_node_name = "Stall"

func enter() -> void:
	agent_inputs.move_direction(Vector3.ZERO)
	super.enter()
	start_timer()

func behavior_process(delta: float) -> Status:
	if !is_ticking && agent.horizontal_velocity.is_zero_approx():
		return Status.SUCCESS
	return Status.IN_PROGRESS

func reset() -> void:
	super.reset()
	if agent_inputs:
		agent_inputs.move_direction(Vector3.ZERO)
