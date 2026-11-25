using UnityEngine;


public enum FuncType {
    none,
    easeInCubic,
    easeOutCubic,
    easeInOutCubic
}

[System.Serializable]
public class EaseFunctions {
    public FuncType type = FuncType.none;
    
    public float ApplyEase(float x) {
        switch (type) {
            case FuncType.easeInCubic:
                return Mathf.Pow(x, 3);
            case FuncType.easeOutCubic:
                return 1 - Mathf.Pow(1 - x, 3);
            case FuncType.easeInOutCubic:
                return x < 0.5 ? 4 * x * x * x : 1 - Mathf.Pow(-2 * x + 2, 3) / 2;
            default:
                return x;
        }
    }


}