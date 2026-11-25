using UnityEngine;

public class DamagingProjectile : Projectile {

    [SerializeField] protected DamageType damageType = DamageType.none;
    protected override void OnTargetReached() {
        // Debug.Log($"i didnt get to hit anything");
        ReleaseSelf();
    }
    protected override void OnCollisionActor(Actor hitActor) {
        // Debug.Log($"I, PROJECTILE, HAVE HIT THIS UNRULY MALEFACTOR NAMED: {hitActor.gameObject.name}");
        hitActor.TakeDamage(GetFinalAbilityDmg(scalings[0]), abilityType, damageType);
    }
    protected override void OnCollisionTerrain(Collider other) {
        // Debug.Log($"I, PROJECTILE, HAVE HIT THIS UNFORTUNATE TERRAIN NAMED: {other.gameObject.name}");
    }
    protected override void OnCollision(Collider other) {
        // Debug.Log($"yeah its me, projectile, again. i spent all my energy shouting. anyway, I hit smth or whatevs {other.gameObject.name}");
        ReleaseSelf();
    }

    protected float GetFinalAbilityDmg(AbilityScaling scaling) {
        return actor.pm.GetFinalDmg(GetScalingValue(scaling), damageType, abilityType);
    }
}