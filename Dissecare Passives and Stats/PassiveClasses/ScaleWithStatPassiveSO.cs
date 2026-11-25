using UnityEngine;
using System.Collections.Generic;

[CreateAssetMenu(menuName = "Passives/Scale with Stat")]
public class ScaleWithStatPassiveSO : PassiveBase
{
    public StatType statTypeBase;
    public StatType statTypeModifier;

    public float value; // to scale up/down the modifier stat
}