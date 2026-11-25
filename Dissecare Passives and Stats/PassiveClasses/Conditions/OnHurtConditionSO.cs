using UnityEngine;

// Subscribes to the actor's OnHurt function
[CreateAssetMenu(menuName = "Passives/Passive Conditions/OnHurt")]
public class OnHurtConditionSO : PassiveConditionSO
{
    protected override void Subscribe() {
        actor.OnHurt += _ => ApplyPassive();
    }

    protected override void Unsubscribe() {
        actor.OnHurt -= _ => ApplyPassive();
    }
}
