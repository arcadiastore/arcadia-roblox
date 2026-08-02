# 28 — Sistem Ekonomi

## Ringkasan

Sistem ekonomi mengatur peredaran gold, harga item, dan perdagangan di dunia Arcadia. Ekonomi dirancang untuk seimbang dan realistis.

## Mata Uang

| Mata Uang | Fungsi | Sumber |
|-----------|--------|--------|
| **Gold** | Mata uang utama | Quest, monster, jual item |
| **Silver** | Mata uang kecil | 100 Silver = 1 Gold |
| **Diamond** | Mata uang premium | Event, achievement |

## Sumber Gold

| Sumber | Jumlah |
|--------|--------|
| Monster drop | 1-100 per monster |
| Quest reward | 100-10000 per quest |
| Jual item | 10-50% harga beli |
| Crafting | Hasil craft dijual |
| Daily quest | 500-2000 per hari |

## Penggunaan Gold

| Kegunaan | Biaya |
|----------|-------|
| Beli item | Harga toko |
| Enhancement | 100-10000 per level |
| Crafting | 50-5000 per craft |
| Job change | 1000-5000 |
| Teleport | 10-100 per teleport |
| Repair | 10-1000 per item |

## Harga Item

### Formula Harga
```
Harga Beli = Base_Price * Rarity_Multiplier * Level_Multiplier
Harga Jual = Harga_Beli * 0.3
```

### Rarity Multiplier
| Rarity | Multiplier |
|--------|-----------|
| Common | 1x |
| Uncommon | 2x |
| Rare | 5x |
| Epic | 15x |
| Legendary | 50x |

## Ekonomi Dinamis

### Supply & Demand
- Harga berfluktuasi berdasarkan jumlah item
- Banyak supply → harga turun
- Sedikit supply → harga naik

### Event Ekonomi
- **Merchant Festival** — Diskon 20% semua toko
- **Black Market** — Item langka dijual
- **Inflation** — Harga naik sementara
- **Deflation** — Harga turun sementara

## Trading (MMORPG)

### Player Trading
- Trade langsung antar pemain
- Trade window dengan konfirmasi
- Anti-scam: item verification

### Auction House
- Jual item ke pemain lain
- Harga ditentukan penjual
- Sistem bidding
- Tax 5% dari harga jual

## Anti-RMT

- Gold cap per hari
- Trade limit per hari
- Suspicious activity detection
- Report system

## Bank

- **Gold Storage:** Simpan gold aman
- **Item Storage:** Simpan item tambahan
- **Shared Storage:** Antar karakter (MMORPG)
- **Fee:** 1% per deposit
