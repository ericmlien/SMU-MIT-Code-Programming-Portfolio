@icon("res://Assets/Node Icons/BehaviorTree Node Icons/close_lock.png")
@tool
class_name BehaviorTreeCloseLockNode
extends BehaviorTreeNode

@export var locks: Array[BehaviorTreeLockNode]

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if locks.size() == 0:
		return ["This CloseLock node needs a lock to open!"]
	return []

func set_node_name() -> void:
	behavior_tree_node_name = "CloseLock"

func init(agent: NPC) -> void:
	super.init(agent)
	if locks.size() == 0:
		push_error(behavior_tree_node_name, " doesn't have a lock to open!")

func behavior_process(delta: float) -> Status:
	#print(behavior_tree_node_name, "attempting to LOCK OUT")
	for lock in locks:
		lock.lock_out()
	#print(behavior_tree_node_name, "'s lock's locked_in: ", lock.locked_in)
	return Status.SUCCESS
