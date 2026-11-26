## The base class for all state data resources!
## Stuff like running move-speed, any timers, can be set oon these resources!
@tool
class_name StateData
extends Resource

@export var state_name: String

func _init() -> void:
	set_state_name()
	pass

func set_state_name() -> void:
	pass
