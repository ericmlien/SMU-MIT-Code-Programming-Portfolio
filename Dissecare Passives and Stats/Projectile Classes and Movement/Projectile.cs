using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Pool;

public abstract class Projectile : MonoBehaviour {
    [SerializeField] protected List<GameObject> models = new();
    protected GameObject currentModel;
    protected Collider col;
    protected Rigidbody body;
    public bool canHitOwner = false;
    public bool canHitSame = false;
    protected Transform shootPoint;

    protected AbilityType abilityType = AbilityType.ranged;
    public List<ProjectileMovementSO> movementSOs = new List<ProjectileMovementSO>();
    protected ProjectileMovementSO currentMovement = null;
    private IObjectPool<GameObject> pool;
    private CountdownTimer despawnTimer;
    public bool canDespawn = true;
    protected List<AbilityScaling> scalings = new List<AbilityScaling>();
    protected Actor actor;
    private bool released;

    public virtual void Awake() {

        if (canDespawn) {
            despawnTimer = new CountdownTimer(0f);
            despawnTimer.OnTimerStop += ReleaseSelf;
        }

        foreach (GameObject model in models) {
            model.SetActive(false);
            if (!model.TryGetComponent<Collider>(out Collider childCol)) {
                // Debug.Log($"Hey, we don't have a collider on our model: {model.name} -Projectile");
            } else {
                childCol.enabled = false;
            }
        }

        if (models.Count < 1) {
            // Debug.Log($"Hey, we don't have any models for this projectile! (they need to be children of the projectile) -Projectile");
        }
        
        if (!TryGetComponent<Rigidbody>(out body)) {
            // Debug.Log($"Hey, we don't have a rigidbody on our projectile parent! -Projectile");
        }

        released = true;
    }

    public virtual void Init(IObjectPool<GameObject> pool, Actor actor, Transform shootPoint, AbilityType abilityType, List<AbilityScaling> scalings) {
        this.pool = pool;
        this.actor = actor;
        this.abilityType = abilityType;
        this.scalings = scalings;
        this.shootPoint = shootPoint;
    }

    public virtual void OnSpawn(float despawnTime, Vector3 target, Transform targetTransform = null) {
        despawnTimer.Reset(despawnTime);
         Debug.Log($"Our target: {target} -Projectile");
        SwitchMovement(movementSOs[0], target, targetTransform);
        released = false;
        //// Debug.Log($"My actor inside Init: {actor}");
        SwitchModel(0);
        currentMovement.ApplyLaunchForce(transform, body);
    }

    public virtual void Update() {
        despawnTimer.Tick(Time.deltaTime);
        currentMovement.UpdateForce(transform, body, Time.fixedDeltaTime);
        currentMovement.CheckTargetReached(transform);
    }

    protected virtual void OnTargetReached() { }
    protected virtual void OnCollisionOwner() { }
    protected virtual void OnCollisionSame() { }
    protected virtual void OnCollisionActor(Actor hitActor) { }
    protected virtual void OnCollisionTerrain(Collider other) { }
    protected virtual void OnCollision(Collider other) { }

    protected void SwitchMovement(ProjectileMovementSO template, Vector3 target, Transform targetTransform = null) {
        if (currentMovement != null) currentMovement.OnTargetReached -= OnTargetReached;
        currentMovement = Instantiate(template);
        currentMovement.Init(transform, body, target, targetTransform);
        currentMovement.OnTargetReached += OnTargetReached;
    }

    protected void SwitchModel(int index) {
        if (currentModel != null) {
            DisableCurrentModel();
        }

        currentModel = models[index];
        if (!currentModel.TryGetComponent(out col)) {
            // Debug.Log($"Hey, we don't have a collider on our model: {currentModel.name} -Projectile");
        }

        EnableCurrentModel();
    }


    private void OnTriggerEnter(Collider other) {
        if (other.gameObject.TryGetComponent<Actor>(out Actor hitActor)) {
            if (hitActor == actor) {
                if (!canHitOwner) {
                    // Debug.Log("We hit our owner and that's not allowed! -Projectile.cs");
                    return;
                }
                OnCollisionOwner();
            } else {
                OnCollisionActor(hitActor);
            }
        }

        if (other.gameObject.TryGetComponent<Projectile>(out Projectile hitProjectile)) {
            if (hitProjectile.actor == actor) {
                if (!canHitSame) {
                    // Debug.Log("We hit another of our owner's projectiles and that's not allowed! -Projectile.cs");
                    return;
                }
                OnCollisionSame();
            }
        }

        if (other.gameObject.layer == LayerMask.NameToLayer("Ground")) {
            OnCollisionTerrain(other);
        }

        OnCollision(other);
    }

    protected float GetScalingValue(AbilityScaling scaling) {
        return scaling.baseVal + (actor.statMap[scaling.stat]() * scaling.scale);
    }

    protected void ReleaseSelf () {
        if (released) {
            return;
        }

        if (currentModel != null) {
            DisableCurrentModel();
        }

        pool.Release(gameObject);
        
        released = false;
    }

    protected void EnableCurrentModel() {
        currentModel.SetActive(true);
        col.enabled = true;
    }
    protected void DisableCurrentModel() {
        currentModel.SetActive(false);
        col.enabled = false;
    }


}