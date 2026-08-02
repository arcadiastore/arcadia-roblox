# Pencahayaan (Lighting)

## Ringkasan

Panduan pencahayaan untuk menciptakan atmosfer yang tepat.

## Sistem Pencahayaan

### Sumber Cahaya
| Tipe | Fungsi |
|------|--------|
| Directional Light | Matahari / bulan |
| Point Light | Lampu, api, kristal |
| Spot Light | Sorotan, lentera |
| Area Light | Cahaya lembut |

### Global Illumination
- Baked GI untuk performa
- Realtime GI untuk interaksi dinamis
- Light probes untuk objek dinamis

## Pencahayaan per Area

### Beginner Village
```
Directional Light:
- Color: Warm White (#FFF5E1)
- Intensity: 1.0
- Shadow: Soft

Ambient:
- Color: Light Blue (#C4D8F0)
- Intensity: 0.3

Point Lights:
- Lampu jalan: Warm Yellow
- Api unggun: Orange
- Rumah: Warm White
```

### Dark Caverns
```
Directional Light:
- Tidak ada (bawah tanah)

Ambient:
- Color: Dark Purple (#1A0A2E)
- Intensity: 0.1

Point Lights:
- Kristal ungu: Purple Glow
- Jamur bercahaya: Green Glow
- Lava: Red-Orange
```

### Sky Islands
```
Directional Light:
- Color: Bright White (#FFFFFF)
- Intensity: 1.2
- Shadow: Hard

Ambient:
- Color: Light Blue (#87CEEB)
- Intensity: 0.5

Point Lights:
- Awan bercahaya: White Glow
- Kristal: Blue Glow
```

## Waktu & Cuaca

### Day/Night Cycle
```
06:00 - Dawn: Orange-Pink
12:00 - Day: White-Yellow
18:00 - Dusk: Red-Purple
22:00 - Night: Dark Blue
```

### Weather Effects
| Weather | Lighting Change |
|---------|-----------------|
| Rain | -30% intensity, blue tint |
| Snow | +10% brightness, white tint |
| Storm | -50% intensity, dark, lightning |
| Fog | -40% contrast, white overlay |

## Post Processing

### Default
- Bloom: Subtle
- Color Grading: Warm
- Vignette: Light
- Ambient Occlusion: Medium

### Combat
- Bloom: Enhanced
- Color Grading: High contrast
- Vignette: None
- Motion Blur: Subtle

### Cutscene
- Bloom: Cinematic
- Color Grading: Dramatic
- Vignette: Heavy
- Depth of Field: Shallow

## Performance

| Setting | Mobile | Low | Medium | High |
|---------|--------|-----|--------|------|
| Shadow Quality | Off | Low | Medium | High |
| Light Count | 4 | 8 | 16 | 32 |
| GI | Off | Baked | Baked | Realtime |
| Post Process | Off | Basic | Full | Full |

## Referensi

- Genshin Impact — Warna cerah, cel-shaded
- Zelda BOTK — Natural lighting
- Persona 5 — Dramatic lighting
- Final Fantasy XIV — Cinematic lighting
