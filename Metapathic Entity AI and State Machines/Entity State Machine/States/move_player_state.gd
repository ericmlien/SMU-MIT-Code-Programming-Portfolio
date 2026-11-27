class_name MovePlayerState
extends MoveEntityState

var target_move_speed: float
var current_forward_acceleration: float
var current_perpendicular_acceleration: float
var hitstop_timer : Timer = Timer.new()
var in_hitstop : bool = false
var horizontal_velocity_on_action_start: Vector3

func init(entity, fsm) -> void:
	super.init(entity, fsm)
	
	entity.action_manager.on_hit.connect(_on_hit)
	hitstop_timer.timeout.connect(_on_hitstop_timeout)
	hitstop_timer.one_shot = true
	add_child(hitstop_timer)
	
	if entity.action_manager:
		entity.action_manager.action_started.connect(_on_action_start)
	
func enter() -> void:
	target_move_speed = data.move_speed
	super.enter()

func state_process(delta: float) -> void:
	if in_hitstop:
		return
	
	move_direction = inputs.get_move_direction()
	move_direction = entity.align_to_global_basis(move_direction)
	move_direction = move_direction.rotated(entity.up_direction, inputs.get_input_move_rotation())
	
	var vertical_velocity = entity.vertical_velocity
	var horizontal_velocity = entity.horizontal_velocity
	var target_horizontal_velocity = move_direction * get_move_speed()
	
	if !move_direction.is_zero_approx():
		var forward_direction = move_direction.normalized()
		var sideways_direction = entity.up_direction.cross(forward_direction).normalized()
		
		var current_forward_speed = horizontal_velocity.dot(forward_direction)
		var current_perpendicular_speed = horizontal_velocity.dot(sideways_direction)
		
		var target_forward_speed = target_horizontal_velocity.dot(forward_direction)
		var target_perpendicular_speed = target_horizontal_velocity.dot(sideways_direction)
		
		current_forward_speed = move_toward(
			current_forward_speed,
			target_forward_speed,
			#current_forward_acceleration * delta
			data.move_acceleration * delta
		)
		current_perpendicular_speed = move_toward(
			current_perpendicular_speed,
			target_perpendicular_speed,
			current_perpendicular_acceleration * delta
		)
		
		#print("Player current forward speed: ", current_forward_speed)
		#print("Player target forward speed: ", target_forward_speed)
		#print("Current forward acceleration: ", current_forward_acceleration)
		horizontal_velocity = (forward_direction * current_forward_speed) + (sideways_direction * current_perpendicular_speed)
		#print("Player move direction is not zero!")
	else:
		horizontal_velocity = horizontal_velocity.move_toward(
			Vector3.ZERO,
			get_move_acceleration() * delta
		)
		#print("Player move accel = ", get_move_acceleration())
		#print("Player move delta = ", delta)
	
	if is_instance_valid(entity.camera_holder.lock_target):
		var to_target = entity.camera_holder.lock_target.global_position - entity.global_position
		to_target.y = 0.0
		if !to_target.is_zero_approx():
			var swing_facing_direction = to_target.normalized()
			entity.mesh_holder.look_at(entity.global_position + swing_facing_direction, entity.up_direction)
	
	entity.velocity = horizontal_velocity + vertical_velocity
	entity.velocity -= entity.up_direction * gravity * get_gravity_mult() * delta
	
	if entity.action_manager:
		if (entity.action_manager.action_state != ActionData.State.READY): 
			var collision = entity.get_last_slide_collision()
			if collision:
				for i in range(collision.get_collision_count()):
					if collision.get_collider(i) is Entity:
						pass
						#collision.get_collider(i).horizontal_velocity = entity.horizontal_velocity
					#print("collision thing: ", collision.get_collider(i))
					#var col_normal = collision.get_normal()
					#var col_tangent = entity.velocity.slide(col_normal).normalized()
					#if col_tangent.length() > 0.0:
						#entity.velocity = col_tangent * entity.velocity.length()
	
	if not entity._snap_up_stairs_check(delta):
		# Don't call move and slide if snap up stairs happened cause we just manually moved the body
		entity.move_and_slide()
		entity._snap_down_to_stairs_check()
	
	var new_horizontal_velocity = entity.horizontal_velocity
	if entity.look_at_override == Vector3.ZERO && !new_horizontal_velocity.is_zero_approx() && !(entity.is_on_wall_only() || entity.is_moving_toward_wall()) && (entity.action_manager.action_state == ActionData.State.READY):
		entity.mesh_holder.look_at(entity.global_position + new_horizontal_velocity, entity.up_direction)

func check_transition_post_process(delta: float) -> void:
	if !entity.is_on_floor():
		state_machine.change_state("Fall")
		return
	
	if entity.horizontal_velocity.is_zero_approx():
		#print("move_player_state: returned player to Idle state via check_transition_post_process")
		state_machine.change_state("Idle")
		return

func subscribe_inputs() -> void:
	super.subscribe_inputs()
	
	inputs.dash_input_detected.connect(on_dash)
	inputs.slide_input_detected.connect(on_slide)
	inputs.slide_input_released.connect(on_slide_released)

func unsubscribe_inputs() -> void:
	super.unsubscribe_inputs()
	
	inputs.dash_input_detected.disconnect(on_dash)
	inputs.slide_input_detected.disconnect(on_slide)
	inputs.slide_input_released.disconnect(on_slide_released)
	
func get_move_speed() -> float:
	return target_move_speed

func on_move(move_dir: Vector3) -> void:
	target_move_speed = data.move_speed
	
	if (entity.camera_holder.is_locked): 
		current_forward_acceleration = 200
		current_perpendicular_acceleration = 200
	else: 
		current_perpendicular_acceleration = data.move_acceleration
		if (entity.horizontal_velocity.length() > data.move_speed):
			current_forward_acceleration = entity.velocity_overflow_decay
		else:
			current_forward_acceleration = data.move_acceleration

func on_move_released(last_move_dir: Vector3) -> void:
	target_move_speed = 0
	current_forward_acceleration = data.move_deceleration
	current_perpendicular_acceleration = data.move_deceleration
	
func on_action(atk_input: String) -> void:
	#state_machine.change_state("Action")
	return
	
func _on_hitstop_timeout():
	in_hitstop = false

func _on_hit(hitbox : HitboxData):
	in_hitstop = true
	hitstop_timer.start(hitbox.get_hitstop_seconds())
	
func _on_action_start():
	horizontal_velocity_on_action_start = entity.horizontal_velocity
