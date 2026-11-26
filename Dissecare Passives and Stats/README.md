Dissecare:
    Dissecare is a 3D roguelite fps for which I designed and implemented the passives, projectile, and stats systems! The demo involves the player stealing appendages and other body-parts from enemies to steal their abilities and passives. At the end of a run, the player’s body might look completely different from when they started their run and how they finished the run before.
    This project was made as part of UCSC’s senior capstone in winter 2026.


Intent:
    Our major design goal was encouraging the player to experiment with their individual playstyle and build-making (more like body-building!). As a roguelite, we knew that a lot of the build-making and individual expression we were aiming for demanded a lot of content and higher scope. With this in mind, I designed the demo’s passives, projectile, and stats systems with the goal of accommodating varying kinds of passives, abilities, and freedom.


What’s inside:
    Actor:
        Base class for entities that have health and stats while also being able to take damage, die, and be affected by passives.
        Has a PassivesManager variable called “pm”.
    Stats:
        BaseStats.cs:
            StatType (enum):
                An enum for different kinds of stats! Multipliers (dmgMult), and flat stats (health).
        BaseStatsSO (scriptable object):
            A scriptable object for an Actor’s base stat values, able to be changed in the editor.
        StatUtils:
            Provides static helper functions for math, such as scaling a stat from a flat amount to a percentage, like “defense”.
        Stat.cs:
            Base class for any value associated with a StatType
        ScaledStat.cs:
            Class for any multiplier stat values. Just sets the default values to 0, as they’re calculated in addition to 100%.
        AbilityScaling.cs:
            A class that has a base value, a StatType “stat”, and a scale.
            The scale is how much the final value of the scaling changes based on the value of the stat that matches StatType “stat”.
    PassiveManager.cs:
        A component owned by Actors.
        GetFinalStat():
            Returns the final value of a stat, altered by any current passives.
            Uses the StatType enum to assert which passive changes what stat, checked in IsApplicable().
        Update():
            Called in the Actor’s Update().
            Updates all the registered passives in the PassiveManager, ticking any timers, and destroying any passives marked for removal.
        AddPassive():
            Adds a passive to the appropriate list and calls the passive’s OnApply().
    Passives (Scriptable Objects):
        PassiveBase.cs:
            Provides the base class that allows passives to be registered under PassiveManager’s collections of current passives
            OnApply():
                Runs when the passive is added to the PassiveManager
            MarkForRemoval():
                Marks itself for the PassiveManager to remove the next time it calls UpdatePassives().
            OnDispose():
                Runs before the passive gets destroyed by the PassivesManager.
        PassiveSO.cs:
            Provides an interface for setting the stat-modifier and affected StatType in-editor.
            Inherited by other Passive SOs (scriptable objects).
        TimedPassiveSO.cs:
            A passive with a timer. The PassivesManager knows to update this passive’s timer in Update().
            Marks itself for removal on timer timeout by default.
        ScaleWithStatPassiveSO.cs:
            A passive that needs to fetch stats from its Owner
        PassiveConditionSO.cs:
            Has a PassiveSO variable called “effect”, changeable in the editor.
            Has abstract Subscribe() and Unsubscribe() functions for conditions to observe events emitted by their owner.
            ApplyPassive() calls the Owner’s PassiveManager’s ApplyPassive() to apply the “effect” passive.
        Projectiles:
            Projectile.cs:
                Base class for projectiles
                Comes with virtual event functions that children can override, such as OnColllsionActor()
                Has a list of ProjectileMovementSOs and a list of scalings that it can pull from.
            ProjectileMovementSOs:
                Uses ApplyLaunchForce() and UpdateLaunchForce() to set a projectile’s movement when shot and during its flight respectively.
                Accommodates for different kinds of projectile flight paths, linear, lobbed, homing, and stopped.


User Instructions and Examples:
    Making a new Passive:
        Just like any Scriptable Object in Unity, designers can make a new Passive by selecting it in the create menu.
        You can set its field values in the editor, like setting its timer duration if it's a TimedPassive.
        See NewPassiveExample.jpg and NewPassiveExampleGameplay.mp4, where I equip a “gut” that grants me a flat attack buff passive, in the examples directory.
    Making a new PassiveCondition:
        To subscribe to a new event, create a new script called ["EventName"]ConditionSO.cs and override the Subscribe() and Unsubscribe() functions. Be sure to change the scriptable object name above the class header.
        Then, make a new scriptable object by selecting your new passive condition in the create menu.
        Add a different Passive scriptable object into the “effect” field, and now you have a passive that applies another passive on a condition!
        See NewPassiveConditionExample.jpeg and NewPassiveConditionExampleGameplay.mp4, where I attack an enemy with an OnHurtPassiveCondition, in the examples directory.
    Making a new projectile:
        Make a new script that inherits Projectile.cs and overrides the event functions you want.
        For example: DamagingProjectile.cs overrides OnCollisionActor() and does damage to the hit actor!
        Another example: Our boomerang sea-star projectile overrides OnTargetReached() and OnCollisionTerrain() to change its projectile movement after flying outward a set distance or hitting terrain.
        Attach the script to a RigidBody as a component.
        Add ProjectileMovement scriptable objects and ability scalings into movement and scalings fields respectively
        See SeastarProjectileExample.jpg and SeastarProjectile.cs to see how the movementSOs and projectileBase are combined to make a new projectile!
        The finished SeastarProjectile can be seen in SeastarProjectileExample.jpg and SeastarProjectileExampleGameplay.mp4.
