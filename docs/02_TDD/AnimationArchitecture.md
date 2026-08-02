# Arsitektur Animasi

## Ringkasan

Sistem animasi menggunakan Animator Controller dengan state machine dan blend tree untuk transisi yang halus.

## Animator Structure

```
Animator Controller
├── States
│   ├── Idle
│   ├── Walk
│   ├── Run
│   ├── Attack_1
│   ├── Attack_2
│   ├── Attack_3
│   ├── Skill_1..8
│   ├── Dodge
│   ├── Block
│   ├── Hit
│   ├── Death
│   └── Interact
├── Transitions
│   └── Conditions (speed, attack, skill, etc)
└── Parameters
    ├── Speed (float)
    ├── Attack (trigger)
    ├── Skill (int)
    ├── Dodge (trigger)
    ├── Block (bool)
    ├── Hit (trigger)
    └── Death (trigger)
```

## Animation Controller

```csharp
public class AnimationController : MonoBehaviour
{
    private Animator animator;
    
    private static readonly int Speed = Animator.StringToHash("Speed");
    private static readonly int Attack = Animator.StringToHash("Attack");
    private static readonly int Skill = Animator.StringToHash("Skill");
    
    public void SetSpeed(float speed) => animator.SetFloat(Speed, speed);
    public void TriggerAttack() => animator.SetTrigger(Attack);
    public void TriggerSkill(int skillId) => animator.SetInteger(Skill, skillId);
    public void TriggerDodge() => animator.SetTrigger("Dodge");
    public void TriggerDeath() => animator.SetTrigger("Death");
}
```

## Blend Tree

### Movement Blend Tree
```
Idle ←→ Walk ←→ Run
(Speed: 0) (Speed: 0.5) (Speed: 1.0)
```

### Attack Blend Tree
```
Attack_1 (combo 1)
Attack_2 (combo 2)
Attack_3 (combo 3)
```

## Animation Events

```csharp
// Dipanggil dari Animation Event
public class AnimationEventReceiver : MonoBehaviour
{
    public void OnAttackHitFrame()
    {
        // Apply damage saat frame hit
        CombatManager.Instance.ApplyDamage();
    }
    
    public void OnAttackEnd()
    {
        // Reset combo
        CombatManager.Instance.EndAttack();
    }
    
    public void OnSkillEffect()
    {
        // Spawn VFX
        SkillSystem.Instance.SpawnEffect();
    }
}
```

## Root Motion

- **Movement:** Root motion untuk walk/run
- **Combat:** Root motion untuk attack lunge
- **Skills:** Root motion untuk skill movement

## IK (Inverse Kinematics)

- **Feet IK:** Kaki menyesuaikan terrain
- **Look At:** NPC melihat pemain saat bicara
- **Hand IK:** Tangan memegang senjata dengan benar

## Animation Layer

| Layer | Weight | Fungsi |
|-------|--------|--------|
| Base | 1.0 | Movement & combat |
| Upper Body | 0.5 | Skill tanpa menggerakkan kaki |
| Face | 1.0 | Ekspresi wajah |
| Override | 1.0 | Death, cutscene |
