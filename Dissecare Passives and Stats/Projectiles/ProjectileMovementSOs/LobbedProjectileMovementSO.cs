using Unity.Cinemachine;
using UnityEngine;

[CreateAssetMenu(menuName = "Projectile Movement/Lobbed")]
public class LobbedProjectileMovementSO : ProjectileMovementSO {
    // Yeah i couldnt find a way to make this work with ease functions;
    protected float gravity => Mathf.Abs(Physics.gravity.y);
    public override void InitProjectileBody(Rigidbody projectileBody) {
        base.InitProjectileBody(projectileBody);
        projectileBody.useGravity = true;
    }

    public override void ApplyLaunchForce(Transform projectileTransform, Rigidbody projectileBody) {
        Vector3 toTarget = GetTarget() - projectileTransform.position;
        float angle = GetLaunchAngle(projectileTransform, projectileBody);
        Vector3 horizontalDir = toTarget;
        horizontalDir.y = 0f;
        horizontalDir.Normalize();
        toTarget.Normalize();

        Vector3 direction = toTarget.y <= Mathf.Sin(angle) ? new Vector3(horizontalDir.x * Mathf.Cos(angle), Mathf.Sin(angle), horizontalDir.z * Mathf.Cos(angle)) : toTarget;
        projectileBody.linearVelocity = direction.normalized * speed;
    }
    
    protected float GetLaunchAngle(Transform projectileTransform, Rigidbody projectileBody) {
        float x = Mathf.Sqrt(Mathf.Pow(GetTarget().x - projectileTransform.position.x, 2) + Mathf.Pow(GetTarget().z - projectileTransform.position.z, 2));
        // // Debug.Log($"x: {x} -GetLaunchAngle");
        float y = GetTarget().y - projectileTransform.position.y;
        // // Debug.Log($"y: {y} -GetLaunchAngle");
        float innerSq = Mathf.Pow(speed, 4) - gravity * ((gravity * Mathf.Pow(x, 2)) + (y * 2 * Mathf.Pow(speed, 2)));
        if (innerSq < 0) {
            // // Debug.Log($"Our innerSq was < 0: {innerSq}");
            return Mathf.PI / 4f;
        }
        // // Debug.Log($"Our innerSq was > 0: {innerSq}");
        float innerATan = (Mathf.Pow(speed, 2) - Mathf.Sqrt(innerSq)) / (gravity * x);
        float angle = Mathf.Atan(innerATan);
        // // Debug.Log($"Angle: {angle} -GetLaunchAngle");
        return angle;
    }
}