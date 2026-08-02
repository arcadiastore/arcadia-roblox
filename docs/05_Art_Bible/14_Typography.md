# Tipografi (Typography)

## Ringkasan

Panduan penggunaan font dan teks dalam game.

## Font Selection

### Primary Font
- **Nama:** TBD (Noto Sans / Source Han Sans)
- **Gaya:** Clean, modern, readable
- **Support:** Latin, CJK (Indonesia, Jepang, Cina)

### Secondary Font
- **Nama:** TBD (Fantasy font)
- **Gaya:** Decorative, stylized
- **Penggunaan:** Title, logo, special text

### Monospace Font
- **Nama:** TBD (JetBrains Mono)
- **Gaya:** Monospace
- **Penggunaan:** Code, stats, numbers

## Font Sizes

| Level | Size | Weight | Usage |
|-------|------|--------|-------|
| H1 | 48px | Bold | Title, logo |
| H2 | 36px | Bold | Section title |
| H3 | 28px | Bold | Subsection |
| H4 | 24px | Bold | Heading |
| Body Large | 20px | Regular | Dialog, description |
| Body | 16px | Regular | Normal text |
| Small | 14px | Light | Caption, label |
| Tiny | 12px | Light | Tooltip, hint |

## Line Height

| Type | Line Height |
|------|-------------|
| Title | 1.2 |
| Heading | 1.3 |
| Body | 1.5 |
| Dialog | 1.6 |

## Text Colors

| Type | Color | Hex |
|------|-------|-----|
| Normal | White | #FFFFFF |
| Highlight | Yellow | #FFD700 |
| Link | Blue | #4A90D9 |
| Error | Red | #FF4444 |
| Success | Green | #44FF44 |
| Disabled | Grey | #888888 |

## Dialog Text

### Speed
- Normal: 30 characters per second
- Fast: 60 characters per second
- Instant: Immediate

### Style
```
Normal: "Ini adalah dialog biasa."
Emphasis: "Ini <b>sangat</b> penting!"
Shout: "AWAS!"
Whisper: "Bisikan lembut..."
Thought: "(Aku harus hati-hati...)"
```

### Formatting
- **Bold:** Untuk penekanan
- *Italic:* Untuk pikiran, nama item
- [Color] Teks [/Color]: Untuk warna khusus

## Number Formatting

| Type | Format | Contoh |
|------|--------|--------|
| Gold | Comma separator | 1,234,567 |
| Damage | Bold, color | **1234** (merah) |
| Heal | Bold, color | **567** (hijau) |
| Percentage | With symbol | 75% |
| Time | HH:MM:SS | 01:23:45 |

## Localization Notes

### Bahasa Indonesia
- Gunakan ejaan yang benar
- Singkatan: tidak umum
- Angka: titik sebagai pemisah ribuan

### English
- American English
- Singkatan: OK untuk UI
- Angka: comma sebagai pemisah

### Japanese
- Formal: です/ます
- Casual: だ/である
- Kanji: Joyo kanji

## Accessibility

- **Font size:** Bisa diubah (75% - 150%)
- **Contrast:** Minimal 4.5:1 ratio
- **Line spacing:** Bisa diatur
- **Font style:** Option untuk dyslexia-friendly
