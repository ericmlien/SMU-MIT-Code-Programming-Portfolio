# The base class for all entities that need behavior trees! 
# NPCs don't need to be but into an NPCManager, 
	# but there will be some behaviors that behave differently if the NPC is part of an NPCManager.

class_name NPC
extends Entity

var behavior_tree: BehaviorTreeNode = null
var busy: bool = false
var start_point: Vector3

var manager: NPCManager = null
var managed: bool = false

@onready var visible_on_screen_notifier: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
var on_screen = false

#signal accepted_im_a_chud(NPC)

func _ready() -> void:
	super._ready()
	behavior_tree = get_node_or_null("BehaviorTree")
	if behavior_tree != null:
		behavior_tree.init(self)
		print("Behavior tree init")
	start_point = global_position
	print (entity_name, "'s StartPoint: ", start_point)
	visible_on_screen_notifier.screen_exited.connect(on_screen_exited)
	visible_on_screen_notifier.screen_entered.connect(on_screen_entered)
	print(entity_name, "'s Up Direction ", up_direction)
	print(entity_name, "'s Basis ", basis)
	print(entity_name, "'s Global Basis ", global_basis)

func _process(delta: float) -> void:
	if behavior_tree != null:
		behavior_tree._behavior_process(delta)

func set_manager(manager: NPCManager) -> void:
	self.manager = manager
	managed = true
	if manager.visible_on_screen_notifier:
		visible_on_screen_notifier.screen_exited.disconnect(on_screen_exited)
		visible_on_screen_notifier.screen_entered.disconnect(on_screen_entered)
		visible_on_screen_notifier = manager.visible_on_screen_notifier
		visible_on_screen_notifier.screen_exited.connect(on_screen_exited)
		visible_on_screen_notifier.screen_entered.connect(on_screen_entered)

## Checks if this npc is busy. "busy" can be toggled by the npc's behavior_tree. Waiting behaviors will mark busy as false.
func is_busy() -> bool:
	return busy

func mark_as_busy() -> void:
	busy = true

func mark_as_chud() -> void:
	#accepted_im_a_chud.emit(self)
	#print(entity_name, "'s marking itself as a useless chud! on_screen: ", on_screen)
	busy = false
	if !on_screen:
		chud_out()

func on_screen_exited() -> void:
	print(entity_name, "'s sensed its NOT on screen! on_screen: ", on_screen)
	if !is_busy():
		chud_out()
	on_screen = false

func on_screen_entered() -> void:
	print(entity_name, "'s sensed its on screen! on_screen: ", on_screen)
	on_screen = true
	process_mode = Node.PROCESS_MODE_INHERIT

func chud_out() -> void:
	print(entity_name, " is chudding out")
	process_mode = Node.PROCESS_MODE_DISABLED

func _on_death():
	queue_free()
