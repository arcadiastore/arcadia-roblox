# Arsitektur AI

## Ringkasan

Sistem AI untuk monster dan NPC menggunakan Finite State Machine (FSM) dengan perilaku berbeda per tipe.

## Monster AI

### State Machine
```
[Idle] → Player terdeteksi → [Chase]
   ↑                              ↓
   └──── Player hilang ←──── [Attack]
```

### States

#### Idle State
```csharp
public class IdleState : IState
{
    public void Enter()
    {
        // Mulai patrol atau diam
    }
    
    public void Update()
    {
        // Cek deteksi pemain
        if (DetectPlayer())
            stateMachine.ChangeState(new ChaseState());
    }
    
    public void Exit() { }
}
```

#### Chase State
```csharp
public class ChaseState : IState
{
    public void Enter()
    {
        // Set target ke pemain
    }
    
    public void Update()
    {
        // Bergerak ke pemain
        MoveToPlayer();
        
        // Jika dekat → Attack
        if (IsInRange())
            stateMachine.ChangeState(new AttackState());
        
        // Jika terlalu jauh → Idle
        if (IsTooFar())
            stateMachine.ChangeState(new IdleState());
    }
}
```

#### Attack State
```csharp
public class AttackState : IState
{
    public void Enter()
    {
        // Pilih serangan
    }
    
    public void Update()
    {
        // Serang pemain
        if (CanAttack())
            Attack();
        
        // Jika pemain kabur → Chase
        if (!IsInRange())
            stateMachine.ChangeState(new ChaseState());
    }
}
```

## Behavior Types

| Behavior | Idle | Chase | Attack |
|----------|------|-------|--------|
| **Passive** | Patrol | Tidak chase | Hanya jika diserang |
| **Aggressive** | Patrol | Chase saat lihat | Serang langsung |
| **Territorial** | Patrol area kecil | Chase dalam area | Serang dalam area |
| **Fleeing** | Diam | Kabur saat lihat | Tidak attack |
| **Pack** | Patrol bersama | Chase bersama | Attack bersama |

## Boss AI

### Phase System
```csharp
public class BossAI : MonoBehaviour
{
    private IBossPhase currentPhase;
    private float hpPercentage;
    
    void Update()
    {
        hpPercentage = currentHP / maxHP;
        
        if (hpPercentage <= 0.7f && currentPhase is Phase1)
            ChangePhase(new Phase2());
        else if (hpPercentage <= 0.4f && currentPhase is Phase2)
            ChangePhase(new Phase3());
        else if (hpPercentage <= 0.1f && currentPhase is Phase3)
            ChangePhase(new Phase4());
        
        currentPhase.Update();
    }
}
```

## NPC AI

### Daily Schedule
```csharp
public class NPCSchedule : MonoBehaviour
{
    [System.Serializable]
    public class ScheduleEntry
    {
        public int hour;
        public string location;
        public string activity;
    }
    
    public List<ScheduleEntry> schedule;
    
    public void UpdateSchedule(int currentHour)
    {
        // Cari entry sesuai jam
        // Bergerak ke lokasi
        // Lakukan aktivitas
    }
}
```

## Detection System

```csharp
public class DetectionSystem : MonoBehaviour
{
    [SerializeField] private float detectionRange = 10f;
    [SerializeField] private float detectionAngle = 120f;
    [SerializeField] private LayerMask detectionLayer;
    
    public bool DetectPlayer()
    {
        Collider[] colliders = Physics.OverlapSphere(
            transform.position, detectionRange, detectionLayer);
        
        foreach (var col in colliders)
        {
            Vector3 dirToPlayer = (col.transform.position - transform.position).normalized;
            float angle = Vector3.Angle(transform.forward, dirToPlayer);
            
            if (angle <= detectionAngle / 2f)
                return true;
        }
        return false;
    }
}
```
