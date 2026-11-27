class_name EntityState
extends Node

@export var state_name: String
var entity: Entity = null
var inputs: InputComponent = null
var state_machine: EntityStateMachine = null
var data: StateData = null
var wall_approach_velocity: Vector3 = Vector3.ZERO
var intended_move_velocity: Vector3 = Vector3.ZERO

var gravity: int = ProjectSettings.get_setting("physics/3d/default_gravity")
var wall_side: Vector3
var player_forward: Vector3
	
	
func init(entity, fsm) -> void:
	set_state_name()
	self.entity = entity
	self.state_machine = fsm
	self.inputs = entity.input_component
	self.data = fsm.data.get_state_data_by_name(state_name)
	print(entity.entity_name, "'s ", state_name, "'s state data: ", data.state_name)

func get_state_name() -> String:
	return state_name

func set_state_name() -> void:
	state_name = ""

func can_enter() -> bool:
	return true

func _enter() -> void:
	#print(state_name, ": enter!")
	if inputs:
		subscribe_inputs()
	enter()

func enter() -> void:
	pass

func _exit() -> void:
	#print(state_name, ": exit!")
	if inputs:
		unsubscribe_inputs()
	exit()

func exit() -> void:
	pass

func _state_process(delta: float) -> void:
	check_transition_pre_process(delta)
	if state_machine.current_state != self:
		return
	state_process(delta)
	if state_machine.current_state != self:
		return
	check_transition_post_process(delta)
	

func state_process(delta: float) -> void:
	pass

func check_transition_pre_process(delta: float) -> void:
	pass

func check_transition_post_process(delta: float) -> void:
	pass

func get_move_speed() -> float:
	return 0.0

func get_gravity_mult() -> float:
	return 1.0

func get_move_acceleration() -> float:
	return 0.0

func subscribe_inputs() -> void:
	inputs.jump_input_detected.connect(on_jump)
	inputs.jump_input_released.connect(on_jump_released)
	inputs.move_input_detected.connect(on_move)
	inputs.move_input_released.connect(on_move_released)
	inputs.attack_input_detected.connect(on_action)
	inputs.attack_input_released.connect(on_action_released)
	inputs.sprint_input_detected.connect(on_sprint)
	inputs.sprint_input_released.connect(on_sprint_released)

func unsubscribe_inputs() -> void:
	inputs.jump_input_detected.disconnect(on_jump)
	inputs.jump_input_released.disconnect(on_jump_released)
	inputs.move_input_detected.disconnect(on_move)
	inputs.move_input_released.disconnect(on_move_released)
	inputs.attack_input_detected.disconnect(on_action)
	inputs.attack_input_released.disconnect(on_action_released)
	inputs.sprint_input_detected.disconnect(on_sprint)
	inputs.sprint_input_released.disconnect(on_sprint_released)

func on_jump() -> void:
	pass

func on_jump_released() -> void:
	pass

func on_move(move_dir: Vector3) -> void:
	pass

func on_move_released(last_move_dir: Vector3) -> void:
	pass

func on_dash() -> void:
	pass

func on_slide() -> void:
	pass

func on_slide_released() -> void:
	pass

func on_action(atk_input: String) -> void:
	pass

func on_action_released(atk_input: String) -> void:
	pass

func on_sprint() -> void:
	pass

func on_sprint_released() -> void:
	pass

func play_oneshot_animation(anim_name: String):
	var parameter_path = "parameters/" + anim_name + "/request"
	if entity.anim_tree.get(parameter_path) == null:
		return
	
	entity.anim_tree[parameter_path] = AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_FIRE
	pass

func end_oneshot_animation(anim_name: String):
	var parameter_path = "parameters/" + anim_name + "/request"
	if entity.anim_tree.get(parameter_path) == null:
		return
	
	entity.anim_tree[parameter_path] = AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_FADE_OUT
	pass

func play_animation(anim_name: String, state_machine_name: String) -> void:
	if entity.anim_tree == null || entity.anim_player == null:
		#print("UR ENTITY GOT NO ANIMATIONS SON")
		return
	var full_name: StringName = entity.entity_name + "_" + anim_name
	print("attempting to play:" + full_name)
	var anim_root = entity.anim_tree.tree_root
	if !anim_root:
		return
	var anim_state_machine: AnimationNode = entity.anim_tree.tree_root.get_node(state_machine_name)
	if !anim_state_machine:
		return
	var anim = anim_state_machine.get_node(full_name)
	if anim != null:
		entity.move_tree.travel(full_name)
		print("OMG ANIMATION FOUND ", full_name)
		return
	print("TSPMO :(")

func update_anim_conditional(state_machine_name:String, anim_name: String, condition: String, state: bool)-> void:
	var full_name: StringName = "parameters/"+state_machine_name+"/"+ entity.entity_name + "_" + anim_name+"/conditions/"+condition
	var conditional = entity.anim_tree.get(full_name)
	if conditional != null:
		entity.anim_tree.set(full_name,state)
		print(anim_name, "/conditions/", condition, " -> ", state)
	elif conditional == null:
		print(condition + " does not exist!! L Bozo")
	return
	
	

func play_movement_animation(anim_name: String) -> void:
	play_animation(anim_name, "movement")


func is_valid_approach_angle(wall_normal: Vector3, approach_vector: Vector3) -> bool:
	if entity.movement_fsm.current_state.state_name == "WallSlide":
		return false
	#print("angle starting check")
	if approach_vector.is_zero_approx():
		print("angle jarona 1")
		return false
	#if wall_normal.is_zero_approx():
		#return false
#
	var up_direction = entity.up_direction
	var approach_horizontal = approach_vector - approach_vector.dot(up_direction) * up_direction
	var wall_horizontal = wall_normal - wall_normal.dot(up_direction) * up_direction
	#if approach_horizontal.is_zero_approx() or wall_horizontal.is_zero_approx():
		#return false

	var approach_direction = approach_horizontal.normalized()
	var wall_direction = wall_horizontal.normalized()
	#print("angle approach normalized: ", approach_direction)
	#print("angle wall direction: ", wall_direction)
	var wall_tangent = up_direction.cross(wall_direction).normalized()
	var alignment = absf(clampf(approach_direction.dot(wall_tangent), -1.0, 1.0))
	var angle_to_wall_tangent = acos(alignment)
	#print("approach: ", (angle_to_wall_tangent), " wall direction: ", wall_direction, " state: ", entity.movement_fsm.current_state)
	if !is_zero_approx(angle_to_wall_tangent):
		pass #print("angle to wall tangent: ", angle_to_wall_tangent)
	
	wall_side = wall_direction
	
	if is_zero_approx(angle_to_wall_tangent):
		## FAILSAFE: if we did this check too late and the horizontal velocity
		## is already basically tangent to the wall, recalculate the approach
		## direction and normal alignment with the intended velocity (which
		## should be the velocity before any move and slide happened)
		print("angle jarona 2")
		approach_direction = entity.movement_fsm.current_state.intended_move_velocity.normalized()
		print("angle intended move velocity: ", approach_direction)
		alignment = absf(clampf(approach_direction.dot(wall_tangent), -1.0, 1.0))
		angle_to_wall_tangent = acos(alignment)
	
	if is_zero_approx(angle_to_wall_tangent) or angle_to_wall_tangent < 0.2:
		print("angle jarona 3: ", entity.movement_fsm.current_state.state_name)
		return false
	print("angle to wall tangent: ", angle_to_wall_tangent, "[", Engine.get_frames_drawn(), "]")
	
	return angle_to_wall_tangent <= entity.wall_run_max_approach_angle_radians
	
func is_wall_left() -> bool:
	var player_up = entity.up_direction
	player_forward = entity.mesh_holder.global_basis.z *-1
	var player_right = player_up.cross(player_forward)
	var dot_result = player_right.dot(wall_side)
	
	print("player forward: ", player_forward," player right: ", player_right, " wall: ", wall_side,  " dot result: ", dot_result)
	
	if dot_result < 0:
		return true
	else:
		return false
	
	
	# if (entity.mesh_holder.global_basis.x.dot(on_wall) >= data.wall_run_max_approach_angle 
		# || entity.mesh_holder.global_basis.x.dot(on_wall) <= -data.wall_run_max_approach_angle): 
		# print("valid approach angle: ")
		# print(entity.mesh_holder.global_basis.x.dot(on_wall)) 
		# return true
	# elif (entity.mesh_holder.global_basis.x.dot(move_to_wall) >= data.wall_run_max_approach_angle 
		# || entity.mesh_holder.global_basis.x.dot(move_to_wall) <= -data.wall_run_max_approach_angle): 
		# print("valid approach angle: ")
		# print(entity.mesh_holder.global_basis.x.dot(move_to_wall)) 
		# return true
	# else: return false
