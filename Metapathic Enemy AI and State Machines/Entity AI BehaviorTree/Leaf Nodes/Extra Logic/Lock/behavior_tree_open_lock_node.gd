@icon("res://Assets/Node Icons/BehaviorTree Node Icons/open_lock.png")

@tool
class_name BehaviorTreeOpenLockNode
extends BehaviorTreeNode

@export var locks: Array[BehaviorTreeLockNode]

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if locks.size() == 0:
		return ["This OpenLock node needs a lock to open!"]
	return []

func set_node_name() -> void:
	behavior_tree_node_name = "OpenLock"

func init(agent: NPC) -> void:
	super.init(agent)
	if locks.size() == 0:
		push_error(behavior_tree_node_name, " doesn't have a lock to open!")

func behavior_process(delta: float) -> Status:
	for lock in locks:
		lock.lock_in()
	return Status.SUCCESS
