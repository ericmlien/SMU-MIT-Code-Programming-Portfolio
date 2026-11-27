@tool
class_name BehaviorTreeTimerBaseNode
extends BehaviorTreeLeafNode

@export var wait_time: float = 0.0
@export var is_one_shot: bool = true
var timer: Timer
var is_ticking: bool = false

func set_node_name() -> void:
	behavior_tree_node_name = "Timer"

func get_wait_time() -> float:
	return wait_time

func start_timer() -> void:
	if !timer:
		timer = Timer.new()
		add_child(timer)
		timer.timeout.connect(func(): is_ticking = false)
	timer.one_shot = is_one_shot
	
	is_ticking = true
	timer.start(get_wait_time())
	
func reset() -> void:
	super.reset()
	if timer:
		timer.stop()
	is_ticking = false
