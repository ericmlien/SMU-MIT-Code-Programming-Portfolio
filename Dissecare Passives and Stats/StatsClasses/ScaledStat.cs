using UnityEngine;
[System.Serializable]
public class ScaledStat : Stat {

    // Cap % for scaling stats: see this video for more details ---> https://www.youtube.com/watch?v=mwWzZbTf3V4
    // BTW this video is by my goat Riot Endstep he did the season 2026 items and the 400 gold amp tome guy

    // What are scaled stats?
    //  to put it simply, they're stats that are applied by multiplying something by their value.
    //  These are stats, not normal calc modifiers, so to avoid things getting out of control, we scale them down!
    //  Defense, for example, is used by taking a damage value and multiplying it by the Defense stat.

    // baseScale usually is just 1f, but you can shift the "asymptote" of the scaling if you want.
    // To put it simply, the "baseScale" is what the final value will be when baseVal is 0.
    // With a "baseScale" of 1f, a baseVal of 0 will GetValue will return 1f.
    //  For example, a defense stat with baseVal of 0 and baseScale of 1f would not change the incoming damage, since it's final multiplying value is 1f.

    // Changing baseScale also slightly changes the function's rate of change
    // if baseScale is less than 1f, then the scaled values, generally, will be slightly smaller.
    // if the baseScale is more, then the scaled values will be higher.

    public float baseScale = 1f;

    public ScaledStat(StatType statType) : base(statType) { }

}
