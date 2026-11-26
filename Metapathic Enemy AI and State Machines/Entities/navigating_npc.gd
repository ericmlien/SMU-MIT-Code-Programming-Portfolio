class_name NavigatingNPC
extends NPC

@export var clamp_to_navmesh_bounds: bool = false

@onready var navi_agent: NavigationAgent3D = $NavigationAgent3D
var navi_map: RID

func _ready() -> void:
	super._ready()
	navi_map = navi_agent.get_navigation_map()

func _physics_process(delta: float) -> void:
	var old_position = global_position
	super._physics_process(delta)
	if clamp_to_navmesh_bounds:
		var old_clamp = NavigationServer3D.map_get_closest_point(navi_map, old_position)
		var new_clamp = NavigationServer3D.map_get_closest_point(navi_map, global_position)
		
		if old_position.distance_to(old_clamp) < 0.1 && !global_position.distance_to(new_clamp) < 0.1:
			velocity = Vector3.ZERO
			global_position = Vector3(new_clamp.x, global_position.y, new_clamp.z)
		#var clamped_position = NavigationServer3D.map_get_closest_point(entity.navi_map, entity.global_position)
		#if clamped_position.distance_to(old_position) < clamped_position.distance_to(entity.global_position):
			#entity.global_position = Vector3(clamped_position.x, entity.global_position.y, clamped_position.z)
		pass
	
	
