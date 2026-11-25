[System.Serializable]

// wow! such empty
public class Stat 
{
    public StatType statType { get; set; }
    public float baseVal;

    public Stat (StatType statType) {
        this.statType = statType;
    }
    public virtual float GetValue() {
        return baseVal;
    }

}
