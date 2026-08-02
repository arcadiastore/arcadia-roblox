# 33 — Pipeline Konten

## Ringkasan

Pipeline konten mengatur alur kerja dari desain hingga implementasi konten game. Pipeline ini memastikan konsistensi dan efisiensi dalam pengembangan.

## Alur Konten

```
Desain → Review → Asset → Implementasi → Testing → Rilis
```

### 1. Desain
- Penulis membuat dokumen desain
- Detail spesifikasi konten
- Referensi visual & mekanisme

### 2. Review
- Lead designer mereview
- Feedback & revisi
- Approval untuk lanjut

### 3. Asset
- Artist membuat visual
- Audio engineer membuat suara
- Writer membuat teks

### 4. Implementasi
- Programmer mengimplementasikan
- Designer mengatur data
- Integrasi dengan sistem existing

### 5. Testing
- QA testing
- Bug fixing
- Balance testing

### 6. Rilis
- Final review
- Build & deploy
- Monitor feedback

## Jenis Konten

### Karakter
| Tahap | Durasi |
|-------|--------|
| Desain | 2-3 hari |
| Concept Art | 3-5 hari |
| 3D Model | 5-10 hari |
| Animation | 3-7 hari |
| Implementation | 2-3 hari |
| **Total** | **15-28 hari** |

### Dungeon
| Tahap | Durasi |
|-------|--------|
| Desain | 3-5 hari |
| Level Design | 5-7 hari |
| Asset | 7-10 hari |
| Implementation | 3-5 hari |
| Testing | 2-3 hari |
| **Total** | **20-30 hari** |

### Quest
| Tahap | Durasi |
|-------|--------|
| Desain | 1-2 hari |
| Writing | 2-3 hari |
| Implementation | 1-2 hari |
| Testing | 1 hari |
| **Total** | **5-8 hari** |

## Template

### Quest Template
```
[Quest Name]
├── ID: Q###
├── Type: Main / Side / Daily
├── Giver: NPC Name
├── Level: ##
├── Objectives:
│   ├── 1.
│   ├── 2.
│   └── 3.
├── Rewards:
│   ├── EXP:
│   ├── Gold:
│   └── Item:
└── Dialogue:
    ├── Start:
    ├── During:
    └── End:
```

### Monster Template
```
[Monster Name]
├── ID: M###
├── Type: Normal / Elite / Boss
├── Level: ##
├── Element: None / Fire / Water / Wind / Earth / Light / Dark
├── HP: ##
├── ATK: ##
├── DEF: ##
├── Skills:
│   ├── 1.
│   └── 2.
└── Drops:
    ├── Item: ##%
    └── Item: ##%
```

## Tools

| Tool | Fungsi |
|------|--------|
| Unity Editor | Level design & implementation |
| Excel/Sheets | Data management |
| Git | Version control |
| Jira/Trello | Task management |
| Confluence | Dokumentasi |
