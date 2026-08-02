# Database Save (Save DB)

## Ringkasan

Struktur data untuk sistem save/load game.

## Save Format

### Root Structure
```json
{
  "metadata": {
    "version": "1.0.0",
    "save_date": "2026-07-31T10:30:00",
    "playtime": 3600.5,
    "slot": 1,
    "checksum": "abc123..."
  },
  "player": { ... },
  "party": { ... },
  "inventory": { ... },
  "quests": { ... },
  "world": { ... },
  "settings": { ... }
}
```

### Player Section
```json
{
  "player": {
    "name": "Hero",
    "level": 25,
    "exp": 15000,
    "job_id": "knight",
    "hp": 450,
    "max_hp": 500,
    "mp": 120,
    "max_mp": 150,
    "gold": 5000,
    "position": {"x": 10.5, "y": 0, "z": -5.2},
    "scene": "scene_green_forest",
    "stats": {
      "ATK": 45,
      "DEF": 38,
      "MATK": 15,
      "MDEF": 12,
      "SPD": 20,
      "LUK": 10
    },
    "equipped_skills": [
      "skill_slash",
      "skill_shield_bash",
      "skill_war_cry"
    ],
    "unlocked_jobs": ["warrior", "knight"],
    "stamina": 85
  }
}
```

### Party Section
```json
{
  "party": {
    "members": ["hero", "lyra", "borin"],
    "formation": {
      "front": ["hero", "borin"],
      "back": ["lyra"]
    },
    "companions": {
      "lyra": {
        "level": 22,
        "hp": 280,
        "mp": 300,
        "affinity": 65,
        "equipped_items": {
          "weapon": "weapon_apprentice_staff",
          "body": "armor_mage_robe"
        }
      },
      "borin": {
        "level": 24,
        "hp": 520,
        "mp": 40,
        "affinity": 45,
        "equipped_items": {
          "weapon": "weapon_iron_axe",
          "body": "armor_iron"
        }
      }
    }
  }
}
```

### Inventory Section
```json
{
  "inventory": {
    "slots": 50,
    "items": [
      {"item_id": "potion_hp_small", "quantity": 15},
      {"item_id": "potion_mp_small", "quantity": 8},
      {"item_id": "material_iron_ore", "quantity": 23},
      {"item_id": "weapon_iron_sword", "quantity": 1}
    ],
    "equipment": {
      "weapon": "weapon_iron_sword",
      "sub_weapon": "shield_iron",
      "head": "helm_iron",
      "body": "armor_iron",
      "hands": null,
      "feet": "boots_iron",
      "accessory_1": "ring_hp",
      "accessory_2": null
    }
  }
}
```

### Quest Section
```json
{
  "quests": {
    "active": [
      {
        "id": "Q002",
        "objectives": [
          {"type": "COLLECT", "target": "herb_001", "current": 2, "required": 3}
        ]
      }
    ],
    "completed": ["Q001"],
    "failed": []
  }
}
```

### World Section
```json
{
  "world": {
    "worldstates": {
      "village_saved": true,
      "king_alive": true,
      "demon_king_awaken": false
    },
    "reputation": {
      "village": 50,
      "merchant": 30,
      "rebel": 10
    },
    "affinity": {
      "NPC001": 40,
      "NPC010": 65,
      "NPC020": 25
    },
    "unlocked_areas": [
      "area_beginner_village",
      "area_green_forest"
    ],
    "day_count": 15,
    "current_weather": "clear",
    "current_time": "14:30"
  }
}
```

## Save Validation

```csharp
public class SaveValidator
{
    public static bool Validate(SaveData save)
    {
        // 1. Checksum valid
        if (ComputeChecksum(save) != save.metadata.checksum)
            return false;
        
        // 2. Version compatible
        if (!IsVersionCompatible(save.metadata.version))
            return false;
        
        // 3. Data integrity
        if (save.player.hp > save.player.max_hp)
            return false;
        
        return true;
    }
}
```

## Migration

| Version | Changes |
|---------|---------|
| 1.0.0 | Initial format |
| 1.1.0 | Added stamina field |
| 1.2.0 | Added pet data |
| 2.0.0 | Cloud save format |
