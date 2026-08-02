# Database Lokalisasi (Localization DB)

## Ringkasan

Struktur data untuk mendukung multi-bahasa.

## Tabel Utama

### localization_keys
| Field | Type | Description |
|-------|------|-------------|
| key | string | Kunci unik (e.g. "ui.menu.start") |
| category | enum | UI, DIALOGUE, QUEST, ITEM, SKILL, SYSTEM |
| context | string | Konteks penggunaan |

### localization_values
| Field | Type | Description |
|-------|------|-------------|
| key | string | FK ke localization_keys |
| language | string | Kode bahasa (id, en, ja, zh) |
| value | string | Teks terjemahan |

## Format Kunci

```
[category].[context].[name]

Contoh:
ui.menu.start_game
dialogue.npc.aldric.greeting
quest.q001.name
item.potion_hp_small.name
skill.slash.description
system.error.inventory_full
```

## Bahasa yang Didukung

| Kode | Bahasa | Status |
|------|--------|--------|
| id | Bahasa Indonesia | Utama |
| en | English | Terjemahan |
| ja | 日本語 | Rencana |
| zh | 中文 | Rencana |

## Contoh Data

### UI Strings
```json
{
  "ui.menu.start_game": {
    "id": "Mulai Game",
    "en": "Start Game",
    "ja": "ゲーム開始",
    "zh": "开始游戏"
  },
  "ui.menu.continue": {
    "id": "Lanjutkan",
    "en": "Continue",
    "ja": "続きから",
    "zh": "继续"
  },
  "ui.menu.settings": {
    "id": "Pengaturan",
    "en": "Settings",
    "ja": "設定",
    "zh": "设置"
  }
}
```

### Item Names
```json
{
  "item.potion_hp_small.name": {
    "id": "Ramuan HP Kecil",
    "en": "Small Health Potion",
    "ja": "小回復薬",
    "zh": "小生命药水"
  },
  "item.potion_hp_small.desc": {
    "id": "Memulihkan 50 HP",
    "en": "Restores 50 HP",
    "ja": "HP50回復",
    "zh": "恢复50生命值"
  }
}
```

### System Messages
```json
{
  "system.quest_complete": {
    "id": "Quest Selesai!",
    "en": "Quest Complete!",
    "ja": "クエスト完了！",
    "zh": "任务完成！"
  },
  "system.level_up": {
    "id": "Level Naik! Level {level}",
    "en": "Level Up! Level {level}",
    "ja": "レベルアップ！レベル{level}",
    "zh": "升级！等级{level}"
  }
}
```

## Localization Manager

```csharp
public class LocalizationManager : MonoBehaviour
{
    private Dictionary<string, Dictionary<string, string>> data;
    private string currentLanguage = "id";
    
    public string Get(string key)
    {
        if (data.ContainsKey(key) && data[key].ContainsKey(currentLanguage))
            return data[key][currentLanguage];
        
        // Fallback ke bahasa Indonesia
        if (data.ContainsKey(key) && data[key].ContainsKey("id"))
            return data[key]["id"];
        
        return $"[{key}]"; // Key not found
    }
    
    public string Get(string key, params object[] args)
    {
        string text = Get(key);
        for (int i = 0; i < args.Length; i++)
            text = text.Replace($"{{{i}}}", args[i].ToString());
        return text;
    }
}
```

## Placeholder Format

| Placeholder | Deskripsi | Contoh |
|-------------|-----------|--------|
| `{0}`, `{1}` | Positional | `"Damage: {0}"` |
| `{name}` | Named | `"{name} menyerang!"` |
| `{level}` | Variable | `"Level {level}"` |
