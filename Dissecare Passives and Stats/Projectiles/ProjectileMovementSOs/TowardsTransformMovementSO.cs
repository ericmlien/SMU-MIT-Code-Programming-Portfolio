using System;
using UnityEngine;

[CreateAssetMenu(menuName = "Projectile Movement/Towards Transform")]

public class TowardsTransformMovementSO : LinearProjectileMovementSO {
    [SerializeField] protected float turningForce = 3f;
    [SerializeField] protected bool canMiss = true;
    public override void InitProjectileBody(Rigidbody projectileBody) {
        base.InitProjectileBody(projectileBody);
        projectileBody.useGravity = false;
    }

    public override void ApplyLaunchForce(Transform projectileTransform, Rigidbody projectileBody) {

        Vector3 direction = (targetPoint - projectileTransform.position).normalized;
        projectileBody.linearVelocity = direction * speed;

        // Debug.Log($"Linear Velocity: {projectileBody.linearVelocity} -StraightProjectileMovement");
    }

    public override void UpdateForce(Transform projectileTransform, Rigidbody projectileBody, float deltaTime) {

        Vector3 toTarget = (GetTarget() - projectileTransform.position).normalized;

        if (!canMiss) {
            Vector3 newPos = Vector3.MoveTowards(projectileTransform.position, GetTarget(), speed * deltaTime);
            projectileBody.MovePosition(newPos);
            return;
        }

        Vector3 newVelocity = toTarget * speed;
        Vector3 steerForce = newVelocity - projectileBody.linearVelocity;
        steerForce = Vector3.ClampMagnitude(steerForce, turningForce);

        projectileBody.AddForce(steerForce * turningForce, ForceMode.Acceleration);
        projectileBody.linearVelocity = projectileBody.linearVelocity.normalized * speed;

        // Debug.Log($"Linear Velocity: {projectileBody.linearVelocity} -StraightProjectileMovement");
    }
}