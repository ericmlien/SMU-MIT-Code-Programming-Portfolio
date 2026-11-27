@tool
class_name DoActionBehaviorAction
extends BehaviorTreeLeafNode

@export var action_name: String
@export var hold_input_duration: float = 0.0
var hold_input_timer: Timer
var can_act: bool = true
var is_action_finished: bool = false

func set_node_name() -> void:
	behavior_tree_node_name = "DoAction"

func enter() -> void:
	can_act = agent.can_act()
	if !can_act:
		return
	is_action_finished = false
	
	agent_inputs.attack(action_name)
	
	agent.action_manager.action_finished.connect(on_action_finished)
	
	if !hold_input_timer:
		hold_input_timer = Timer.new()
		hold_input_timer.wait_time = hold_input_duration or 0.01
		hold_input_timer.one_shot = true
		hold_input_timer.timeout.connect(on_hold_input_timer_timeout)
		add_child(hold_input_timer)
	hold_input_timer.start()

func behavior_process(delta: float) -> Status:
	if !can_act:
		print(behavior_tree_node_name, ": Action is unavailable!")
		return Status.FAILURE
	
	if is_action_finished:
		print(behavior_tree_node_name, ": Action is finished!!")
		return Status.SUCCESS
	
	return Status.IN_PROGRESS

func exit() -> void:
	super.exit()
	agent.action_manager.action_finished.disconnect(on_action_finished)

func on_hold_input_timer_timeout() -> void:
	agent_inputs.release_attack(action_name)

func on_action_finished() -> void:
	is_action_finished = true
	
func reset() -> void:
	if !just_started:
		if agent.action_manager.action_finished.is_connected(on_action_finished):
			agent.action_manager.action_finished.disconnect(on_action_finished)
		
		agent_inputs.release_attack(action_name)
	
	super.reset()
	is_action_finished = false
	can_act = true
