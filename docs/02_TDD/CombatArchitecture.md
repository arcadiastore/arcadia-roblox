# Arsitektur Pertarungan

## Ringkasan

Arsitektur sistem pertarungan real-time dengan Target Lock di Unity.

## Komponen Utama

```
CombatManager (Singleton)
├── TargetLockSystem
├── DamageCalculator
├── SkillSystem
├── BuffSystem
└── CombatUI
```

## CombatManager

```csharp
public class CombatManager : MonoBehaviour
{
    public static CombatManager Instance { get; private set; }
    
    public bool IsInCombat { get; private set; }
    public Transform CurrentTarget { get; private set; }
    
    public void EnterCombat(Transform enemy);
    public void ExitCombat();
    public void SwitchTarget();
    public void ExecuteAttack();
    public void ExecuteSkill(int skillIndex);
    public void ExecuteDefend();
    public void ExecuteFlee();
}
```

## TargetLockSystem

```csharp
public class TargetLockSystem : MonoBehaviour
{
    [SerializeField] private float lockRange = 15f;
    [SerializeField] private float switchCooldown = 0.5f;
    
    private List<Transform> availableTargets = new List<Transform>();
    private int currentTargetIndex = 0;
    
    public Transform FindNearestTarget();
    public void SwitchToNextTarget();
    public void SwitchToPreviousTarget();
    public void ClearTarget();
    public bool IsTargetInRange();
}
```

## DamageCalculator

```csharp
public static class DamageCalculator
{
    public static DamageResult CalculatePhysical(
        float atk, float targetDef, float skillMultiplier, 
        float critRate, float critDamage)
    {
        float baseDamage = (atk * skillMultiplier) - (targetDef * 0.5f);
        bool isCrit = Random.value < critRate;
        float finalDamage = isCrit ? baseDamage * (critDamage / 100f) : baseDamage;
        
        return new DamageResult
        {
            Damage = Mathf.Max(1, finalDamage),
            IsCritical = isCrit
        };
    }
    
    public static DamageResult CalculateMagic(
        float matk, float targetMdef, float skillMultiplier,
        float critRate, float critDamage)
    {
        // Similar to physical but uses MATK and MDEF
    }
}
```

## SkillSystem

```csharp
public class SkillSystem : MonoBehaviour
{
    [SerializeField] private SkillData[] equippedSkills = new SkillData[8];
    
    public void UseSkill(int index);
    public bool CanUseSkill(int index);
    public float GetCooldownRemaining(int index);
    public void EquipSkill(SkillData skill, int slot);
    public void UnequipSkill(int slot);
}

[System.Serializable]
public class SkillData
{
    public string id;
    public string skillName;
    public SkillType type;
    public float mpCost;
    public float cooldown;
    public float damageMultiplier;
    public SkillEffect effect;
}
```

## Alur Pertarungan

```
1. Player mendekati Enemy
       ↓
2. TargetLockSystem mendeteksi target
       ↓
3. Player menekan Attack
       ↓
4. CombatManager.ExecuteAttack()
       ↓
5. DamageCalculator menghitung damage
       ↓
6. Enemy menerima damage
       ↓
7. Enemy AI merespons
       ↓
8. Ulangi sampai salah satu HP = 0
```
