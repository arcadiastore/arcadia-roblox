# Cel Shader (Art Bible)

## Ringkasan

Panduan untuk shader cel-shaded yang menjadi ciri khas visual Arcadia Online.

## Cel Shader Overview

### Apa itu Cel-Shading?
Teknik rendering yang membuat objek terlihat seperti kartun/anime dengan:
- Garis outline tebal
- Warna datar (flat shading)
- Sedikit gradasi (1-3 tone)
- Shadow hard-edge

### Mengapa Cel-Shaded?
- Cocok untuk anime style
- Ringan untuk performa
- Mudah di-customize
- Tampilan unik dan konsisten

## Shader Parameters

### Outline
```
Outline Width: 0.5 - 2.0
Outline Color: Black (#000000) atau Dark version of base color
Outline Method: Inverted hull / Post-process
```

### Toon Shading
```
Shadow Steps: 2-3
Shadow Color: Darker version of base color (H-10, S+10, V-30)
Shadow Threshold: 0.4 - 0.6
Highlight: Optional, white, small area
```

### Rim Light
```
Rim Width: 0.5 - 1.5
Rim Color: White atau light version of base color
Rim Threshold: 0.7
```

## Material Setup

### Karakter
```
Base Color: Warna dasar
Shadow Color: Warna bayangan
Outline Color: Warna outline
Specular: Optional, small highlight
Rim Light: Optional
```

### Environment
```
Base Color: Warna terrain
Shadow Color: Warna bayangan
Outline: Tipis atau tidak ada
Detail Texture: Optional
```

### Weapon/Armor
```
Base Color: Metal color
Shadow Color: Dark metal
Specular: Strong highlight
Rim Light: Optional
Emission: Untuk enhancement level
```

## Contoh Warna

### Karakter Warrior
```
Skin: #F5D6B8
Hair: #3A3A3A
Armor: #8C8C8C
Outline: #2A2A2A
Shadow: #6B6B6B
```

### Karakter Mage
```
Skin: #F5D6B8
Hair: #4A90D9
Robe: #6C5CE7
Outline: #2A2A2A
Shadow: #4834B4
```

## Post Processing Stack

```
1. Cel Shader (per object)
2. Outline (per object)
3. Bloom (global)
4. Color Grading (global)
5. Vignette (optional)
```

## Optimasi

| Technique | Fungsi |
|-----------|--------|
| Shader LOD | Shader sederhana untuk objek jauh |
| Outline Culling | Outline hanya untuk objek dekat |
| Shadow Baking | Bayangan statis di-bake |
| Instancing | Material batching |

## Referensi

- **Genshin Impact** — Cel-shaded terbaik di mobile
- **Dragon Quest XI** — Cel-shaded klasik
- **Guilty Gear** — Anime cel-shaded fighting
- **Okami** — Unik cel-shaded style
