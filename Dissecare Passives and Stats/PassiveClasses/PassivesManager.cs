using System.Collections.Generic;
using System;
using Unity.VisualScripting;
using UnityEngine;

// Passives Manager!
// Each "Actor", and by extension the player and enemies, will have their own instance of one
// Has two Passive Lists: one for addative passives and one for multiplicative passives.

// The passives have a value and a PassiveType, which is either add or mult.
// When AddPassive is called (pls call it by first passing in an INSTANCE of a passiveSO by using instantiate):
//  Adds the passive to the passive list corresponding to its operation type.

// The PassiveManager essentially stores a collection of value modifiers.
// When CalculateFinalValue is called with a StatType and base value:
//  PassiveManager iterates through its active passives.
//  If a passive matches the given statType, then it applies that passive's number modifier.

public class PassivesManager {
    public Actor actor;

    public List<PassiveBase> adds = new List<PassiveBase>();

    public List<PassiveBase> mults = new List<PassiveBase>();

    public List<PassiveBase> conditionals = new List<PassiveBase>();

    public List<PassiveBase> varMults = new List<PassiveBase>();

    public PassivesManager(Actor actor) {
        this.actor = actor;
    }

    // This is just a shorthand method to get all of the correct general damage multipliers.
    // Should just be called by Abilities.
    // When a new final damage modifier type is added, add it to the list inside this method!

    public float GetFinalDmg(float baseDamage, DamageType? damageType = null, AbilityType? abilityType = null) {

        List<float> appliedMults = new List<float>();

        switch (abilityType) {
            case AbilityType.melee:
                appliedMults.Add(actor.meleeDmgMult);
                break;
            case AbilityType.ranged:
                appliedMults.Add(actor.rangedDmgMult);
                break;
        }

        switch (damageType) {
            case DamageType.blunt:
                appliedMults.Add(actor.bluntDmgMult);
                break;
            case DamageType.sharp:
                appliedMults.Add(actor.sharpDmgMult);
                break;
        }


        appliedMults.Add(actor.dmgMult);
        //// Debug.Log($"damage mult is {actor.dmgMult}");

        //// Debug.Log($"Base Damage before multiplication: {baseDamage} -BaseAbility");
        float multSum = 1f;
        foreach (float mult in appliedMults) {
            multSum += mult;
        }

        //// Debug.Log($"final damage is: {baseDamage * multSum}");
        return baseDamage * multSum;
    }

    public float GetFinalStat(StatType statType, float baseVal) {
        float runningVal = baseVal;

        foreach (PassiveSO passive in adds) {
            if (IsApplicable(passive, statType)) {
                runningVal += passive.value;
            }
        }

        float multSum = 1f;
        foreach (PassiveSO passive in mults) {
            if (IsApplicable(passive, statType)) {
                multSum += passive.value;
            }
        }

        foreach (ScaleWithStatPassiveSO passive in varMults)
        {
            if (passive.statTypeBase == statType)
            {
                float modifierStatValue = actor.statMap[passive.statTypeModifier].Invoke();
                multSum += modifierStatValue * passive.value;
            }
        }

        return runningVal * multSum;
    }

    // Helper to check if our current passive applies given the current criteria
    private bool IsApplicable(PassiveSO passive, StatType statType) {
        
        // We first check to see if the passive's statType matches the stat-to-change
        // If yes, then we also need to check if we were given any additional criteria.
        if (passive.statType != statType) {
            return false;
        }

        return true;
    }

    public void AddPassive(PassiveBase item) {

        if (item is PassiveSO passive) {
            // Debug.Log($"Adding Passive! passive stat type: {passive.statType}, passive stat value: {passive.value}");            
            if (passive.operation == PassiveOp.add) {
                adds.Add(passive);
                passive.OnDispose += _ => adds.Remove(passive);
            }
            else if (passive.operation == PassiveOp.mult) {
                mults.Add(passive);
                passive.OnDispose += _ => mults.Remove(passive);
            }
        }

        if (item is PassiveConditionSO condition) {
            // Debug.Log($"Adding Passive Condition! Effect stat type: {condition.effect.statType}, effect stat value: {condition.effect.value}");
            condition.Attach(actor);
            conditionals.Add(condition);
            condition.OnDispose += _ => conditionals.Remove(condition);
        }

        if (item is ScaleWithStatPassiveSO scaled)
        {
            // Debug.Log($"Adding Scaled Passive! Effect stat type: {scaled.statTypeBase}, effect stat value: {scaled.value} x speed");
            varMults.Add(scaled);
            scaled.OnDispose += _ => varMults.Remove(scaled);
        }

        item.OnApply();
    }

    public void Update(float deltaTime) {
        UpdatePassives(adds, deltaTime);
        UpdatePassives(mults, deltaTime);
        UpdatePassives(conditionals, deltaTime);
        UpdatePassives(varMults, deltaTime);
    }

    private void UpdatePassives(List<PassiveBase> passiveList, float deltaTime) {
        for (int i = passiveList.Count - 1; i >= 0; i--) {
            var passive = passiveList[i];

            if (passive is TimedPassiveSO timed) {
                timed.TickTimer(deltaTime);
            }

            if (passive.markedForRemoval) {
                passive.Dispose();
            }
        }
    }
    public void ClearAll() {
        for (int i = adds.Count - 1; i >= 0; i--) {
            adds[i].Dispose();
        }
        for (int i = mults.Count - 1; i >= 0; i--) {
            mults[i].Dispose();
        }
        for (int i = conditionals.Count - 1; i >= 0; i--) {
            conditionals[i].Dispose();
        }
        for (int i = varMults.Count - 1; i >= 0; i--)
        {
            varMults[i].Dispose();
        }

        adds.Clear();
        mults.Clear();
        conditionals.Clear();
        varMults.Clear();
    }

}