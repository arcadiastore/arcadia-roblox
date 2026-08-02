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

return Dialogues
