## The collection of StateData that a state machine will use.
## Make an instance of this resource and drag in all of the StateData resources you want for this entity
## Example: Idle, Running, Jumping, etc
class_name StateMachineData
extends Resource

@export var name: String

@export var state_resources: Array[StateData]

## Every state within the state machine should get its corresponding StateData from the array using this method
## Name of the state should match the StateData name.
## Example: Player's idle state calls get_state_by_name("Idle")
func get_state_data_by_name(state_name: String) -> StateData:
	var filtered_resources = state_resources.filter(
		func(state_data): 
			return state_data.state_name == state_name
	)
	
	if filtered_resources.size() > 0:
		print("StateMachineData: adding state_data to: ", state_name)
		return filtered_resources[0]
	print("StateMachineData: Couldn't find data for: ", state_name)
	return null
