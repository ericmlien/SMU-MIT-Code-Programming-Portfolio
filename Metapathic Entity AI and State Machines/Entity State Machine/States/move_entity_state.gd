class_name MoveEntityState
extends EntityState

var move_direction

func init(entity, fsm) -> void:
	super.init(entity, fsm)

func set_state_name() -> void:
	state_name = "Move"

func enter() -> void:
	#entity.animator.play("Player|Player_Run", -1, 1.25)
	print("we're running now")
	play_movement_animation("RunLoop")

func state_process(delta: float) -> void:
	move_direction = inputs.get_move_direction()
	move_direction = entity.align_to_global_basis(move_direction)
	move_direction = move_direction.rotated(entity.up_direction, inputs.get_input_move_rotation())
	
	var vertical_velocity = entity.vertical_velocity
	var horizontal_velocity = entity.horizontal_velocity
	
	var target_horizontal_velocity = move_direction * get_move_speed()
	
	horizontal_velocity = horizontal_velocity.move_toward(
		target_horizontal_velocity,
		get_move_acceleration() * delta,
	)
	
	entity.velocity = horizontal_velocity + vertical_velocity
	entity.velocity -= entity.up_direction * gravity * get_gravity_mult() * delta

	if not entity._snap_up_stairs_check(delta):
		# Don't call move and slide if snap up stairs happened cause we just manually moved the body
		entity.move_and_slide()
		entity._snap_down_to_stairs_check()
	
	var new_horizontal_velocity = entity.horizontal_velocity
	if entity.look_at_override == Vector3.ZERO && !new_horizontal_velocity.is_zero_approx() && !(entity.is_on_wall_only() || entity.is_moving_toward_wall()):
		entity.mesh_holder.look_at(entity.global_position + new_horizontal_velocity, entity.up_direction)
		

func check_transition_post_process(delta: float) -> void:
	if !entity.is_on_floor():
		state_machine.change_state("Fall")
		return
	
	var horizontal_velocity = entity.horizontal_velocity
	
	if move_direction.is_zero_approx() && horizontal_velocity.is_zero_approx():
		state_machine.change_state("Idle")
		#print("player returned to idle from check_transition_post_process")
		return
	
	if inputs.sprinting:
		state_machine.change_state("Sprint")
		return

func get_move_speed() -> float:
	return data.move_speed

func get_gravity_mult() -> float:
	return data.move_gravity_multiplier

func get_move_acceleration() -> float:
	return data.move_acceleration

func on_jump() -> void:
	state_machine.change_state("Jump")
	return

func on_dash() -> void:
	state_machine.change_state("Dash")
	return

func on_slide() -> void:
	state_machine.change_state("Slide")
	return

func on_move_released(last_move_dir: Vector3) -> void:
	if !last_move_dir.is_zero_approx():
		state_machine.change_state("Idle")
		return
	
func on_action(atk_input: String) -> void:
	state_machine.change_state("Action")
	return
