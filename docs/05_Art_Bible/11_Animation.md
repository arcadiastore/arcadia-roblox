# Animasi (Art Bible)

## Ringkasan

Panduan untuk animasi karakter dan monster.

## Gaya Animasi

### Prinsip
- **Exaggerated** — Gerakan dilebihkan untuk efek
- **Snappy** — Transisi cepat, tidak lambat
- **Readable** — Gerakan harus jelas
- **Anime** — Terinspirasi anime

## Karakter Animation Set

### Basic
| Animasi | Durasi | Loop |
|---------|--------|------|
| Idle | 2-4s | Yes |
| Walk | 0.8s | Yes |
| Run | 0.6s | Yes |
| Sprint | 0.5s | Yes |

### Combat
| Animasi | Durasi | Loop |
|---------|--------|------|
| Attack_1 | 0.5s | No |
| Attack_2 | 0.5s | No |
| Attack_3 | 0.7s | No |
| Dodge | 0.4s | No |
| Block | 0.3s | No |
| Hit | 0.3s | No |
| Death | 1.0s | No |

### Skill
| Animasi | Durasi | Loop |
|---------|--------|------|
| Skill_Cast | 0.5-1.0s | No |
| Skill_Channel | 1.0-3.0s | Yes |
| Skill_Release | 0.3-0.5s | No |

### Social
| Animasi | Durasi | Loop |
|---------|--------|------|
| Wave | 1.0s | No |
| Bow | 1.0s | No |
| Sit | - | Yes |
| Dance | 3.0s | Yes |

## Monster Animation Set

### Basic
| Animasi | Durasi | Loop |
|---------|--------|------|
| Idle | 2-3s | Yes |
| Walk | 0.8s | Yes |
| Run | 0.5s | Yes |

### Combat
| Animasi | Durasi | Loop |
|---------|--------|------|
| Attack | 0.5-1.0s | No |
| Special | 1.0-2.0s | No |
| Hit | 0.3s | No |
| Death | 1.0-2.0s | No |

## Animation Principles

### Squash & Stretch
- Karakter sedikit gepeng saat mendarat
- Stretch saat melompat
- Exaggerated untuk efek

### Anticipation
- Ayunan pedang: tarik ke belakang dulu
- Lompat: squat dulu
- Skill: charge dulu

### Follow Through
- Rambut dan pakaian bergerak setelah karakter berhenti
- Senjata berayun setelah serangan
- Cape mengikuti gerakan

### Timing
- Fast in, slow out
- Snappy untuk combat
- Smooth untuk eksplorasi

## Animation Blending

### Blend Tree
```
Movement:
  Idle ↔ Walk ↔ Run (Speed parameter)

Combat:
  Attack_1 ↔ Attack_2 ↔ Attack_3 (Combo parameter)
```

### Layer
| Layer | Weight | Fungsi |
|-------|--------|--------|
| Base | 1.0 | Movement |
| Upper Body | 0.5 | Skill tanpa gerak kaki |
| Face | 1.0 | Ekspresi |
| Override | 1.0 | Death, cutscene |

## Animation Events

```csharp
// Di frame tertentu
void OnAttackHitFrame() { ApplyDamage(); }
void OnSkillEffect() { SpawnVFX(); }
void OnFootstep() { PlayFootstepSFX(); }
```

## Referensi

- **Genshin Impact** — Anime RPG animation
- **Devil May Cry** — Snappy combat
- **Persona 5** — Stylish animation
- **Zelda** — Smooth exploration
