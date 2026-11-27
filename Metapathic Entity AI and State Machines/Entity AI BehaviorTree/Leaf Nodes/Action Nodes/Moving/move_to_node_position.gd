@tool
class_name MoveToNodeBehaviorPosition
extends BehaviorTreeLeafNode

@export var destination_node: Node3D = null
@export var destination_reached_range: float = 3.0
@export var lateral_only: bool = true

func set_node_name() -> void:
	behavior_tree_node_name = "MoveToNodePosition"

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if destination_node == null:
		return ["This MoveToNodePosition needs a Node to go to!"]
	return []

func init(agent: NPC) -> void:
	super.init(agent)
	if destination_node == null:
		push_error(behavior_tree_node_name, ": doesn't have a destination_node!")

func behavior_process(delta: float) -> Status:
	var to_destination_node: Vector3 = Vector3.ZERO
	if has_ai():
		return Status.SUCCESS
	
	to_destination_node = destination_node.global_position - agent.global_position
	#print(behavior_tree_node_name, ": to_destination_node.length(): ", to_destination_node.length())
	if to_destination_node.length() <= destination_reached_range:
		agent_inputs.move_direction(Vector3.ZERO)
		return Status.SUCCESS
	
	if lateral_only:
		to_destination_node = lateral_to_agent_up(to_destination_node)
	
	agent_inputs.move_direction(agent.align_to_entity_basis(to_destination_node.normalized()))
	return Status.IN_PROGRESS

func reset() -> void:
	super.reset()
	if agent_inputs:
		agent_inputs.move_direction(Vector3.ZERO)
