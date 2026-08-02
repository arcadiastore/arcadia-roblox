# Sistem Input

## Ringkasan

Sistem input menggunakan Unity's Input System Package untuk mendukung keyboard, mouse, dan gamepad.

## Input Actions

### Movement
| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Move | WASD | Left Stick |
| Sprint | Left Shift | Left Stick Press |
| Jump | Space | Button South |
| Dodge | Left Ctrl | Button East |

### Combat
| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Attack | Left Click | Right Trigger |
| Skill 1-8 | 1-8 | Face Buttons + D-Pad |
| Target Lock | Middle Click | Right Stick Press |
| Defend | Right Click | Left Trigger |
| Flee | F | Select |

### UI
| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Menu | Escape | Start |
| Inventory | I | Select |
| Map | M | - |
| Quest | Q | - |

## Input Manager

```csharp
public class InputManager : MonoBehaviour
{
    public static InputManager Instance { get; private set; }
    
    public Vector2 MoveInput { get; private set; }
    public bool IsSprinting { get; private set; }
    public bool AttackPressed { get; private set; }
    public int SkillIndex { get; private set; }
    
    private PlayerInputActions inputActions;
    
    void Awake()
    {
        inputActions = new PlayerInputActions();
        inputActions.Enable();
    }
    
    void Update()
    {
        MoveInput = inputActions.Player.Move.ReadValue<Vector2>();
        IsSprinting = inputActions.Player.Sprint.IsPressed();
        AttackPressed = inputActions.Player.Attack.WasPressedThisFrame();
    }
}
```

## Input Remapping

```csharp
public class InputRemapper : MonoBehaviour
{
    public void RemapAction(string actionName, KeyCode newKey)
    {
        var action = inputActions.FindAction(actionName);
        action.ApplyBindingOverride(newKey.ToString());
        SaveRemapSettings();
    }
    
    public void ResetToDefault()
    {
        inputActions.RemoveAllBindingOverrides();
        SaveRemapSettings();
    }
    
    private void SaveRemapSettings()
    {
        string json = inputActions.SaveBindingOverridesAsJson();
        PlayerPrefs.SetString("InputRemap", json);
    }
}
```

## Controller Support

| Controller | Support |
|------------|---------|
| Xbox | Full |
| PlayStation | Full |
| Generic | Partial |
| Mobile Touch | Future |

## Input Buffer

```csharp
public class InputBuffer : MonoBehaviour
{
    private Queue<InputCommand> buffer = new Queue<InputCommand>();
    [SerializeField] private float bufferWindow = 0.2f;
    
    public void BufferInput(InputCommand command)
    {
        buffer.Enqueue(command);
        StartCoroutine(RemoveAfterDelay(command));
    }
    
    public InputCommand ConsumeBuffer()
    {
        return buffer.Count > 0 ? buffer.Dequeue() : null;
    }
}
```
