extends CharacterBody3D
class_name Entity

@export var entity_name: String
@export var movement_fsm: EntityStateMachine
@export var health_component: HealthComponent
@export var damage_number_spawner : DamageNumberSpwaner
@export var input_component: InputComponent
@export_range(0.0, 1.5707) var wall_run_max_approach_angle_radians : float
@export var mesh_holder: Node3D
@export var floor_check_raycast: RayCast3D
@export var step_up_check_raycast: RayCast3D
@export var audio_handler: AudioHandler
@export var is_testing : bool

var anim_player: AnimationPlayer = null
var anim_tree: AnimationTree = null
var move_tree
var tree_conditionals

var action_manager: ActionManager = null
var hitbox_manager : HitboxManager
var hurtbox_manager : HurtboxManager
var last_recieved_hitbox : HitboxData
var last_recieved_hitbox_attacker : Entity

var look_at_override: Vector3 = Vector3.ZERO
var hitstunnable: bool = true
var knockback_speed : float
var damage_multiplier : float = 1.0

const MAX_STEP_HEIGHT = 0.65
const MAX_SLOPE_HEIGHT = 0.9
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

func override_move_look_direction(direction: Vector3) -> void:
	look_at_override = direction.normalized()
	mesh_holder.look_at(global_position + look_at_override, up_direction)

func unlock_move_look_direction() -> void:
	look_at_override = Vector3.ZERO

var vertical_velocity: Vector3:
	get:
		return align_to_entity_up_direction_vertical(velocity)

var horizontal_velocity: Vector3:
	get:
		return align_to_entity_up_direction_horizontal(velocity)

func align_to_entity_up_direction_vertical(vector: Vector3) -> Vector3:
	return vector.dot(up_direction) * up_direction

func align_to_entity_up_direction_horizontal(vector: Vector3) -> Vector3:
	return vector - align_to_entity_up_direction_vertical(vector)

func align_to_entity_basis(vector: Vector3) -> Vector3:
	return global_transform.basis.inverse() * vector

func align_to_global_basis(vector: Vector3) -> Vector3:
	return global_transform.basis * vector

func align_to_mesh_basis(vector: Vector3) -> Vector3:
	return mesh_holder.global_transform.basis.inverse() * vector

func align_to_global_basis_from_mesh(vector: Vector3) -> Vector3:
	return mesh_holder.global_transform.basis * vector

func _ready() -> void:
	anim_player = get_node_or_null("MeshHolder/Mesh/AnimationPlayer")
	anim_tree = get_node_or_null("MeshHolder/AnimationTree")
	if anim_tree != null:
		anim_tree.active = true
	
	input_component.entity = self
	
	print("ANIM_PLAYER GET" if anim_player != null else "NO ANIM_PLAYER!")
	print("ANIM_TREE GET" if anim_tree != null else "NO ANIM_TREE!")
	
	if anim_tree != null:
		move_tree = anim_tree.get("parameters/movement/playback")
	else:
		move_tree = null
	
	action_manager = get_node_or_null("EntityActionManager")
	movement_fsm.init(self)
	
	health_component.on_death.connect(_on_death)
	
	for child in mesh_holder.get_children():
		if child is HurtboxManager:
			hurtbox_manager = child
		if child is HitboxManager:
			hitbox_manager = child
			hitbox_manager.init(self)
	
	hurtbox_manager.got_hurt.connect(_on_hurt)

func _physics_process(delta: float) -> void:
	if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
	
	movement_fsm.current_state_process(delta)


func is_moving_toward_wall() -> bool:
	var move_direction := input_component.get_move_direction()
	if move_direction.is_zero_approx():
		move_direction = input_component.get_last_move_direction()

	if move_direction.is_zero_approx():
		return false

	var intended_direction := move_direction.rotated(up_direction, input_component.get_input_move_rotation()).normalized()

	if intended_direction.is_zero_approx():
		return false

	var test_transform := global_transform.translated(Vector3.UP * 0.05)
	var result := PhysicsTestMotionResult3D.new()

	var hit := _run_body_test_motion(test_transform, intended_direction * 0.55, result)

	if not hit:
		return false

	for i in range(result.get_collision_count()):
		var normal := result.get_collision_normal(i)
		if normal.angle_to(up_direction) > floor_max_angle:
			return true

	return false

func _on_hurt(hostile_hitbox_data : HitboxData, attacker : Entity):
	#print("OUCHIE")
	last_recieved_hitbox = hostile_hitbox_data
	last_recieved_hitbox_attacker = attacker
	health_component.take_damage(hostile_hitbox_data.damage_ammount)
	damage_number_spawner.spawn_label(hostile_hitbox_data.damage_ammount)
	if hitstunnable:
		movement_fsm.change_state("Hitstun")

func _on_death():
	pass
	
func _on_dash():
	pass

func can_act() -> bool:
	return (
			action_manager != null
			&& movement_fsm.current_state.get_state_name() != "Hitstun"
			&& !action_manager.is_action_active()
			)

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	var floor_below := false
	if self.floor_check_raycast != null:
		floor_below = self.floor_check_raycast.is_colliding() and not is_surface_too_steep(self.floor_check_raycast.get_collision_normal())
		self.floor_check_raycast.force_raycast_update()
	var was_on_floor_last_frame = Engine.get_physics_frames() == _last_frame_was_on_floor
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0,-MAX_SLOPE_HEIGHT,0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _snap_up_stairs_check(delta) -> bool:
	if movement_fsm.current_state.state_name != "Hitstun":
		if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	# Run a body_test_motion slightly above the pos we expect to move to, towards the floor.
	#  We give some clearance above to ensure there's ample room for the player.
	#  If it hits a step <= MAX_STEP_HEIGHT, we can teleport the player on top of the step
	#  along with their intended motion forward.
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (_run_body_test_motion(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		# Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		# 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		# The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT: return false
		if self.step_up_check_raycast != null:
			self.step_up_check_raycast.global_position = down_check_result.get_collision_point() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
			self.step_up_check_raycast.force_raycast_update()
			if self.step_up_check_raycast.is_colliding() and not is_surface_too_steep(self.step_up_check_raycast.get_collision_normal()):
				self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
				apply_floor_snap()
				_snapped_to_stairs_last_frame = true
				return true
	return false
	

func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle
	
## This function allows a body to simulate if a collision would happen given
## a starting position and a "motion" vector. This does not actually move the body.
## Pair ts with get_travel() to force-move this entity against an object
## [br][br][param from] This should be the entity's GLOBAL TRANSFORM
## [br][param motion] The vector you want to simulate movement along
## [br][param result] make a new variable that holds PhysicsTestMotionResult3D.new() and pass it here
func _run_body_test_motion(from : Transform3D, motion : Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)
	
func _run_body_test_motion_in_input_direction(result = null) -> bool:
	var move_direction := input_component.get_move_direction()
	var intended_direction := move_direction.rotated(up_direction, input_component.get_input_move_rotation()).normalized()
	
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = self.global_transform
	params.motion = intended_direction * 1.5
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)
