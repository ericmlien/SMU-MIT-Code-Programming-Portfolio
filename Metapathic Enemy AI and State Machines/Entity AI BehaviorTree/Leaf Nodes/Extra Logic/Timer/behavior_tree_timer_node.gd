@tool
class_name BehaviorTreeTimerNode
extends BehaviorTreeTimerBaseNode

@export var success_if_ticking: bool = false

func behavior_process(delta: float) -> Status:
	return Status.SUCCESS if is_ticking == success_if_ticking else Status.FAILURE
