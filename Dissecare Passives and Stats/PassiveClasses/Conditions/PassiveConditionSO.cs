using UnityEngine;


public abstract class PassiveConditionSO : PassiveBase
{
    public PassiveSO effect;

    protected Actor actor;
    protected PassivesManager manager;
    protected PassiveSO activeInstance;

    public void Attach (Actor actor) {
        this.actor = actor;
        manager = actor.pm;
        Subscribe();
    }

    protected abstract void Subscribe();
    protected abstract void Unsubscribe();

    public void ApplyPassive() {
        if (activeInstance == null) {
            // Debug.Log("We don't yet have an active instance. Adding it now! -PassiveConditionSO");
            activeInstance = Instantiate(effect);
            manager.AddPassive(activeInstance);
            return;
        } else if (activeInstance is TimedPassiveSO timed) {
            // Debug.Log("We already have an active instance, so we're just going to refresh! -PassiveConditionSO");
            timed.Refresh();
        }
    }

    public void RemovePassive() {
        activeInstance?.Dispose();
        activeInstance = null;
    }

    public override void Dispose() {
        Unsubscribe();
        RemovePassive();
        base.Dispose();
    }

}
