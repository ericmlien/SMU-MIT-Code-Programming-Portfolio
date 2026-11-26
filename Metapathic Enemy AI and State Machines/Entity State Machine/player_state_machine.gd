class_name PlayerStateMachine
extends EntityStateMachine

func init(entity: Entity) -> void:
	super.init(entity)
	if inputs is not PlayerInputComponent:
		push_error("PlayerStateMachine: didn't receive player input component!!!")
	
