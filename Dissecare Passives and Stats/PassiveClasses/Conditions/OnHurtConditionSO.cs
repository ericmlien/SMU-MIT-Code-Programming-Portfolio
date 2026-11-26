using UnityEngine;

// Subscribes to the actor's OnHurt function
[CreateAssetMenu(menuName = "Passives/Passive Conditions/OnHurt")]
public class OnDeathConditionSO : PassiveConditionSO
{
    protected override void Subscribe() {
        actor.OnDeath += _ => ApplyPassive();
    }

    protected override void Unsubscribe() {
        actor.OnDeath -= _ => ApplyPassive();
    }
}
