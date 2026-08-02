--[[
    Arcadia Online - Dialogue Data
]]

local Dialogues = {}

Dialogues["Elder"] = {
    npcId = "Elder",
    greeting = {
        text = "Selamat datang di desa kami, pejuang. Ada yang bisa kubantu?",
        responses = {
            {text = "Saya mencari quest.", next = "quest"},
            {text = "Siapa Anda?", next = "about"},
            {text = "Sampai jumpa.", next = nil},
        },
    },
    about = {
        text = "Saya Elder Tetua, kepala desa ini. Kami membutuhkan bantuan untuk mengalahkan monster.",
        responses = {
            {text = "Saya akan membantu!", next = "quest"},
            {text = "Saya akan kembali nanti.", next = nil},
        },
    },
    quest = {
        text = "Bunuh 5 Slime di Training Ground untuk melatih kemampuanmu!",
        questId = "quest_kill_slimes",
        responses = {
            {text = "Saya terima!", next = nil},
            {text = "Nanti saja.", next = nil},
        },
    },
}

Dialogues["Guard"] = {
    npcId = "Guard",
    greeting = {
        text = "Hati-hati di luar desa. Monster semakin berbahaya.",
        responses = {
            {text = "Ada quest untuk saya?", next = "quest"},
            {text = "Terima kasih.", next = nil},
        },
    },
    quest = {
        text = "Bunuh 3 Serigala di Forest Entrance. Mereka mengancam desa!",
        questId = "quest_kill_wolves",
        responses = {
            {text = "Saya terima!", next = nil},
            {text = "Nanti saja.", next = nil},
        },
    },
}

Dialogues["TrainingMaster"] = {
    npcId = "TrainingMaster",
    greeting = {
        text = "Selamat datang, pejuang muda! Saya akan mengajarkanmu dasar-dasar pertarungan.",
        responses = {
            {text = "Apa yang harus saya lakukan?", next = "tutorial"},
            {text = "Terima kasih!", next = nil},
        },
    },
    tutorial = {
        text = "Pergi ke Training Ground dan bunuh Slime. Bicara dengan Elder untuk quest!",
        responses = {
            {text = "Baik, saya akan pergi!", next = nil},
        },
    },
}

Dialogues["Blacksmith"] = {
    npcId = "Blacksmith",
    greeting = {
        text = "Selamat datang di tokoku! Saya menjual senjata terbaik.",
        responses = {
            {text = "Tunjukkan daganganmu.", next = "shop"},
            {text = "Saya hanya melihat-lihat.", next = nil},
        },
    },
    shop = {
        text = "Ini senjata-senjata yang saya jual!",
        openShop = "weapon_shop",
        responses = {
            {text = "Terima kasih!", next = nil},
        },
    },
}

Dialogues["Merchant"] = {
    npcId = "Merchant",
    greeting = {
        text = "Hei, traveler! Mau beli ramuan?",
        responses = {
            {text = "Ya, tunjukkan!", next = "shop"},
            {text = "Tidak, terima kasih.", next = nil},
        },
    },
    shop = {
        text = "Ini ramuan-ramuan yang saya jual!",
        openShop = "general_shop",
        responses = {
            {text = "Terima kasih!", next = nil},
        },
    },
}

Dialogues["JobMaster"] = {
    npcId = "JobMaster",
    greeting = {
        text = "Selamat datang, petualang! Saya adalah Job Master. Kamu bisa memilih job di sini.",
        responses = {
            {text = "Saya mau pilih Job!", next = "select_job"},
            {text = "Apa saja job yang tersedia?", next = "job_info"},
            {text = "Nanti saja", next = nil},
        },
    },
    select_job = {
        text = "Pilih job yang kamu inginkan:",
        responses = {
            {text = "Warrior - Tank/Melee DPS", next = "confirm_warrior"},
            {text = "Mage - Magic DPS/Support", next = "confirm_mage"},
            {text = "Archer - Ranged DPS", next = "confirm_archer"},
            {text = "Kembali", next = "greeting"},
        },
    },
    job_info = {
        text = "3 job awal:\n[W] Warrior - HP & DEF tinggi\n[M] Mage - MATK & MP tinggi\n[A] Archer - SPD & LUK tinggi",
        responses = {
            {text = "Saya mau pilih Job!", next = "select_job"},
            {text = "Nanti saja", next = nil},
        },
    },
    confirm_warrior = {
        text = "Yakin pilih Warrior?\n+50 HP, +5 ATK, +8 DEF, -2 SPD\nSenjata: Sword, Axe, Hammer",
        responses = {
            {text = "Ya, saya pilih Warrior!", action = "select_job", jobId = "Warrior"},
            {text = "Tidak, kembali", next = "select_job"},
        },
    },
    confirm_mage = {
        text = "Yakin pilih Mage?\n+50 MP, +10 MATK, +5 MDEF, -20 HP\nSenjata: Staff, Wand, Orb",
        responses = {
            {text = "Ya, saya pilih Mage!", action = "select_job", jobId = "Mage"},
            {text = "Tidak, kembali", next = "select_job"},
        },
    },
    confirm_archer = {
        text = "Yakin pilih Archer?\n+8 SPD, +5 LUK, +3 ATK\nSenjata: Bow, Crossbow, Dagger",
        responses = {
            {text = "Ya, saya pilih Archer!", action = "select_job", jobId = "Archer"},
            {text = "Tidak, kembali", next = "select_job"},
        },
    },
}

return Dialogues
