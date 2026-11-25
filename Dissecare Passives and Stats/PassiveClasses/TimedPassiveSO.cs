using UnityEngine;

// Timed Passive inherits PassiveSO, which inherits PassiveBase.
// It's essentially the same thing, but it has an extra Duration variable and its own countdown timer.
// When the timer fully counts down, it marks itself for removal.

[CreateAssetMenu(menuName = "Passives/Temporary Passive")]
public class TimedPassiveSO : PassiveSO {

    public float duration;

    private CountdownTimer timer;

    public override void OnApply() {
        timer = new CountdownTimer(duration);
        Refresh();

        timer.OnTimerStop += MarkForRemoval;
    }
    
    public void Refresh() {
        markedForRemoval = false;
        timer.Reset();
        timer.Start();
    }

    public void TickTimer(float delta) {
        timer.Tick(delta);
    }

    public override void Dispose() {
        timer.OnTimerStop -= MarkForRemoval;
        base.Dispose();
    }

}
