using System;
using System.Collections.Generic;
using UnityEngine;

public class Actor : MonoBehaviour, IDamageable {
    public BaseStatsSO baseStats;
    public Dictionary<StatType, Func<float>> statMap;
    public PassivesManager pm { get; private set; }
    public float Health { get; set; }
    public bool isInvincible = false;

    #region Stat Getter Methods (Update when adding new stats!)
    public float attack => pm.GetFinalStat(StatType.attack, baseStats.attack.GetValue());
    public float maxHP => pm.GetFinalStat(StatType.maxHP, baseStats.maxHP.GetValue());
    public float speed => pm.GetFinalStat(StatType.speed, baseStats.speed.GetValue());
    public float defense => pm.GetFinalStat(StatType.defense, baseStats.defense.GetValue());
    public float size => pm.GetFinalStat(StatType.size, baseStats.size.GetValue());
    public float dmgMult => pm.GetFinalStat(StatType.dmgMult, baseStats.dmgMult.GetValue());
    public float meleeDmgMult => pm.GetFinalStat(StatType.meleeDmgMult, baseStats.meleeDmgMult.GetValue());
    public float rangedDmgMult => pm.GetFinalStat(StatType.rangedDmgMult, baseStats.rangedDmgMult.GetValue());
    public float sharpDmgMult => pm.GetFinalStat(StatType.sharpDmgMult, baseStats.sharpDmgMult.GetValue());
    public float bluntDmgMult => pm.GetFinalStat(StatType.bluntDmgMult, baseStats.bluntDmgMult.GetValue());
    #endregion

    #region StatMap construction method (Update when adding new stats!)
    private void ConstructStatMap() {
        statMap = new Dictionary<StatType, Func<float>> {
            {StatType.attack, () => attack},
            {StatType.maxHP, () => maxHP},
            {StatType.speed, () => speed},
            {StatType.defense, () => defense},
            {StatType.size, () => size},
            {StatType.dmgMult, () => dmgMult},
            {StatType.meleeDmgMult, () => meleeDmgMult},
            {StatType.rangedDmgMult, () => rangedDmgMult},
            {StatType.sharpDmgMult, () => sharpDmgMult},
            {StatType.bluntDmgMult, () => bluntDmgMult}
        };
    }
    #endregion

    #region Observer Signals! Add as you please :)
    public Action<float> OnHurt = delegate { };
    public Action<float> OnGetHit = delegate { };
    public Action<float> OnHeal = delegate { };
    public Action<Actor> OnDeath = delegate { };
    #endregion

    // This method constructs the Stat Map! When adding new stat types, please add them to this dicionary!

    protected virtual void Awake() {
        pm = new PassivesManager(this);
        ConstructStatMap();
    }

    protected virtual void Start() {
        Health = baseStats.maxHP.GetValue();
    }

    protected virtual void Update() {
        pm.Update(Time.deltaTime);
    }

    public virtual float DamageCalc(float amount) {
        return StatUtils.PostMitDmg(amount, defense, baseStats.defense);
        
    }

    public virtual void Die() {
        OnDeath?.Invoke(this);
        pm.ClearAll();
    }

    public void TakeDamage(float amount, AbilityType abilityType, DamageType damageType) {
        if (isInvincible) return;

        float healthBeforeHit = Health;
        float damageReceived = DamageCalc(amount);
        Health -= damageReceived;
        if (!CompareTag("Player")) DamagePopupSystem.ShowDamagePopup(transform.position, Mathf.FloorToInt(damageReceived).ToString());
        OnGetHit?.Invoke(damageReceived);

        if (Health < healthBeforeHit)
        {
            OnHurt?.Invoke(healthBeforeHit - Health);

            //// Debug.Log($"I got hit! My new HP: {Health} -{gameObject.name}");

            if (Health <= 0)
            {
                Die();
            }
        }
    }

    public void Heal (float value) {
        OnHeal?.Invoke(value);
    }

    public void EnableInvincibility()
    {
        isInvincible = true;
    }
}
