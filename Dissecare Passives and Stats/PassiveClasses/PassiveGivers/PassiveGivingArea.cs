using UnityEngine;

public class PassiveGivingArea : PassiveGiver
{
    public bool takeBackOnLeave = false;

    private Collider col;
    private void Awake() {
        if (!TryGetComponent<Collider>(out Collider col)) {
            // Debug.Log("Hey uhhh I'm supposed to have a collider but I don't have one - PassiveGivingArea");
            return;
        }
        col.isTrigger = true;
    }

    private void OnTriggerEnter(Collider other) {
        if (other.TryGetComponent(out Actor actor)) {
            GivePassive(actor);
        }
    }

    private void OnTriggerExit(Collider other) {
        if (!takeBackOnLeave) return;

        if (other.TryGetComponent(out Actor actor)) {
            TakeBackPassive(actor);
        }

    }





}
