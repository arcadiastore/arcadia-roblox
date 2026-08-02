--[[
    Arcadia Online - Dialogue Data
    
    SEMUA data dialogue ada di sini!
    Sesuai GDD 15_Dialogue.md
    
    @author arcadiastore
    @version 3.0.0
]]

local Dialogues = {}

Dialogues["TrainingMaster"] = {
    npcId = "TrainingMaster",
    greeting = {
        text = "Selamat datang, pejuang muda! Saya akan mengajarkanmu dasar-dasar pertarungan.",
        responses = {
            {text = "Apa yang harus saya lakukan?", next = "tutorial"},
            {text = "Saya sudah siap bertarung!", next = "ready"},
        },
    },
    tutorial = {
        text = "Pertama, pergi ke Training Ground dan bunuh 5 Slime. Itu akan melatih kemampuanmu!",
        responses = {
            {text = "Baik, saya akan pergi!", next = nil},
        },
    },
    ready = {
        text = "Bagus! Bicara dengan Elder Tetua untuk mendapatkan quest pertamamu.",
        responses = {
            {text = "Terima kasih!", next = nil},
        },
    },
}

Dialogues["Elder"] = {
    npcId = "Elder",
    greeting = {
        text = "Selamat datang di desa kami, pejuang. Ada yang bisa kubantu?",
        responses = {
            {text = "Saya mencari quest.", next = "quest_menu"},
            {text = "Siapa Anda?", next = "about"},
        },
    },
    about = {
        text = "Saya Elder Tetua, kepala desa ini. Kami membutuhkan bantuan untuk mengalahkan monster-monster yang mengancam desa.",
        responses = {
            {text = "Saya akan membantu!", next = "quest_menu"},
            {text = "Saya akan kembali nanti.", next = nil},
        },
    },
    quest_menu = {
        text = "Baik, saya punya beberapa tugas untukmu. Pilih yang sesuai dengan kemampuanmu.",
        responses = {
            {text = "Bunuh Slime (Level 1)", next = "quest_slime"},
            {text = "Bunuh Babi Hutan (Level 7)", next = "quest_boar"},
            {text = "Kalahkan Guardian (Level 10)", next = "quest_guardian"},
        },
    },
    quest_slime = {
        text = "Bunuh 5 Slime di Training Ground. Ini akan melatih kemampuanmu!",
        questId = "quest_kill_slimes",
        responses = {
            {text = "Saya terima!", next = nil},
            {text = "Terlalu mudah.", next = "quest_menu"},
        },
    },
    quest_boar = {
        text = "Bunuh 5 Babi Hutan di Deep Forest. Mereka sangat berbahaya!",
        questId = "quest_kill_boars",
        responses = {
            {text = "Saya terima!", next = nil},
            {text = "Saya belum siap.", next = "quest_menu"},
        },
    },
    quest_guardian = {
        text = "Kalahkan Guardian of the Forest! Ini adalah tantangan terberat!",
        questId = "quest_kill_guardian",
        responses = {
            {text = "Saya terima!", next = nil},
            {text = "Saya perlu lebih banyak latihan.", next = "quest_menu"},
        },
    },
}

Dialogues["Guard"] = {
    npcId = "Guard",
    greeting = {
        text = "Halt! Siapa yang datang? Oh, pejuang baru. Ada yang bisa kubantu?",
        responses = {
            {text = "Saya mencari quest.", next = "quest"},
            {text = "Apa yang terjadi di hutan?", next = "info"},
        },
    },
    info = {
        text = "Hutan dipenuhi serigala akhir-akhir ini. Mereka semakin berani mendekati desa.",
        responses = {
            {text = "Saya bisa membantu!", next = "quest"},
            {text = "Saya akan berhati-hati.", next = nil},
        },
    },
    quest = {
        text = "Bunuh 3 Serigala di Forest Entrance. Itu akan membantu kami!",
        questId = "quest_kill_wolves",
        responses = {
            {text = "Saya terima!", next = nil},
            {text = "Saya belum siap.", next = nil},
        },
    },
}

Dialogues["Blacksmith"] = {
    npcId = "Blacksmith",
    greeting = {
        text = "Selamat datang di tokoku! Saya menjual senjata terbaik di desa.",
        responses = {
            {text = "Tunjukkan daganganmu.", next = "shop"},
            {text = "Saya hanya melihat-lihat.", next = nil},
        },
    },
    shop = {
        text = "Ini senjata-senjata yang saya jual. Pilih yang sesuai dengan kebutuhanmu!",
        openShop = "weapon_shop",
        responses = {
            {text = "Terima kasih!", next = nil},
        },
    },
}

Dialogues["Merchant"] = {
    npcId = "Merchant",
    greeting = {
        text = "Hei, traveler! Mau beli ramuan? Saya punya stok terbaru!",
        responses = {
            {text = "Ya, tunjukkan!", next = "shop"},
            {text = "Tidak, terima kasih.", next = nil},
        },
    },
    shop = {
        text = "Ini ramuan-ramuan yang saya jual. Sangat berguna untuk petualanganmu!",
        openShop = "general_shop",
        responses = {
            {text = "Terima kasih!", next = nil},
        },
    },
}

return Dialogues
