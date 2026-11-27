@icon("res://Assets/Node Icons/BehaviorTree Node Icons/mark_as_not_busy.png")

# Marks the agent NPC as a goofy little chud. 
# This will let the npc manager know that it's ok for it to disable the NPC while the player's looking away.
# Will return SUCCESS ALWAYS.

@tool
class_name MarkAsNotBusyBehaviorAction
extends BehaviorTreeLeafNode

func set_node_name() -> void:
	behavior_tree_node_name = "MarkAsNotBusy"

func behavior_process(delta: float) -> Status:
	agent.mark_as_chud()
	return Status.SUCCESS
