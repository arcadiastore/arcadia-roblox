# Database Skill (Skill DB)

> **Status**: Sesuai implementasi (3 job + basic attack)

## Ringkasan

Struktur data untuk semua skill di Arcadia Online.

## Schema

### skill_base
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik skill (format: `{job}_{skill_name}`) |
| name | string | Nama skill |
| description | string | Deskripsi skill |
| type | string | physical, magic, buff, heal |
| job_id | string | ID job (warrior, mage, archer) |
| mpCost | float | Biaya MP |
| cooldown | float | Cooldown (detik) |
| damageMultiplier | float | Multiplier damage (1.0 = 100% ATK/MATK) |
| effects | table | Efek tambahan (buff, stun, shield, heal) |

---

## Semua Skill

### Basic Attack (Semua Job)
| ID | Name | Type | MP | CD | Effect |
|----|------|------|----|-----|--------|
| basic_attack | Serangan Dasar | physical | 0 | 0s | 100% ATK |

### Warrior Skills
| ID | Name | Type | MP | CD | Effect |
|----|------|------|----|-----|--------|
| warrior_power_strike | Power Strike | physical | 10 | 3s | 150% ATK |
| warrior_shout | Battle Shout | buff | 15 | 15s | +20% ATK, 10s |

### Mage Skills
| ID | Name | Type | MP | CD | Effect |
|----|------|------|----|-----|--------|
| mage_fireball | Fireball | magic | 15 | 5s | 180% MATK |
| mage_ice_shield | Ice Shield | buff | 20 | 20s | Absorb 100 dmg, 15s |

### Archer Skills
| ID | Name | Type | MP | CD | Effect |
|----|------|------|----|-----|--------|
| (belum ada) | - | - | - | - | Archer belum punya skill khusus |

---

## Contoh Data (Lua)

```lua
warrior_power_strike = {
    id = "warrior_power_strike",
    name = "Power Strike",
    description = "Serangan kuat dengan damage 150%",
    type = "physical",
    mpCost = 10,
    cooldown = 3,
    damageMultiplier = 1.5,
    effects = {},
},
```

---

## Effect Types

| Type | Description | Contoh |
|------|-------------|--------|
| buff | Buff stat sementara | `{type="buff", stat="atk", value=0.2, duration=10}` |
| shield | Absorb damage | `{type="shield", value=100, duration=15}` |
| heal | Pulihkan HP | `{type="heal", value=50}` |
| stun | Stun target | `{type="stun", duration=1}` |

---

## Relationship

```
skill_base (N) ──→ (1) job_base
skill_base (1) ──→ (N) effects
```
