using System;
using UnityEngine;

// For anyone curious, this is just the base class for PassiveSO, TimedPassiveSO, and PassiveConditionSO.
// This class is kinda just so that the Passives Manager can manage all of these different classes using the same method.

// Every passive has an OnApply(), a Dispose(), a MarkForRemoval(), and a markedForRemoval boolean.
// These let the passive managers apply and discard passives whenever they want!
// Passive Managers will check every passive to see if they've marked themselves for removal.
// Passive Conditions will directly apply another passive to the passive manager, but can also be marked for removal (probably when the gut/heart is taken away)
public abstract class PassiveBase : ScriptableObject {
    public bool markedForRemoval { get; set; }

    public event Action<PassiveBase> OnDispose = delegate { };

    private bool disposed;

    public virtual void OnApply() {
        markedForRemoval = false;
    }

    public virtual void Dispose() {
        if (disposed) {
            return;
        }

        // Debug.Log($"Disposing Myself! -PassiveBase");
        disposed = true;
        OnDispose.Invoke(this);
        OnDispose = null;
        Destroy(this);
    }

    public void MarkForRemoval() {
        // Debug.Log($"Marking myself for removal! -PassiveBase");
        markedForRemoval = true;
    }
}