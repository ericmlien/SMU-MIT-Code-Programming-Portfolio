using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class OldSeaStarProjectile : MonoBehaviour 
{
    [SerializeField] protected DamageType damageType = DamageType.none;
    public GameObject model;
    [SerializeField] private Collider col;
    private Actor actor;
    private Transform parent;
    private float speed;
    private Vector3 rotationSpeed;
    private float maxDistance;
    private LayerMask layerMask;
    private List<AbilityScaling> abilityScalings;
    private SeastarAbility ability;

    private Coroutine movingCoroutine;
    private bool returning = false;
    private Rigidbody rb;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        col.enabled = false;
    }

    private void Update()
    {
        if (actor.Health <= 0 || parent == null) Destroy(gameObject);
    }

    public void Init(Actor actor, Transform parent, float speed, Vector3 rotationSpeed, float maxDistance, LayerMask targetLayer, List<AbilityScaling> abilityScalings, SeastarAbility ability)
    {
        this.actor = actor;
        this.parent = parent;
        this.speed = speed;
        this.rotationSpeed = rotationSpeed;
        this.maxDistance = maxDistance;
        this.layerMask = targetLayer;
        this.abilityScalings = abilityScalings;
        this.ability = ability;
    }

    public void StartProjectileMovement(Vector3 direction)
    {
        if (actor.CompareTag("Enemy")) direction += Vector3.up * 0.05f;
        col.enabled = true;
        Vector3 endPoint = transform.position + (direction.normalized * maxDistance);
        float duration = maxDistance / speed;
        returning = false;
        rb.detectCollisions = true;
        movingCoroutine = StartCoroutine(MoveSeastar(transform.position, endPoint, duration));
    }

    private void ReturnProjectile()
    {
        float duration = Vector3.Distance(transform.position, parent.position) / speed;
        returning = true;
        StartCoroutine(ReturnSeastar(transform.position, duration));
    }

    private IEnumerator MoveSeastar(Vector3 startPoint, Vector3 endPoint, float duration)
    {
        float timeElapsed = 0f;
        model.transform.localRotation = Quaternion.Euler(Vector3.zero);
        while (timeElapsed < duration)
        {
            Vector3 newPosition = Vector3.Lerp(startPoint, endPoint, timeElapsed / duration);
            rb.MovePosition(newPosition);
            model.transform.Rotate(rotationSpeed * Time.deltaTime);
            timeElapsed += Time.deltaTime;
            yield return null;
        }

        transform.position = endPoint;
        ReturnProjectile();
    }

    private IEnumerator ReturnSeastar(Vector3 startPoint, float duration)
    {
        float timeElapsed = 0f;

        while (timeElapsed < duration)
        {
            Vector3 newPosition = Vector3.Lerp(startPoint, parent.position, timeElapsed / duration);
            rb.MovePosition(newPosition);
            model.transform.Rotate(rotationSpeed * Time.deltaTime);
            timeElapsed += Time.deltaTime;
            yield return null;
        }

        returning = false;
        col.enabled = false;
        model.transform.rotation = Quaternion.Euler(Vector3.zero);
        rb.detectCollisions = false;
        ability.RetrieveProjectile();
    }

    // About (targetLayer.value & (1 << other.gameObject.layer))
    // bitshift is weird man
    // https://discussions.unity.com/t/checking-if-a-layer-is-in-a-layer-mask/860331/8
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(this.actor.transform.tag)) return;
        if ((layerMask.value & (1 << other.gameObject.layer)) != 0 && other.TryGetComponent(out Actor actor))
        {
            if (returning)
            {
                actor.TakeDamage(GetFinalAbilityDmg(abilityScalings[1]), AbilityType.ranged, damageType);
            }
            else
            {
                actor.TakeDamage(GetFinalAbilityDmg(abilityScalings[0]), AbilityType.ranged, damageType);
            }
        }
        else
        {
            if (returning) return;
            if (movingCoroutine != null) StopCoroutine(movingCoroutine);
            Debug.Log($"{transform.name} has hit {other.name} and is now returning.");
            ReturnProjectile();
        }
    }

    protected float GetFinalAbilityDmg(AbilityScaling scaling) {
        return actor.pm.GetFinalDmg(GetScalingValue(scaling), damageType, AbilityType.ranged);
    }

    private float GetScalingValue(AbilityScaling scaling)
    {
        return scaling.baseVal + (actor.statMap[scaling.stat]() * scaling.scale);
    }
}