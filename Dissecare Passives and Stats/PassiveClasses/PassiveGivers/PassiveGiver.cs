using System.Collections.Generic;
using System.Linq;
using UnityEngine;

// This will be the base class for all Passive Givers! Add this as a component to any prefab u want.

public class PassiveGiver : MonoBehaviour
{
    public PassiveBase passiveToGive;

    public Dictionary<Actor, PassiveBase> activeInstances = new();

    public void GivePassive (Actor receiver) {
        if (activeInstances.TryGetValue(receiver, out PassiveBase existing)) {
            if (existing is TimedPassiveSO timed) {
                // Debug.Log("We found an existing timed passive. Refreshing it! -PassiveGiver");
                timed.Refresh();
            }
            return;
        }

        PassiveBase newInstance = Instantiate(passiveToGive);
        activeInstances[receiver] = newInstance;

        newInstance.OnDispose += _ => activeInstances.Remove(receiver);

        receiver.pm.AddPassive(newInstance);
    }

    public void TakeBackPassive (Actor receiver) {
        if (activeInstances.TryGetValue(receiver, out PassiveBase toTake)) {
            toTake.Dispose();
            activeInstances.Remove(receiver);
        }
    }

    public void TakeBackAll () {
        foreach (var passive in activeInstances.Values.ToList()) {
            passive.Dispose();
        }

        activeInstances.Clear();
    }

    private void OnDestroy() {
        TakeBackAll();
    }

}
