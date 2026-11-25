using UnityEngine;

public class LinearProjectileMovementSO : ProjectileMovementSO {
    [SerializeField] EaseFunctions easeFunc;
    protected float initialDistToTarget = 0.0f;
    protected Vector3 originPoint;

    public override void Init(Transform projectileTransform, Rigidbody projectileBody, Vector3 target, Transform transform = null) {
        base.Init(projectileTransform, projectileBody, target, transform);
        SetInitialDist(projectileTransform, GetTarget());
        SetOriginPoint(projectileTransform);
    }
    public void SetInitialDist(Transform projectileTransform, Vector3 target) {
        initialDistToTarget = (GetTarget() - projectileTransform.position).magnitude;
    }

    public void SetOriginPoint(Transform projectileTransform) {
        originPoint = projectileTransform.position;
    }

    public override void InitProjectileBody(Rigidbody projectileBody) {
        base.InitProjectileBody(projectileBody);
        projectileBody.useGravity = false;
    }
}