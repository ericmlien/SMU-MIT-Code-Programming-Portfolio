Metapathic:
    Metapathic is a fast-paced 3D hack-n-slash platformer made in Godot that I helped on in the Spring of 2026, specifically from April 2026 - early June 2026.

Intent:
    This capstone project was started in Winter of 2026. When I joined this project, a lot of the code made during Winter quarter was, understandably, given the fast-paced capstone class requirements, not written with scalability as the main priority. The group decided that it was worth it to rewrite the entity state machine code from scratch to be modular and easily scalable, which was right up my alley! I spent my first weeks in development planning out the architecture and writing the base classes for entities and their state machines, while also writing the code and physics for some basic entity states. One of my groupmates wanted to take the reins on writing the code for the rest of the states, which allowed me to devote the rest of the quarter to designing and implementing the AI behaviors for NPCs, building a behavior tree system from the bottom-up!

What’s Inside:
    Entities:
        entity.gd:
            Base class for any character in the game. Inherited by the player and any NPCs, including enemies. Equipped with components including a state machine, as well as hitbox and hurtbox managers. Subscribes to events on hitbox and hurtbox components like on_hurt and on_death. Also has helper functions for different kinds of movement checks. Before shifting to this architecture, players and npcs were completely separate. This forced us to repeat redundant code if we wanted things to affect both, which was now no longer an issue!
        npc:gd:
            Inherits from entity.gd. Has the added component of an OnScreenNotifier, which allows the enemy to disable its processes when it’s not_busy and off-screen. An npc can be marked as not_busy through calling mark_as_chud() inside BehaviorTree nodes. I completely forgot I named that function like that
        navigating_npc.gd:
            Inherits from npc.gd. Adds the functionality of being clamped to navmesh bounds. This came in handy to prevent enemies from being knocked out of their navmesh and getting stuck. This functionality is toggleable and can be changed inside BehaviorTree nodes.
    Entity State Machine:
        As the player and NPCs were separated, the state machines and states for both were also completely unrelated. Any change we wanted to apply to both had to be done individually. Now, both the player and all NPCs use the same base class for states, which made implementing universal changes, like accommodating anti-gravity, a breeze!.
        entity_state_machine.gd:
            Holds a collection of possible states and manages state changes. Holds a StateMachineData resource as a collection of the StateData for each state the state machine includes. Observes signals emitted from an InputComponent to trigger state changes.
        player_state_machine.gd:
            Inherits from entity_state_machine.gd. Asserts that the included InputComponent is a PlayerInputComponent.
    States:	
        entity_state.gd:
            Provides observers to an entity’s input component for state changes, as well as enter(), exit(), state-process(), and transition-checking functions like check_transition_pre_process() and check_transition_post_process() for child classes to inherit. This is also where an entity’s physics and movement calculations were written as illustrated in “move_entity_state.gd”. Also came with a helper function for a state to play an animation from an entity’s animation tree through play_animation(). Assigns values to state-specific variables using a StateData resource.
        move_entity_state:gd:
            The base class for an entity’s running state. Uses the direction obtained from the entity’s InputComponent and sets its velocity using the move_speed from its MoveStateData resource.
        move_player_state.gd:
            Inherits from move_entity_state.gd. Overrides move_entity_state’s state_process() to add a “steering” feeling to turning and sideways movement, among other functions specific to the player, such as unique hitstop interactions.
        StateMachineData:
            A resource that serves as a container for the StateData in a specific state machine.
        StateData:
            A resource that contains the tunable variables used for physics calculations in specific states. Resources were a natural choice to organize all the state-specific variables, as they’re changeable in-editor for designers. See PlayerMoveStateData.jpg for an example.
    Input Components:
        input_component.gd:
            A component owned by an entity that emits signals for different actions observed by state machines.
        player_input_component.gd: 
            Inherits from input_component.gd: Overrides functions from input_component.gd to emit action signals based on player input.
    Entity AI Behavior Tree: 
        The structure from which designers can build the logic for NPC AI. A behavior tree was especially intuitive inside Godot because the engine’s node tree provides an interface for designers to easily edit an NPCs behavior tree. See SpearEnemyBehaviorTree.jpg for an example! Most nodes that have a dependency for any reason use Godot’s “@tool” functionality to give designers warnings in-editor while they’re constructing their BehaviorTrees to make experimentation and construction easier and more secure. For example, the “behavior_tree_inverter_node.gd” pushes an error if it doesn’t have a child node.
        Base Classes: 
            Base classes for a behavior tree node, branch nodes, and leaf nodes. All nodes return “failure”, “success”, or “”in_progress”.
        Branch Nodes: 
            Branch nodes inherit from behavior_tree_branch_node.gd. Basic nodes that have a list of child nodes. Each branch node iterates through its list of child nodes in a different way. Includes the standard Sequence and Selector branch nodes.
            behavior_tree_sequence_node.gd: 
                Returns “success” only if all of its children return “success”. If any child returns “failure”, stops iterating and returns “failure”. Can be used logically as an “and” clause, string actions together, or make actions only run if a query returns “success” by putting a query before other nodes in a sequence.
            behavior_tree_selector_node.gd: 
                Stops iterating and returns “success” if any of its children return “success”. Returns “failure” only if all of its children return “failure”. Can be used logically as an “or’ clause, and usually serves as a BehaviorTree’s root node.
        Decorators: 
            Extra nodes that have one child node and alter the return state of its child, such as “behavior_tree_inverter_node.gd”, which acts as a “not” modifier, inverting the return value of its child.
        Conditional Decorators:
            Decorator nodes that impose special logic on their children. For example, “behavior_tree_abort_condition_node.gd” takes in two children. The first child is the “abort condition”, and the second are the nodes that are run while the “abort condition” is true.
        Leaf Nodes: 
            Actions or query nodes that do not have children.
            Action Nodes:
                Leaf nodes that can return “success”, “failure”, and “in_progress”. Can range from moving towards a target, inputting an attack, or changing a variable. For example, “stall.gd” forces the NPC to a stop.
            Query Nodes:
                Leaf nodes that can return “success” or “failure” based on the status of something in the world. For example, “is_player_in_range_behaviory_query.gd” has a “range” variable changeable in-editor, and if the player is within that range to the NPC, the node returns “success”, or returns “failure” otherwise.
            Toggle Busy:
                Leaf nodes that just mark their owner as “busy” or “not_busy”. Often used when the NPC behavior is in an idling state, allowing the NPC to turn itself off when it’s off-screen.
            Extra Logic:
                Leaf nodes that allow for different structures of logic to keep tree structure simple. For example, “behavior_tree_lock_node.gd” is a lock that returns “success” or “failure” depending on if it’s locked or not. “Behavior_tree_open_lock_node.gd” and “behavior_tree_close_node.gd” take in a lock_node as an exported variable and can open/close a lock node as an action in the tree. See SpearEnemyBehaviorTree.jpg for an example on how lock nodes were used!

User Instructions and Examples:
    Making a BehaviorTree for an NPC:
        Make a new 3D scene with an NPC as its root node.
        Add an EntityStateMachine and an InputComponent as child nodes.
        Then, add a BehaviorTree node as a child node. This node can be any BehaviorTree node, but it usually is a Selector or Sequence node.
        Drag in each of these components, including the BehaviorTree node, into the appropriate fields in the NPC’s exported fields in-editor. For an example of what an NPC scene’s node tree looks like, see SpearEnemyScene.jpg.
        Then add any BehaviorTree nodes as children of your root BehaviorTree node. The nodes all have in-editor functionality using Godot’s “@tool” libraries, so if something’s wrong, a node should give you a warning and tell you what’s wrong, so you can experiment with your new NPC’s behavior safely. See SpearEnemyBehaviorTree.jpg for an example of a finished BehaviorTree.
    Enemy AI in Gameplay Example:
        Take a look at SpearEnemyGameplay.mp4, ScytheEnemyGameplay.mp4, and SnailEnemyGameplay.mp4 for some examples of how AI behavior looks like in gameplay!
        SpearEnemy:
            An enemy that chases the player if they get too close. While chasing, if the player is within attack range, performs a lunge attack. If the player gets out of chasing range, the NPC runs back to its starting position and marks itself as “not_busy”. After some playtesting, I noticed that the player, by keeping a constant distance from the enemy, could force the enemy to get stuck in a cycle chasing the player and running back to its starting position. To solve this janky interaction, I introduced an “IfChasingPlayerLock” lock node, which allowed me to expand the chasing range while the enemy is chasing the player while shrinking the chasing range while the enemy is running back to its starting position. This made the player have to get closer than before to gain aggro after losing it.
        ScytheEnemy:
            An unfinished enemy that had a sequence of 3 dash attacks.
        SnailEnemy:
            A neutral NPC that sticks to walls and moves back and forth. Head empty.