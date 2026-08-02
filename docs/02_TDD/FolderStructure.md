# Struktur Folder Unity

## Ringkasan

Struktur folder proyek Unity Arcadia Online. Setiap folder memiliki tanggung jawab spesifik.

## Root Structure

```
Arcadia-Online/
├── Assets/
│   ├── Scripts/
│   ├── Prefabs/
│   ├── Scenes/
│   ├── Art/
│   ├── Audio/
│   ├── Data/
│   ├── UI/
│   ├── Resources/
│   └── Plugins/
├── Packages/
├── ProjectSettings/
└── UserSettings/
```

## Scripts/

```
Scripts/
├── Core/                    ← Sistem inti
│   ├── GameManager.cs
│   ├── EventSystem.cs
│   ├── ObjectPool.cs
│   └── Singleton.cs
│
├── Player/                  ← Sistem pemain
│   ├── PlayerController.cs
│   ├── PlayerStats.cs
│   ├── PlayerInventory.cs
│   └── PlayerEquipment.cs
│
├── Combat/                  ← Sistem pertarungan
│   ├── CombatManager.cs
│   ├── TargetLock.cs
│   ├── DamageCalculator.cs
│   └── SkillSystem.cs
│
├── NPC/                     ← Sistem NPC
│   ├── NPCController.cs
│   ├── DialogueSystem.cs
│   ├── QuestGiver.cs
│   └── Merchant.cs
│
├── Monster/                 ← Sistem monster
│   ├── MonsterController.cs
│   ├── MonsterAI.cs
│   ├── BossController.cs
│   └── SpawnSystem.cs
│
├── World/                   ← Sistem dunia
│   ├── WorldState.cs
│   ├── WeatherSystem.cs
│   ├── DayNightCycle.cs
│   └── MapManager.cs
│
├── UI/                      ← Sistem UI
│   ├── UIManager.cs
│   ├── HUDController.cs
│   ├── MenuController.cs
│   └── DialogueUI.cs
│
├── Save/                    ← Sistem simpan
│   ├── SaveManager.cs
│   ├── SaveData.cs
│   └── CloudSave.cs
│
├── Data/                    ← Data & config
│   ├── GameData.cs
│   ├── ItemDatabase.cs
│   ├── MonsterDatabase.cs
│   └── QuestDatabase.cs
│
└── Utils/                   ← Utilities
    ├── MathHelper.cs
    ├── StringHelper.cs
    └── Extensions.cs
```

## Art/

```
Art/
├── Characters/              ← Model & animasi karakter
│   ├── Player/
│   ├── NPC/
│   └── Monster/
├── Environment/             ← Model lingkungan
│   ├── Terrain/
│   ├── Buildings/
│   └── Props/
├── VFX/                     ← Visual effects
│   ├── Combat/
│   ├── Environment/
│   └── UI/
├── Materials/               ← Material & shader
│   ├── CelShader/
│   └── Standard/
└── Textures/                ← Texture
    ├── Characters/
    ├── Environment/
    └── UI/
```

## Naming Convention

| Tipe | Format | Contoh |
|------|--------|--------|
| Script | PascalCase | `PlayerController.cs` |
| Prefab | PascalCase | `Player.prefab` |
| Scene | PascalCase | `MainMenu.unity` |
| Material | PascalCase_Mat | `PlayerBody_Mat.mat` |
| Texture | snake_case | `player_body_albedo.png` |
| Animation | PascalCase_Anim | `Idle_Anim.anim` |
| Audio | snake_case | `bgm_forest.wav` |
