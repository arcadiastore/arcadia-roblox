# 19 — Sistem Pet

## Ringkasan

Pet adalah makhluk kecil yang menemani pemain dalam petualangan. Pet memberikan buff pasif dan bisa dilatih untuk menjadi lebih kuat.

## Mendapatkan Pet

| Metode | Contoh |
|--------|--------|
| Quest | Pet quest reward |
| Egg Drop | Monster drop telur |
| Crafting | Craft pet egg |
| Event | Event exclusive pet |
| Shop | Pet shop (cosmetic) |

## Tipe Pet

### 1. Combat Pet
- Ikut bertarung
- Memiliki skill sendiri
- Bisa di-level up

### 2. Support Pet
- Memberikan buff pasif
- Heal, ATK buff, DEF buff
- Tidak ikut bertarung

### 3. Gathering Pet
- Membantu gathering material
- Auto collect resource
- Bonus drop rate

### 4. Cosmetic Pet
- Hanya untuk penampilan
- Tidak ada efek gameplay
- Bisa di-customize

## Pet Stats

```
[Pet Name]
├── Level: 1-50
├── HP: Base HP
├── ATK: Base Attack
├── Skill: 1-3 skill
├── Loyalty: 0-100
├── Hunger: 0-100
└── Evolution: Stage 1-3
```

## Pet Evolution

Pet bisa berevolusi menjadi bentuk lebih kuat:

```
Stage 1: Baby Pet (Lv 1)
  → Feed + Training
Stage 2: Adult Pet (Lv 20)
  → Special Material + Quest
Stage 3: Elder Pet (Lv 40)
  → Rare Material + Boss Drop
```

## Pet Care

### Feeding
- Feed pet secara teratur
- Hunger = 0: pet tidak memberikan buff
- Makanan berbeda = efek berbeda

### Training
- Training meningkatkan stat
- Membutuhkan waktu (1-24 jam)
- Bisa dipercepat dengan item

### Loyalty
- Meningkat dengan feeding & training
- Menurut jika lama tidak diurus
- Loyalty tinggi = buff lebih kuat

## Pet Limit

- Maks 5 pet yang dimiliki
- Maks 1 pet aktif (ikut pemain)
- Pet lain disimpan di Pet House
