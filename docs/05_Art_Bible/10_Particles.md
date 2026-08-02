# Partikel (Particles)

## Ringkasan

Panduan untuk efek partikel dalam game.

## Kategori Partikel

### Combat VFX
| Efek | Warna | Durasi |
|------|-------|--------|
| Slash | Putih, silver | 0.3s |
| Fire | Merah, oranye | 0.5s |
| Ice | Biru, putih | 0.5s |
| Lightning | Kuning, putih | 0.2s |
| Heal | Hijau, putih | 1.0s |
| Buff | Emas, putih | 2.0s |
| Debuff | Ungu, hitam | 2.0s |

### Environment VFX
| Efek | Warna | Durasi |
|------|-------|--------|
| Daun jatuh | Hijau, coklat | Continuous |
| Salju | Putih | Continuous |
| Hujan | Biru transparan | Continuous |
| Kabut | Putih transparan | Continuous |
| Partikel cahaya | Kuning, putih | Continuous |
| Kupu-kupu | Bervariasi | Continuous |

### UI VFX
| Efek | Warna | Durasi |
|------|-------|--------|
| Level up | Emas, putih | 2.0s |
| Achievement | Emas | 3.0s |
| Item pickup | Sesuai rarity | 0.5s |
| Damage number | Merah (damage), Hijau (heal) | 1.0s |
| Critical | Merah besar + efek | 1.0s |

## Partikel per Skill

### Warrior Skills
```
Slash: Garis putih horizontal
Shield Bash: Gelombang kejut
War Cry: Aura merah
Berserk: Api merah di sekitar karakter
```

### Mage Skills
```
Fire Bolt: Bola api kecil
Ice Wall: Dinding es kristal
Meteor: Bola api besar dari atas
Archmage's Fury: Aura ungu + petir
```

### Archer Skills
```
Arrow Shot: Panah dengan trail
Rain of Arrows: Banyak panah dari atas
Eagle Eye: Mata elang bercahaya
Shadow Strike: Bayangan bergerak
```

## Sistem Partikel Unity

### Komponen
```
ParticleSystem
├── Emission: Rate over time/distance
├── Shape: Bentuk emisi (sphere, cone, box)
├── Velocity: Kecepatan & arah
├── Lifetime: Umur partikel
├── Size: Ukuran partikel
├── Color: Warna & gradient
├── Rotation: Rotasi partikel
├── Renderer: Billboard/Mesh
└── Collision: Interaksi dengan world
```

### Pooling
- Semua partikel menggunakan object pool
- Spawn dari pool, return setelah selesai
- Max 50 partikel aktif sekaligus

## Performance

| Platform | Max Particles | Texture Size |
|----------|--------------|--------------|
| Mobile | 500 | 64x64 |
| PC Low | 1000 | 128x128 |
| PC High | 5000 | 256x256 |

## Referensi

- **Genshin Impact** — VFX anime terbaik
- **Final Fantasy XIV** — VFX skill beragam
- **Persona 5** — VFX stylish
- **Guilty Gear** — VFX anime fighting
