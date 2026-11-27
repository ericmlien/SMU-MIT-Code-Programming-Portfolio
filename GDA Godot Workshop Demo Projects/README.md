GDA Workshop Demo Projects:
    As a programming officer at GDA, I have the privilege of designing workshops for members of the programming department. Most of the workshops are given during our department meetings during fall quarter, after which we transition to devoting meeting times to work on GDA’s yearly game. As GDA is still pretty new to Godot and a lot of new members come to the first programming meeting without any experience using Godot or game engines in general. Thus, of the workshops I’ve been working on are designed to provide an introduction to game programming, using Godot as a game engine, and best practices and design patterns. Based on member feedback about the workshops from last year, I pushed to make hands-on activities a larger part of our workshops, as opposed to just a lecture. These demo projects are a product of this experiment!

Intent:
    After talking about each topic, we’d introduce an activity, where us officers would give a live demo while members follow along. We felt that this further engaged members in the practice of using Godot, letting members learn by gaining familiarity instead of purely using their memory. So far, I’ve been super impressed with how fast our members have been able to learn and I’m hoping future programming officers continue to refine these demo projects after I leave!

What’s Inside:
    Godot Workshop 1 - Intro to Godot and GDScript:
        This workshop was a lot of member’s first introduction to using Godot. We cover Nodes, Scenes, Godot’s physics, classes, and GDScript fundamentals like exportable variables, built-in functions, and syntax. The only scene in this project is a 3D scene called “bodies” and is meant to illustrate the main common physics nodes in Godot: StaticBody, CharacterBody RigidBody, and Area, all with CollisionShapes. The player controls a basic character (CharacterBody3D) and kicks around a bouncy ball (RigidBody3D) into a goal (Area3D) within a world of StaticBody3Ds. Initially, nothing happens when the player kicks the ball into the goal, and changing that is part of the activity! If all goes well, members without any prior Godot experience should come out of this workshop having imported their first project from github, creating their first script, attaching that script to a node, writing their first GDScript function, and experimenting with Godot’s physics hands-on.
        This demo project was given in tandem with this presentation, which you can look at here: 
            https://docs.google.com/presentation/d/1uQor_LXMyIEZifyg0ewFn4w6mwT-5cmNFQVdAyJRCko/edit?usp=drive_link
        You can find the full public repo here: 
            https://github.com/GDACollab/Programming-Workshop-Godot-1-Intro-to-Godot
        bodies_player.gd:
            The included script attached to a 3D characterbody3D node. Starts with basic movement and camera movement. Members do not need to change this script. However, late in the presentation, as we cover @export variables, we live-demo changing the kick_force variable in-editor.
        goal.gd (example):
            As part of the live demo, members will follow along with us as we make a new script and attach it to the goal in the “bodies” scene. We then open that script and add in the functionality to print out something when another body enters its collision shape. This script is just an example of what that might look like. Next, we run the scene again and point out that the print statement shows when both the ball and the player enter the goal, so the next part of the demo involves members changing the ball and goal’s collision filtering so the print statement only is caused by the ball. 
    Godot Workshop 2 - Game Systems:
        The workshop covered class inheritance, Godot signals, globals(singletons), raycasts, timers, and Resources. This workshop is probably the most involved, as members are greeted with an unfinished Vampire Survivors-like game that they need to fix!
        The presentation associated with this demo project can be found here:
            https://docs.google.com/presentation/d/1YmVIKsRblJcT_jI94Z_iuzPevWImjwt45EBjyLa88wU/edit?usp=drive_link 
        You can find the full public repo here: 
            https://github.com/GDACollab/Programming-Workshop-Godot-2-Game-Systems
        "Edit These":
            damage_number_spawner.gd:
                Comes with a function that spawns a damage number. Members need to subscribe to an “On_Hurt” signal they make in “survivors_entity.gd” with which to call “spawn_damage_number()”.
            survivors_entity.gd:
                Provides the basic functionality for a moving character that can take damage and die. Members need to make a new function in this script to assign the entity’s “move_speed”, “max_health, and “damage” from variables in a Resource. They also need to add an “on_hurt” signal to emit in “take_damage()”.
            survivors_player.gd:
                Inherits from “survivors_entity.gd” and provides basic controls for the player. Members need to make a global script, add that to Godot’s global’s page in settings, and, from inside “survivors_player.gd”, have the player add itself to the global to be accessed by enemies. Members also need to add shooting functionality, using the Raycast in “reticle_line.gd” to deal damage to any hit enemies.
            survivors_enemy.gd:
                Inherits from “survivors_entity.gd” and overrides the “get_move_direction()” function, where the member writes the code for the enemy to creep towards the player's position. To access the player’s position, members need to get it from a global script they made earlier in the demo. See “game_manager (example)” in “Examples” to see what that global could look like.
            survivors_enemy_spawner.gd::
                Comes with the functionality to spawn a new enemy at a random spot on the map. Members need to make a resource to hold different kinds of enemy stat values for the spawner to use. The spawner then needs to take a random one of these resources and apply it to the enemy it spawns. See “enemy_stats_resource (example)” in  “Examples” to see what that resource would look like.
        "Helper Scripts (Don’t Edit)":
            damage_number.gd:
                The code for the spawned damage numbers. Makes use of Godot’s tweens, which is talked about briefly in part with the presentation.
            reticle_line.gd:
                Provides a raycast that members can access to make the player shoot enemies.
    Godot Workshop 3 - Vis Dev:
        This workshop gave an introduction to Godot’s particle systems, AnimationPlayer, UI control nodes, canvas layers, and lights. Members damage particles and a death animation to enemies, while also adding a HUD to show the number of enemies killed, in the “Survivors” scene from Workshop 2. They also add lights to the “bodies” scene from Workshop 1.This one ended up going under-time, so, when the time comes to train next year’s programming officers, I’ll talk about possibly adding more content to this workshop, such as elaborating on the more specific kinds of control nodes Godot offers, among other learnings from this amazing experiment! By making our workshops more hands-on, new members can gain firsthand experience in a game engine early in their college career, giving them a foundation to further learn game dev, whether that's through GDA or game jams! I’m super happy with how these demos worked out and I’m looking forward to seeing how they’re improved through the years!
        The presentation for this demo project can be found here:
            https://docs.google.com/presentation/d/19TJODJFRgOeSbCwMcUOimX9knwH0Q7_8qvuboYCM0ok/edit?usp=drive_link
        You can find the full public repo here: 
            https://github.com/GDACollab/Programming-Workshop-Godot-3-Vizdev
        The scripts from the other workshops are combined into this one and all remain the same from their respective projects. The only new scripts provided in the demo are below:
        damage_particles.gd:
            Provides helper functions to spawned damage_particle nodes. These nodes free themselves when they’re finished emitting. The node that this script is on is a CPUParticle2D node that members can change the values to make its emitted particles look natural.
        damage_particles_spawner.gd:
            Spawns damage particles when their owner is hurt.
        game_manager.gd:
            Now comes with a score value and a function to increment score that's called when an enemy dies.
        score_label.gd:
            Updates its text to show the game_manager’s current score. Members need to add a Label with this script on to their HUD to display score. They make this HUD by adding a CanvasLayer to the “survivors” scene and adding control nodes as children of that layer.
