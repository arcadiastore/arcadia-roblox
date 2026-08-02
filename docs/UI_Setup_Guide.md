# Level Up UI Setup Guide

## Struktur Hierarchy

```
Canvas
└── LevelUpPanel (Panel) - Stats container
    ├── LevelText (Text)
    ├── EXPBarBG (Image) - Background bar
    │   └── EXPBar (Image) - Fill bar
    ├── EXPText (Text)
    ├── HPBarBG (Image) - Background bar
    │   └── HPBar (Image) - Fill bar
    ├── HPText (Text)
    ├── MPBarBG (Image) - Background bar
    │   └── MPBar (Image) - Fill bar
    └── MPText (Text)
```

---

## Step-by-Step Setup

### 1. Buat LevelUpPanel (Container)

```
Klik Canvas → Klik kanan → UI → Panel → rename "LevelUpPanel"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 10 |
| Pos Y | -10 |
| Width | 200 |
| Height | 120 |
| Anchor | Top-Left |
| Pivot | (0, 1) |

**Image (Background):**
| Property | Value |
|----------|-------|
| Color | (0, 0, 0, 0.7) - Hitam transparan |
| Raycast Target | ☐ Uncheck |

---

### 2. Buat LevelText

```
Klik LevelUpPanel → Klik kanan → UI → Text → rename "LevelText"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 0 |
| Pos Y | 0 |
| Width | 200 |
| Height | 25 |
| Anchor | Top-Stretch |
| Pivot | (0.5, 1) |

**Text:**
| Property | Value |
|----------|-------|
| Text | Lv. 1 |
| Font Size | 18 |
| Font Style | Bold |
| Color | White |
| Alignment | Center |

---

### 3. Buat HP Bar

#### 3a. HPBarBG (Background)
```
Klik LevelUpPanel → Klik kanan → UI → Image → rename "HPBarBG"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 10 |
| Pos Y | -30 |
| Width | 180 |
| Height | 20 |
| Anchor | Top-Left |
| Pivot | (0, 1) |

**Image:**
| Property | Value |
|----------|-------|
| Color | (0.2, 0.2, 0.2, 1) - Abu gelap |

#### 3b. HPBar (Fill)
```
Klik HPBarBG → Klik kanan → UI → Image → rename "HPBar"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 0 |
| Pos Y | 0 |
| Width | 180 |
| Height | 20 |
| Anchor | Stretch-Stretch |
| Left | 0 |
| Right | 0 |
| Top | 0 |
| Bottom | 0 |

**Image:**
| Property | Value |
|----------|-------|
| Color | (0.8, 0.1, 0.1, 1) - Merah |
| Image Type | Filled |
| Fill Method | Horizontal |
| Fill Origin | Left |
| Fill Amount | 1 |

---

### 4. Buat HP Text

```
Klik LevelUpPanel → Klik kanan → UI → Text → rename "HPText"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 10 |
| Pos Y | -30 |
| Width | 180 |
| Height | 20 |
| Anchor | Top-Left |
| Pivot | (0, 1) |

**Text:**
| Property | Value |
|----------|-------|
| Text | 100/100 |
| Font Size | 12 |
| Color | White |
| Alignment | Center |
| Raycast Target | ☐ Uncheck |

---

### 5. Buat MP Bar

#### 5a. MPBarBG (Background)
```
Klik LevelUpPanel → Klik kanan → UI → Image → rename "MPBarBG"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 10 |
| Pos Y | -55 |
| Width | 180 |
| Height | 20 |
| Anchor | Top-Left |
| Pivot | (0, 1) |

**Image:**
| Property | Value |
|----------|-------|
| Color | (0.2, 0.2, 0.2, 1) - Abu gelap |

#### 5b. MPBar (Fill)
```
Klik MPBarBG → Klik kanan → UI → Image → rename "MPBar"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 0 |
| Pos Y | 0 |
| Width | 180 |
| Height | 20 |
| Anchor | Stretch-Stretch |
| Left | 0 |
| Right | 0 |
| Top | 0 |
| Bottom | 0 |

**Image:**
| Property | Value |
|----------|-------|
| Color | (0.1, 0.3, 0.8, 1) - Biru |
| Image Type | Filled |
| Fill Method | Horizontal |
| Fill Origin | Left |
| Fill Amount | 1 |

---

### 6. Buat MP Text

```
Klik LevelUpPanel → Klik kanan → UI → Text → rename "MPText"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 10 |
| Pos Y | -55 |
| Width | 180 |
| Height | 20 |
| Anchor | Top-Left |
| Pivot | (0, 1) |

**Text:**
| Property | Value |
|----------|-------|
| Text | 50/50 |
| Font Size | 12 |
| Color | White |
| Alignment | Center |
| Raycast Target | ☐ Uncheck |

---

### 7. Buat EXP Bar

#### 7a. EXPBarBG (Background)
```
Klik LevelUpPanel → Klik kanan → UI → Image → rename "EXPBarBG"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 10 |
| Pos Y | -80 |
| Width | 180 |
| Height | 15 |
| Anchor | Top-Left |
| Pivot | (0, 1) |

**Image:**
| Property | Value |
|----------|-------|
| Color | (0.2, 0.2, 0.2, 1) - Abu gelap |

#### 7b. EXPBar (Fill)
```
Klik EXPBarBG → Klik kanan → UI → Image → rename "EXPBar"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 0 |
| Pos Y | 0 |
| Width | 180 |
| Height | 15 |
| Anchor | Stretch-Stretch |
| Left | 0 |
| Right | 0 |
| Top | 0 |
| Bottom | 0 |

**Image:**
| Property | Value |
|----------|-------|
| Color | (0.2, 0.8, 0.2, 1) - Hijau |
| Image Type | Filled |
| Fill Method | Horizontal |
| Fill Origin | Left |
| Fill Amount | 0 |

---

### 8. Buat EXP Text

```
Klik LevelUpPanel → Klik kanan → UI → Text → rename "EXPText"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 10 |
| Pos Y | -80 |
| Width | 180 |
| Height | 15 |
| Anchor | Top-Left |
| Pivot | (0, 1) |

**Text:**
| Property | Value |
|----------|-------|
| Text | 0/100 |
| Font Size | 10 |
| Color | White |
| Alignment | Center |
| Raycast Target | ☐ Uncheck |

---

### 9. Buat Level Up Notification

#### 9a. LevelUpNotification (Panel)
```
Klik Canvas → Klik kanan → UI → Panel → rename "LevelUpNotification"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 0 |
| Pos Y | 100 |
| Width | 300 |
| Height | 80 |
| Anchor | Center |
| Pivot | (0.5, 0.5) |

**Image:**
| Property | Value |
|----------|-------|
| Color | (1, 0.8, 0, 0.9) - Gold transparan |
| Raycast Target | ☐ Uncheck |

#### 9b. LevelUpText (Text)
```
Klik LevelUpNotification → Klik kanan → UI → Text → rename "LevelUpText"
```

**RectTransform:**
| Property | Value |
|----------|-------|
| Pos X | 0 |
| Pos Y | 0 |
| Width | 300 |
| Height | 80 |
| Anchor | Stretch-Stretch |
| Left | 0 |
| Right | 0 |
| Top | 0 |
| Bottom | 0 |

**Text:**
| Property | Value |
|----------|-------|
| Text | LEVEL UP! Lv. 2 |
| Font Size | 24 |
| Font Style | Bold |
| Color | Black |
| Alignment | Center |

---

## Final Hierarchy

```
Canvas
├── LevelUpPanel (Panel)
│   ├── LevelText (Text)
│   ├── HPBarBG (Image)
│   │   └── HPBar (Image) - Filled
│   ├── HPText (Text)
│   ├── MPBarBG (Image)
│   │   └── MPBar (Image) - Filled
│   ├── MPText (Text)
│   ├── EXPBarBG (Image)
│   │   └── EXPBar (Image) - Filled
│   └── EXPText (Text)
└── LevelUpNotification (Panel)
    └── LevelUpText (Text)
```

---

## Assign References

Klik GameObject yang punya script **LevelUpUI**:

| Field | Drag dari Hierarchy |
|-------|---------------------|
| Level Text | LevelText |
| Exp Bar | EXPBar |
| Exp Text | EXPText |
| HP Bar | HPBar |
| HP Text | HPText |
| MP Bar | MPBar |
| MP Text | MPText |
| Level Up Panel | LevelUpNotification |
| Level Up Text | LevelUpText |
