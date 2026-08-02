# Standar Kode (Coding Standard)

## Ringkasan

Standar kode untuk menjaga konsistensi dan kualitas kode dalam proyek Arcadia Online.

## Naming Convention

### Class & Struct
```csharp
// PascalCase
public class PlayerController { }
public struct Vector3Data { }
public interface IDamageable { }
```

### Methods
```csharp
// PascalCase
public void TakeDamage(float amount) { }
public float CalculateDamage() { return 0f; }
```

### Variables
```csharp
// camelCase untuk private & local
private float currentHP;
private string playerName;

// PascalCase untuk public property
public float MaxHP { get; private set; }
public string Name { get; set; }

// UPPER_SNAKE untuk constants
private const float MAX_SPEED = 10f;
private const int INVENTORY_SIZE = 50;
```

### Fields
```csharp
// Prefix underscore untuk private field
[SerializeField] private float _moveSpeed;
private int _level;

// Tanpa prefix untuk public field
public float moveSpeed;
public int level;
```

## File Structure

```csharp
// 1. Using statements
using System;
using System.Collections.Generic;
using UnityEngine;

// 2. Namespace
namespace ArcadiaOnline.Player
{
    // 3. Class declaration
    public class PlayerController : MonoBehaviour
    {
        // 4. Constants
        private const float MAX_SPEED = 10f;
        
        // 5. Serialized fields
        [SerializeField] private float _moveSpeed;
        
        // 6. Private fields
        private float _currentHP;
        
        // 7. Properties
        public float CurrentHP => _currentHP;
        
        // 8. Unity methods (Awake, Start, Update)
        void Awake() { }
        void Start() { }
        void Update() { }
        
        // 9. Public methods
        public void TakeDamage(float amount) { }
        
        // 10. Private methods
        private void Move() { }
    }
}
```

## Code Style

### Braces
```csharp
// Opening brace on new line
if (condition)
{
    // code
}
else
{
    // code
}
```

### Spacing
```csharp
// Spasi antara operator
float result = a + b;
bool isValid = x > 0 && y < 100;

// Spasi setelah koma
void Method(int a, int b, int c) { }
```

### Comments
```csharp
// Single line comment
/* Multi-line comment */

/// <summary>
/// XML documentation for public API
/// </summary>
public void PublicMethod() { }
```

## Error Handling

```csharp
// Null check
if (component == null)
{
    Debug.LogError("Component not found!");
    return;
}

// Try-catch untuk risky operations
try
{
    SaveManager.Instance.Save(slot);
}
catch (Exception e)
{
    Debug.LogError($"Save failed: {e.Message}");
}
```

## Unity-Specific Rules

| Rule | Bad | Good |
|------|-----|------|
| GetComponent | Setiap frame | Cache di Awake |
| Find | FindObjectOfType | Reference atau Singleton |
| String | "Player" | const string PLAYER_TAG |
| Alloc | new List di Update | Reuse list |
| Corotine | StartCoroutine di Update | Flag + check |

## Code Review Checklist

- [ ] Naming conventions followed
- [ ] No magic numbers
- [ ] Error handling present
- [ ] Comments for complex logic
- [ ] No performance issues (alloc in Update, etc)
- [ ] Unity best practices followed
- [ ] No unused variables/methods
- [ ] Consistent formatting
