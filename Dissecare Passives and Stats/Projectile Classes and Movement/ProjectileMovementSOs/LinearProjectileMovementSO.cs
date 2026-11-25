using UnityEngine;

public class LinearProjectileMovementSO : ProjectileMovementSO {
    [SerializeField] EaseFunctions easeFunc;
    protected float initialDistToTarget = 0.0f;
    public float maxDistance = -1.0f;
    protected float distanceTraveled = 0.0f;

    public override void Init(Transform projectileTransform, Rigidbody projectileBody, Vector3 target, Transform transform = null) {
        base.Init(projectileTransform, projectileBody, target, transform);
        SetInitialDist(projectileTransform, GetTarget());
    }
    public void SetInitialDist(Transform projectileTransform, Vector3 target) {
        initialDistToTarget = (GetTarget() - projectileTransform.position).magnitude;
    }

    public override void InitProjectileBody(Rigidbody projectileBody) {
        base.InitProjectileBody(projectileBody);
        projectileBody.useGravity = false;
    }

    public override bool CheckTargetReached(Transform projectileTransform) {
        if (maxDistance > 0f) {
            distanceTraveled = (projectileTransform.position - originPoint).magnitude;
            if (distanceTraveled > maxDistance) {
                OnTargetReached.Invoke();
                return true;
            }
        }
        Vector3 targetPos = targetTransform != null ? targetTransform.position : GetTarget();
        Debug.Log($"Distance to target: {(projectileTransform.position - targetPos).magnitude}");
        if ((projectileTransform.position - targetPos).magnitude < 1f) {
            OnTargetReached.Invoke();
            return true;
        }
        return false;
    }
}