using UnityEngine;

[System.Serializable]

// Ability Scaling!
// A set of a base value, a StatType, and a multiplier.
// These go into abilities.
// For a basic melee ability, maybe it has a hit that deals 100 base damage + ({user's attack} * scale)

public class AbilityScaling {
    public float baseVal;
    public StatType stat;
    public float scale;

}