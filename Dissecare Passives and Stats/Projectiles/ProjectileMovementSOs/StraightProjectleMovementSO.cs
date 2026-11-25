using UnityEngine;

[CreateAssetMenu(menuName = "Projectile Movement/Straight")]
public class StraightProjectileMovementSO : LinearProjectileMovementSO {
    public override void ApplyLaunchForce(Transform projectileTransform, Rigidbody projectileBody) {
        Vector3 direction = (targetPoint - projectileTransform.position).normalized;
        projectileBody.linearVelocity = direction * speed;
        // Debug.Log($"Linear Velocity: {projectileBody.linearVelocity} -StraightProjectileMovement");
        // Debug.Log($"Linear Velocity: {projectileBody.angularVelocity} -StraightProjectileMovement");
    }
}