# Arsitektur Save System

## Ringkasan

Sistem simpan menggunakan JSON untuk serialisasi data dan PlayerPrefs untuk pengaturan.

## SaveManager

```csharp
public class SaveManager : MonoBehaviour
{
    private const string SAVE_PATH = "Saves/";
    private const int MAX_SLOTS = 10;
    
    public void Save(int slot)
    {
        SaveData data = CollectSaveData();
        string json = JsonUtility.ToJson(data, true);
        string path = GetSavePath(slot);
        File.WriteAllText(path, json);
        
        // Backup
        File.Copy(path, GetBackupPath(slot), true);
    }
    
    public void Load(int slot)
    {
        string path = GetSavePath(slot);
        if (!File.Exists(path)) return;
        
        string json = File.ReadAllText(path);
        SaveData data = JsonUtility.FromJson<SaveData>(json);
        ApplySaveData(data);
    }
    
    private string GetSavePath(int slot) => 
        Application.persistentDataPath + SAVE_PATH + $"save_{slot}.json";
}
```

## SaveData Structure

```csharp
[System.Serializable]
public class SaveData
{
    // Metadata
    public string saveDate;
    public float playTime;
    public string gameVersion;
    
    // Player
    public PlayerSaveData player;
    
    // Party
    public List<CompanionSaveData> companions;
    
    // World
    public WorldSaveData world;
    
    // Quest
    public QuestSaveData quests;
    
    // Inventory
    public InventorySaveData inventory;
}

[System.Serializable]
public class PlayerSaveData
{
    public string name;
    public int level;
    public string jobId;
    public float currentHP;
    public float currentMP;
    public float exp;
    public float[] position; // x, y, z
    public string currentScene;
    public List<StatSaveData> stats;
    public List<string> unlockedSkills;
}

[System.Serializable]
public class WorldSaveData
{
    public Dictionary<string, bool> worldStates;
    public Dictionary<string, int> reputation;
    public Dictionary<string, int> affinity;
    public int dayCount;
    public string weather;
    public string timeOfDay;
}
```

## Auto Save

```csharp
public class AutoSaveSystem : MonoBehaviour
{
    [SerializeField] private float autoSaveInterval = 300f; // 5 menit
    private float timer;
    
    void Update()
    {
        timer += Time.deltaTime;
        if (timer >= autoSaveInterval)
        {
            SaveManager.Instance.AutoSave();
            timer = 0f;
        }
    }
}
```

## Save Integrity

```csharp
public static class SaveValidator
{
    public static bool ValidateSave(SaveData data)
    {
        // Checksum validation
        string computedHash = ComputeHash(data);
        return computedHash == data.checksum;
    }
    
    private static string ComputeHash(SaveData data)
    {
        // SHA256 hash of save data
    }
}
```

## File Structure

```
Saves/
├── save_0.json
├── save_0_backup.json
├── save_1.json
├── save_1_backup.json
├── ...
├── save_9.json
├── save_9_backup.json
├── autosave.json
├── autosave_backup.json
└── quicksave.json
```
