# Database Pemain (Player DB)

## Ringkasan

Struktur data untuk menyimpan informasi pemain.

## Tabel Utama

### player_base
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| id | string | - | ID unik pemain |
| name | string | - | Nama karakter |
| level | int | 1 | Level pemain |
| exp | long | 0 | Total EXP |
| job_id | string | "warrior" | ID job saat ini |
| hp | float | 100 | HP saat ini |
| mp | float | 50 | MP saat ini |
| gold | long | 0 | Gold saat ini |
| position_x | float | 0 | Posisi X |
| position_y | float | 0 | Posisi Y |
| position_z | float | 0 | Posisi Z |
| scene | string | "beginner_village" | Scene saat ini |
| playtime | float | 0 | Total waktu main (detik) |
| created_at | datetime | now | Waktu pembuatan |
| updated_at | datetime | now | Waktu update terakhir |

### player_stats
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| player_id | string | - | FK ke player_base |
| stat_type | string | - | Jenis stat (ATK, DEF, dll) |
| base_value | float | - | Nilai dasar |
| bonus_value | float | 0 | Nilai bonus (equipment, buff) |
| total_value | float | - | Total (base + bonus) |

### player_skills
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| player_id | string | - | FK ke player_base |
| skill_id | string | - | ID skill |
| level | int | 1 | Level skill |
| equipped | bool | false | Apakah di-equip |
| slot | int | -1 | Slot equip (0-7) |

### player_jobs
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| player_id | string | - | FK ke player_base |
| job_id | string | - | ID job |
| unlocked | bool | false | Apakah sudah di-unlock |
| unlocked_at | datetime | - | Waktu unlock |

## Relationship

```
player_base (1) ──→ (N) player_stats
player_base (1) ──→ (N) player_skills
player_base (1) ──→ (N) player_jobs
player_base (1) ──→ (N) player_equipment
player_base (1) ──→ (N) player_inventory
```

## EXP Table (Sample)

| Level | EXP Needed | Cumulative |
|-------|-----------|------------|
| 1 | 100 | 100 |
| 2 | 150 | 250 |
| 3 | 225 | 475 |
| 5 | 500 | 1,275 |
| 10 | 1,500 | 7,500 |
| 25 | 10,000 | 75,000 |
| 50 | 40,000 | 500,000 |
| 100 | 200,000 | 5,000,000 |

## Stat Growth per Job

### Warrior
| Level | HP | MP | ATK | DEF | MATK | MDEF | SPD |
|-------|-----|-----|------|------|------|------|------|
| 1 | 120 | 30 | 15 | 12 | 5 | 5 | 8 |
| 10 | 250 | 50 | 30 | 25 | 8 | 8 | 12 |
| 50 | 800 | 100 | 100 | 80 | 20 | 20 | 25 |
| 100 | 2000 | 200 | 250 | 200 | 50 | 50 | 40 |
