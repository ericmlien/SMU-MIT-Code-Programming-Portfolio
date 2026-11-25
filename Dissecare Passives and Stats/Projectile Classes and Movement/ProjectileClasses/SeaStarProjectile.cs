using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using UnityEngine.Pool;

public class SeaStarProjectile : DamagingProjectile
{
    protected bool isComingBack = false;
    [SerializeField] private Vector3 rotationSpeed = new Vector3(0f, 500f, 0f);
    [SerializeField] private float returnDelay = 0.5f;

    public override void OnSpawn(float despawnTime, Vector3 target, Transform targetTransform = null) {
        canHitOwner = false;
        isComingBack = false;
        base.OnSpawn(despawnTime, target, targetTransform);
    }

    public override void Update() {
        base.Update();
        currentModel.transform.Rotate(rotationSpeed * Time.deltaTime);
    }

    private void StartTurnBack() {
        SwitchMovement(movementSOs[1], actor.gameObject.transform.position);
        // Debug.Log($"Starting turn back! -SeaStarProjectile");
        isComingBack = true;
        canHitOwner = true;
        StartCoroutine(ReturnDelay());
    }

    protected override void OnTargetReached() {
        // Debug.Log($"i didnt get to hit anything");
        if (!isComingBack) StartTurnBack();
    }

    protected override void OnCollisionTerrain(Collider other) {
        if (!isComingBack) StartTurnBack();
    }

    private IEnumerator ReturnDelay() {
        yield return new WaitForSeconds(returnDelay);
        SwitchMovement(movementSOs[2], shootPoint.position, shootPoint);
        yield return null;
    }

    protected override void OnCollisionActor(Actor hitActor) {
        if (isComingBack) {
            hitActor.TakeDamage(GetFinalAbilityDmg(scalings[0]), abilityType, damageType);
        } else {
            hitActor.TakeDamage(GetFinalAbilityDmg(scalings[1]), abilityType, damageType);
        }
    }

    protected override void OnCollisionOwner() {
        if (isComingBack) {
            ReleaseSelf();
        }
    }

}
