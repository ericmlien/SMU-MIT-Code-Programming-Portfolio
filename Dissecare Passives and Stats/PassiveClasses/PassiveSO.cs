using UnityEngine;
using System.Collections.Generic;

// PassiveOp! Essentially what kind of operation the passive uses.
//  add: addative- just add this passive's value to the total.
//  mult: multiplicative- multiply the total by this passive's value.
public enum PassiveOp {
    add,
    mult
}

// PassiveSO! It's essentially a permanent passive. It has a PassiveOp and a StatType (see BaseStats.cs for more), and a value.
[CreateAssetMenu(menuName = "Passives/Permanent Passive")]
public class PassiveSO : PassiveBase {
    public StatType statType;

    public PassiveOp operation;

    public float value;

}
