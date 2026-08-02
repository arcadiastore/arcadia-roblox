# Game Managers

## Ringkasan

Game Manager adalah singleton class yang mengelola sistem global dalam game. Setiap manager memiliki tanggung jawab spesifik.

## Daftar Manager

### 1. GameManager
```csharp
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    
    public GameState CurrentState { get; private set; }
    public float PlayTime { get; private set; }
    
    public void ChangeState(GameState newState);
    public void PauseGame();
    public void ResumeGame();
    public void QuitGame();
}

public enum GameState
{
    MainMenu,
    Playing,
    Paused,
    Battle,
    Cutscene,
    GameOver
}
```

### 2. SaveManager
```csharp
public class SaveManager : MonoBehaviour
{
    public static SaveManager Instance { get; private set; }
    
    public void Save(int slot);
    public void Load(int slot);
    public void AutoSave();
    public void DeleteSave(int slot);
    public SaveData GetSaveData(int slot);
    public bool HasSave(int slot);
}
```

### 3. AudioManager
```csharp
public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }
    
    public void PlayBGM(string bgmName);
    public void PlaySFX(string sfxName);
    public void PlayVoice(string voiceName);
    public void StopBGM();
    public void SetVolume(AudioType type, float volume);
}
```

### 4. UIManager
```csharp
public class UIManager : MonoBehaviour
{
    public static UIManager Instance { get; private set; }
    
    public void ShowHUD();
    public void HideHUD();
    public void ShowMenu();
    public void HideMenu();
    public void ShowDialogue(DialogueData data);
    public void ShowNotification(string message);
}
```

### 5. QuestManager
```csharp
public class QuestManager : MonoBehaviour
{
    public static QuestManager Instance { get; private set; }
    
    public void AcceptQuest(string questId);
    public void CompleteQuest(string questId);
    public void FailQuest(string questId);
    public List<QuestData> GetActiveQuests();
    public bool IsQuestComplete(string questId);
}
```

### 6. WorldStateManager
```csharp
public class WorldStateManager : MonoBehaviour
{
    public static WorldStateManager Instance { get; private set; }
    
    public void SetState(string key, bool value);
    public bool GetState(string key);
    public void RegisterState(string key, bool defaultValue);
}
```

## Manager Dependencies

```
GameManager (root)
├── SaveManager
├── AudioManager
├── UIManager
├── QuestManager
├── WorldStateManager
├── CombatManager
├── NPCManager
├── ItemManager
└── MapManager
```

## Initialization Order

```
1. GameManager (Awake)
2. SaveManager (Awake)
3. WorldStateManager (Awake)
4. AudioManager (Awake)
5. UIManager (Awake)
6. QuestManager (Start)
7. CombatManager (Start)
8. NPCManager (Start)
9. ItemManager (Start)
10. MapManager (Start)
```
