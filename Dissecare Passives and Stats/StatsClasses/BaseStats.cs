using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using static UnityEngine.Rendering.DebugUI;

// IMPORTANT!!!! PLEASE READ THIS TINY BLURB ABOUT ADDING NEW STATS!

// When adding stats, be sure to update:
//  - the StatType enum below,
//  - the Stat Map in Actor.cs,
//  - and the Stat Getter methods in Actor.cs

// When adding modifier stats (see IsModStat() in StatUtils below) be sure to update:
//  - GetFinalDamage() in BaseAbility.cs


// Stat Types!
// This enum is used to find all of the actor's current passives that apply to a specific stat.
public enum StatType {
    // Base Stats:
    attack,
    maxHP,
    speed,
    defense,
    size,
    // Modifier Stats:
    // When adding new types dmg modifiers, update the GetFinalDamage method in PassivesManager!
    dmgMult,
    meleeDmgMult,
    rangedDmgMult,
    sharpDmgMult,
    bluntDmgMult,
}
// And also update the stat getter methods in Actor.cs!
[CreateAssetMenu(menuName = "Stats/Base Stats")]
public class BaseStatsSO : ScriptableObject {

    // These are just base stats!
    // If ur confused about how a ScalingStat is different than a "raw" stat, then take a look at ScalingStat.cs or StatMath.cs!
    [Header ("Base Stats")]
    public Stat attack = new Stat(StatType.attack);
    public Stat maxHP = new Stat(StatType.maxHP);
    public Stat speed = new Stat(StatType.speed);
    public ScaledStat defense = new ScaledStat(StatType.defense);
    public Stat size = new Stat(StatType.size);

    [Header("Mod Stats: don't have to change")]
    public ModStat dmgMult = new ModStat(StatType.dmgMult);
    public ModStat meleeDmgMult = new ModStat(StatType.meleeDmgMult);
    public ModStat rangedDmgMult = new ModStat(StatType.rangedDmgMult);
    public ModStat sharpDmgMult = new ModStat(StatType.sharpDmgMult);
    public ModStat bluntDmgMult = new ModStat(StatType.bluntDmgMult);
}

// I'm gonna put our stat math into an abstract class just in case.

// Formulas from Riot Endstep's scaling math presentation ---> https://www.youtube.com/watch?v=mwWzZbTf3V4
public class StatUtils {
    public static float ScaleStat(float value, float baseScale) {
        return 1 / (Mathf.Max(baseScale + (value / 100f), 0.01f));
    }

    public static float PostMitDmg(float damage, float statVal, ScaledStat mitStat) {
        if (mitStat.baseVal >= 0) {
            return damage * ScaleStat(statVal, mitStat.baseScale);
        }
        return damage * (2 - ScaleStat(statVal, mitStat.baseScale));
    }

}


