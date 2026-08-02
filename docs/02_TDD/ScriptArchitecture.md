# Arsitektur Script

## Ringkasan

Dokumen ini menjelaskan pola arsitektur script yang digunakan dalam proyek Arcadia Online.

## Pola Utama

### 1. Manager Pattern
Singleton manager untuk sistem global:

```csharp
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    
    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }
}
```

### 2. Event System
Komunikasi antar sistem tanpa coupling:

```csharp
public static class Events
{
    public static event System.Action<int> OnPlayerLevelUp;
    public static event System.Action<string> OnQuestComplete;
    public static event System.Action<float> OnHPChanged;
    
    public static void PlayerLevelUp(int level) => OnPlayerLevelUp?.Invoke(level);
    public static void QuestComplete(string questId) => OnQuestComplete?.Invoke(questId);
    public static void HPChanged(float hp) => OnHPChanged?.Invoke(hp);
}
```

### 3. State Machine
Untuk AI dan game state:

```csharp
public interface IState
{
    void Enter();
    void Update();
    void Exit();
}

public class StateMachine
{
    private IState currentState;
    
    public void ChangeState(IState newState)
    {
        currentState?.Exit();
        currentState = newState;
        currentState.Enter();
    }
    
    public void Update() => currentState?.Update();
}
```

### 4. Object Pool
Untuk performa:

```csharp
public class ObjectPool<T> where T : MonoBehaviour
{
    private Queue<T> pool = new Queue<T>();
    private T prefab;
    
    public T Get()
    {
        T obj = pool.Count > 0 ? pool.Dequeue() : Instantiate(prefab);
        obj.gameObject.SetActive(true);
        return obj;
    }
    
    public void Return(T obj)
    {
        obj.gameObject.SetActive(false);
        pool.Enqueue(obj);
    }
}
```

## Script Communication

```
[GameManager]
    ├── Events (global events)
    ├── PlayerController
    │   ├── Input → Movement
    │   ├── Input → Combat
    │   └── Events → UI
    ├── CombatManager
    │   ├── Player → Monster
    │   ├── Monster → Player
    │   └── Events → UI
    └── UIManager
        ├── Listen Events
        └── Update UI
```

## Naming Convention

| Item | Format | Contoh |
|------|--------|--------|
| Class | PascalCase | `PlayerController` |
| Method | PascalCase | `TakeDamage()` |
| Variable | camelCase | `currentHP` |
| Constant | UPPER_SNAKE | `MAX_HP` |
| Interface | I + PascalCase | `IDamageable` |
| Enum | PascalCase | `MonsterType` |
| Property | PascalCase | `public int HP { get; set; }` |
