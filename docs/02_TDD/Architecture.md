# Arsitektur Unity

## Ringkasan

Dokumen ini menjelaskan arsitektur teknis keseluruhan proyek Unity Arcadia Online.

## Stack Teknis

| Komponen | Teknologi |
|----------|-----------|
| Engine | Unity 6 LTS |
| Render Pipeline | URP (Universal Render Pipeline) |
| Language | C# |
| IDE | Visual Studio / Rider |
| Version Control | Git + Git LFS |
| Build | Unity Build Automation |

## Arsitektur Keseluruhan

```
┌─────────────────────────────────────────┐
│              Presentation Layer          │
│  UI System │ Camera │ Visual Effects     │
├─────────────────────────────────────────┤
│              Game Logic Layer            │
│  Combat │ Quest │ NPC │ World State      │
├─────────────────────────────────────────┤
│              Data Layer                  │
│  Save System │ Database │ Config         │
├─────────────────────────────────────────┤
│              Core Layer                  │
│  Event System │ Object Pool │ Utils      │
└─────────────────────────────────────────┘
```

## Pola Desain

### Singleton (untuk Manager)
- GameManager
- SaveManager
- AudioManager
- UIManager

### Observer (untuk Event)
- EventSystem untuk komunikasi antar sistem
- C# event & delegate

### State Machine (untuk AI & Game State)
- Monster AI: Patrol → Chase → Attack
- Game State: Menu → Playing → Paused → Battle

### Object Pool (untuk Performance)
- Projectile pool
- VFX pool
- Monster pool (untuk respawn)

### Factory (untuk Object Creation)
- Item factory
- Monster factory
- NPC factory

## Prinsip SOLID

- **S**ingle Responsibility — Setiap class 1 tanggung jawab
- **O**pen/Closed — Bisa extend, tidak modify
- **L**iskov Substitution — Subclass bisa ganti parent
- **I**nterface Segregation — Interface kecil & spesifik
- **D**ependency Inversion — Depend pada abstraksi

## Dependency Management

```
Presentation → Game Logic → Data → Core
     ↑              ↑         ↑      ↑
     └──────────────┴─────────┴──────┘
              Tidak boleh reverse
```
