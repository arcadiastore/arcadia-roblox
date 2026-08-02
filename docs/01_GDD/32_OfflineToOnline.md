# 32 — Transisi Offline ke Online

## Ringkasan

Arcadia Online dirancang dengan pendekatan "Offline First". Game dapat dimainkan sepenuhnya secara offline, dengan rencana transformasi menjadi MMORPG di masa depan.

## Arsitektur "Offline First"

### Prinsip
1. **Game penuh tanpa internet** — Semua konten bisa diakses offline
2. **Data lokal** — Semua data disimpan di device
3. **Tidak ada always-online DRM** — Tidak memerlukan koneksi terus-menerus
4. **Cloud opsional** — Cloud save & multiplayer adalah fitur tambahan

### Manfaat
- Pemain bisa bermain di mana saja
- Tidak ada masalah server down
- Tidak ada lag
- Cocok untuk pemain dengan koneksi terbatas

## Fitur Online (MMORPG)

### Multiplayer
- **Co-op Dungeon** — Bermain bersama teman
- **World Boss** — Bersama melawan boss besar
- **PvP** — Arena & open world PvP
- **Guild** — Sistem guild

### Economy
- **Trading** — Tukar item dengan pemain lain
- **Auction House** — Jual beli item
- **Market** — Harga dinamis

### Social
- **Chat** — Global, party, guild, whisper
- **Friend List** — Daftar teman
- **Emote** — Ekspresi karakter

## Data Migration

### Offline → Online
```
1. Pemain membuat akun online
2. Data lokal di-upload ke cloud
3. Validasi data (anti-cheat)
4. Data tersedia di semua device
```

### Conflict Resolution
```
Jika data lokal ≠ data cloud:
1. Tampilkan perbandingan
2. Pemain memilih data mana yang dipakai
3. Data yang tidak dipilih di-backup
```

## Server Architecture (Rencana)

```
[Client] → [Gateway Server] → [Game Server] → [Database]
                ↓
         [Chat Server]
         [Match Server]
         [World Server]
```

## Timeline Transisi

| Fase | Target | Fitur |
|------|--------|-------|
| Alpha Offline | Rilis awal | Game offline penuh |
| Beta Online | +6 bulan | Cloud save, friend list |
| Launch Online | +12 bulan | Multiplayer, trading |
| Expansion | +18 bulan | Guild, PvP, world boss |

## Tantangan

| Tantangan | Solusi |
|-----------|--------|
| Anti-cheat | Server-side validation |
| Data sync | Conflict resolution UI |
| Lag compensation | Client prediction |
| Toxicity | Report & moderation system |
