using UnityEngine;
using System;

public abstract class ProjectileMovementSO : ScriptableObject {

    [SerializeField] protected float speed;

    protected float hitMaxSpeed;

    // For projectile movement that just goes toward a point. Standard!
    protected Vector3 targetPoint;
    // For projectile movement that wants to react to the movement of a target transform.
    protected Transform targetTransform = null;

    protected Vector3 originPoint;

    public Action OnTargetReached = delegate { };
   
    public virtual void Init(Transform projectileTransform, Rigidbody projectileBody, Vector3 target, Transform transform = null) {
        this.targetPoint = target;
        
        if (transform != null) targetTransform = transform;
        
        InitProjectileBody(projectileBody);
        SetOriginPoint(projectileTransform);
    }

    public virtual void InitProjectileBody(Rigidbody projectileBody) {
        projectileBody.linearVelocity = Vector3.zero;
        projectileBody.angularVelocity = Vector3.zero;
    }
    public virtual void ApplyLaunchForce(Transform projectileTransform, Rigidbody projectileBody) { }
    public virtual void ReachMaxSpeed(Transform projectileTransform, Rigidbody projectileBody) { }
    public virtual void UpdateForce(Transform projectileTransform, Rigidbody projectileBody, float deltaTime) { }

    public virtual bool CheckTargetReached(Transform projectileTransform) {
        Vector3 targetPos = targetTransform != null ? targetTransform.position : GetTarget();
        Debug.Log($"Distance to target: {(projectileTransform.position - targetPos).magnitude}");
        if ((projectileTransform.position - targetPos).magnitude < 1f) {
            OnTargetReached.Invoke();
            return true;
        }
        return false;
    }

    public virtual Vector3 GetTarget () {
        if (targetTransform == null) {
            return targetPoint;
        }
        return targetTransform.position;
    }

    public void SetOriginPoint(Transform projectileTransform) {
        originPoint = projectileTransform.position;
    }

    public Vector3 GetOriginPoint() {
        return originPoint;
    }

}