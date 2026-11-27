@icon("res://Assets/Node Icons/BehaviorTree Node Icons/mark_as_busy.png")

# Marks the agent NPC as busy. 
# This will let the npc manager know not to disable them while the player isn't looking away.
# Will return SUCCESS ALWAYS.

@tool
class_name MarkAsBusyBehaviorAction
extends BehaviorTreeLeafNode

func set_node_name() -> void:
	behavior_tree_node_name = "MarkAsBusy"

func behavior_process(delta: float) -> Status:
	agent.mark_as_busy()
	return Status.SUCCESS
