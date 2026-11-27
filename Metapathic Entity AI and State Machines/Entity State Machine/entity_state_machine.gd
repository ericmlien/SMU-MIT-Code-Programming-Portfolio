class_name EntityStateMachine
extends Node

var entity: Entity = null
var state_dictionary: Dictionary
var prev_state: EntityState = null
var current_state: EntityState = null
var inputs: InputComponent
@export var data: StateMachineData

signal state_changed(new_state_name: String)

func init(entity: Entity) -> void:
	self.entity = entity
	self.inputs = entity.input_component
	create_state_dictionary()

func create_state_dictionary() -> void:
	state_dictionary = { }
	
	for child: EntityState in get_children():
		child.init(entity, self)
		state_dictionary.set(child.get_state_name(), child)
		print("Added " + child.get_state_name() + " state to Behavior dictionary")
		
	print(state_dictionary.keys())
	
	print("Parent: " + entity.name)
	change_state("Idle")
	

func current_state_process(delta: float) -> void:
	current_state._state_process(delta)

func change_state(new_state_name: String) -> void:
	if !state_dictionary.has(new_state_name):
		print(entity.entity_name, " tried to go from \"", current_state.get_state_name(), "\" to \"", new_state_name, "\", but the new state doesn't exist!")
		return
	
	var new_state: EntityState = null
	new_state = state_dictionary[new_state_name]
	if !new_state.can_enter():
		return

	#print(entity.entity_name, "'s State Machine is switching states!")
	#print("Current State: ",  current_state.state_name if current_state != null else "none")
	#print("New State: ", new_state_name)

	if current_state != null:
		prev_state = current_state
		current_state._exit()
	current_state = new_state
	new_state._enter()
	state_changed.emit(new_state_name)

func get_prev_state() -> String:
	return prev_state.state_name
	
