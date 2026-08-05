--[[
    Arcadia Online - Item Data
    Sesuai GDD 09_Items.md
    
    Equipment Slots:
    - hat: Topi
    - tshirt: Baju atas
    - pants: Celana
    - shoes: Sepatu
    - ringLeft: Cincin kiri
    - ringRight: Cincin kanan
    - necklace: Kalung
    - weapon1h: Senjata 1 tangan
    - weapon2h: Senjata 2 tangan (tidak bisa pakai shield)
    - wings: Sayap/Tali
    - costume: Kostum (visual only)
]]

local Items = {}

-- ============================================
-- CONSUMABLES
-- ============================================

Items["hp_potion_small"] = {
    id = "hp_potion_small",
    name = "HP Potion (Small)",
    description = "Memulihkan 50 HP",
    type = "consumable",
    price = 50,
    sellPrice = 25,
    stackable = true,
    maxStack = 99,
    effect = {stat = "hp", value = 50},
    icon = "rbxassetid://0", -- placeholder
}

Items["hp_potion_medium"] = {
    id = "hp_potion_medium",
    name = "HP Potion (Medium)",
    description = "Memulihkan 100 HP",
    type = "consumable",
    price = 100,
    sellPrice = 50,
    stackable = true,
    maxStack = 99,
    effect = {stat = "hp", value = 100},
    icon = "rbxassetid://0",
}

Items["mp_potion_small"] = {
    id = "mp_potion_small",
    name = "MP Potion (Small)",
    description = "Memulihkan 30 MP",
    type = "consumable",
    price = 40,
    sellPrice = 20,
    stackable = true,
    maxStack = 99,
    effect = {stat = "mp", value = 30},
    icon = "rbxassetid://0",
}

Items["mp_potion_medium"] = {
    id = "mp_potion_medium",
    name = "MP Potion (Medium)",
    description = "Memulihkan 60 MP",
    type = "consumable",
    price = 80,
    sellPrice = 40,
    stackable = true,
    maxStack = 99,
    effect = {stat = "mp", value = 60},
    icon = "rbxassetid://0",
}

-- ============================================
-- MATERIALS
-- ============================================

Items["slime_gel"] = {
    id = "slime_gel",
    name = "Slime Gel",
    description = "Lendir slime",
    type = "material",
    sellPrice = 5,
    stackable = true,
    maxStack = 99,
    icon = "rbxassetid://0",
}

Items["wolf_fang"] = {
    id = "wolf_fang",
    name = "Wolf Fang",
    description = "Taring serigala",
    type = "material",
    sellPrice = 15,
    stackable = true,
    maxStack = 99,
    icon = "rbxassetid://0",
}

Items["boar_tusk"] = {
    id = "boar_tusk",
    name = "Boar Tusk",
    description = "Gading babi hutan",
    type = "material",
    sellPrice = 25,
    stackable = true,
    maxStack = 99,
    icon = "rbxassetid://0",
}

-- ============================================
-- SPECIAL ITEMS
-- ============================================

Items["job_change_ticket"] = {
    id = "job_change_ticket",
    name = "Job Change Ticket",
    description = "Tiket untuk mengganti job. Bicara dengan Job Master.",
    type = "special",
    sellPrice = 2500,
    stackable = true,
    maxStack = 5,
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - WEAPON (1 Hand)
-- ============================================

-- Helper: bikin visual pedang yang BERBENTUK (gagang + guard + pommel +
-- bilah + ujung runcing) dari beberapa primitive part, bukan 1 kotak polos.
-- Dipakai ulang oleh semua pedang/belati, tinggal beda warna/ukuran per tier.
-- Lihat EquipmentVisuals.lua untuk cara `parts` & `relativeTo` diproses.
local function makeSwordVisual(opts)
    opts = opts or {}
    local bladeColor    = opts.bladeColor or Color3.fromRGB(210, 210, 215)
    local bladeMaterial = opts.bladeMaterial or Enum.Material.Metal
    local hiltColor      = opts.hiltColor or Color3.fromRGB(92, 64, 40)
    local hiltMaterial   = opts.hiltMaterial or Enum.Material.Wood
    local guardColor     = opts.guardColor or Color3.fromRGB(150, 150, 150)
    local scale           = opts.scale or 1

    return {
        attachTo = opts.attachTo or "Right Arm",
        -- Pose genggaman: memutar sumbu pedang (lokal +X, dari gagang ke
        -- ujung bilah) supaya menghadap ke depan-atas seperti dipegang
        -- tangan. Kalau di Studio arahnya masih aneh, ini yang perlu
        -- di-nudge (coba ubah math.rad(100) atau math.rad(-35) sedikit demi
        -- sedikit sambil lihat hasilnya).
        offset = CFrame.new(0.1, -0.05, 0.05) * CFrame.Angles(math.rad(100), 0, math.rad(-35)),
        parts = {
            {
                name = "Handle",
                shape = "Cylinder",
                size = Vector3.new(0.9, 0.24, 0.24) * scale,
                color = hiltColor,
                material = hiltMaterial,
                offset = CFrame.new(),
            },
            {
                name = "Guard",
                shape = "Block",
                relativeTo = "Handle",
                size = Vector3.new(0.16, 0.75, 0.2) * scale,
                color = guardColor,
                material = Enum.Material.Metal,
                offset = CFrame.new(0.53 * scale, 0, 0),
            },
            {
                name = "Pommel",
                shape = "Ball",
                relativeTo = "Handle",
                size = Vector3.new(0.28, 0.28, 0.28) * scale,
                color = hiltColor,
                material = hiltMaterial,
                offset = CFrame.new(-0.48 * scale, 0, 0),
            },
            {
                name = "BladeBody",
                shape = "Block",
                relativeTo = "Handle",
                size = Vector3.new(1.5 * scale, 0.34 * scale, 0.09 * scale),
                color = bladeColor,
                material = bladeMaterial,
                offset = CFrame.new(1.35 * scale, 0, 0),
            },
            {
                -- Wedge = bilah meruncing di ujung (bukan kotak). Kalau
                -- arah lancipnya kebalik di Studio, tambahkan
                -- `* CFrame.Angles(0, 0, math.rad(180))` di offset ini.
                name = "BladeTip",
                shape = "Wedge",
                relativeTo = "BladeBody",
                size = Vector3.new(0.4 * scale, 0.34 * scale, 0.09 * scale),
                color = bladeColor,
                material = bladeMaterial,
                offset = CFrame.new(0.95 * scale, 0, 0) * CFrame.Angles(0, math.rad(180), 0),
            },
        },
    }
end

Items["wooden_sword"] = {
    id = "wooden_sword",
    name = "Wooden Sword",
    description = "Senjata kayu sederhana",
    type = "equipment",
    slot = "weapon1h",
    price = 100,
    sellPrice = 50,
    levelReq = 1,
    jobReq = {"Warrior"},
    stats = {atk = 5},
    range = 8,
    visual = makeSwordVisual({
        bladeColor = Color3.fromRGB(224, 198, 145),
        bladeMaterial = Enum.Material.Wood,
        hiltColor = Color3.fromRGB(92, 64, 40),
        hiltMaterial = Enum.Material.Wood,
        guardColor = Color3.fromRGB(150, 120, 70),
        scale = 1,
    }),
    icon = "rbxassetid://136149295735575",
}

Items["iron_sword"] = {
    id = "iron_sword",
    name = "Iron Sword",
    description = "Senjata besi yang kuat",
    type = "equipment",
    slot = "weapon1h",
    price = 300,
    sellPrice = 150,
    levelReq = 5,
    jobReq = {"Warrior"},
    stats = {atk = 12},
    range = 8,
    visual = makeSwordVisual({
        bladeColor = Color3.fromRGB(180, 180, 180),  -- abu besi
        hiltColor = Color3.fromRGB(70, 55, 40),
        scale = 1.1,
    }),
    icon = "rbxassetid://0",
}

Items["steel_sword"] = {
    id = "steel_sword",
    name = "Steel Sword",
    description = "Pedang baja berkualitas tinggi",
    type = "equipment",
    slot = "weapon1h",
    price = 800,
    sellPrice = 400,
    levelReq = 10,
    jobReq = {"Warrior", "Archer"},
    stats = {atk = 25, spd = 2},
    range = 8,
    visual = makeSwordVisual({
        bladeColor = Color3.fromRGB(200, 210, 220),  -- baja terang
        hiltColor = Color3.fromRGB(50, 50, 55),
        guardColor = Color3.fromRGB(210, 210, 220),
        scale = 1.2,
    }),
    icon = "rbxassetid://0",
}

Items["hunting_dagger"] = {
    id = "hunting_dagger",
    name = "Hunting Dagger",
    description = "Belati berburu yang tajam",
    type = "equipment",
    slot = "weapon1h",
    price = 200,
    sellPrice = 100,
    levelReq = 3,
    jobReq = {"Archer"},
    stats = {atk = 8, spd = 3},
    range = 6,
    visual = makeSwordVisual({
        bladeColor = Color3.fromRGB(160, 160, 170),  -- abu keperakan
        hiltColor = Color3.fromRGB(60, 45, 35),
        scale = 0.65,
    }),
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - WEAPON (2 Hands)
-- ============================================

-- Helper: tongkat sihir (shaft bulat + bola magic di ujung). "orb" tetap
-- pakai mekanisme lama (sub-part terpisah relatif ke part utama), hanya
-- shaft-nya kita jadikan Cylinder (bulat) alih-alih Block (kotak).
local function makeStaffVisual(opts)
    opts = opts or {}
    return {
        attachTo = "Right Arm",
        color = opts.shaftColor or Color3.fromRGB(139, 90, 43),
        material = opts.shaftMaterial or Enum.Material.Wood,
        size = Vector3.new(opts.length or 4, 0.24, 0.24),
        shape = "Cylinder",
        offset = CFrame.new(0.1, 0, 0.05) * CFrame.Angles(0, 0, math.rad(-90)) * CFrame.Angles(math.rad(-15), 0, 0),
        orb = {
            color = opts.orbColor or Color3.fromRGB(80, 150, 255),
            size = opts.orbSize or Vector3.new(0.6, 0.6, 0.6),
            offset = CFrame.new(0, (opts.length or 4) / 2 + 0.1, 0),
        },
    }
end

-- Helper: kapak besar. Handle silinder + mata kapak dibentuk dari 2 Wedge
-- yang saling dicerminkan (depan & belakang) supaya jadi bentuk bilah
-- melebar-meruncing, bukan cuma lempengan kotak.
local function makeAxeVisual(opts)
    opts = opts or {}
    local headColor = opts.headColor or Color3.fromRGB(200, 200, 210)
    return {
        attachTo = "Right Arm",
        offset = CFrame.new(0.15, -0.05, 0.05) * CFrame.Angles(math.rad(95), 0, math.rad(-25)),
        parts = {
            {
                name = "Handle",
                shape = "Cylinder",
                size = Vector3.new(opts.length or 3, 0.28, 0.28),
                color = opts.handleColor or Color3.fromRGB(90, 60, 35),
                material = opts.handleMaterial or Enum.Material.Wood,
                offset = CFrame.new(),
            },
            {
                -- separuh mata kapak menghadap depan
                name = "HeadFront",
                shape = "Wedge",
                relativeTo = "Handle",
                size = Vector3.new(0.9, 1.4, 0.18),
                color = headColor,
                material = Enum.Material.Metal,
                offset = CFrame.new((opts.length or 3) / 2 - 0.1, 0, 0.09)
                    * CFrame.Angles(0, math.rad(90), 0),
            },
            {
                -- separuh mata kapak menghadap belakang (dicerminkan)
                name = "HeadBack",
                shape = "Wedge",
                relativeTo = "Handle",
                size = Vector3.new(0.9, 1.4, 0.18),
                color = headColor,
                material = Enum.Material.Metal,
                offset = CFrame.new((opts.length or 3) / 2 - 0.1, 0, -0.09)
                    * CFrame.Angles(0, math.rad(-90), 0),
            },
        },
    }
end

-- Helper: busur panjang. Didekati dengan 2 "limb" (batang) yang dimiringkan
-- berlawanan arah dari grip supaya membentuk siluet melengkung, plus tali
-- busur tipis. Ini pendekatan sederhana (bukan kurva asli, karena part
-- primitif Roblox tidak bisa melengkung) tapi jauh lebih berbentuk daripada
-- 1 batang lurus.
local function makeBowVisual(opts)
    opts = opts or {}
    local woodColor = opts.color or Color3.fromRGB(139, 90, 43)
    local limbLen = (opts.length or 3.4) / 2
    return {
        attachTo = "Left Arm",
        offset = CFrame.new(0.1, -0.05, 0.05) * CFrame.Angles(0, 0, math.rad(-90)),
        parts = {
            {
                name = "Grip",
                shape = "Cylinder",
                size = Vector3.new(0.6, 0.22, 0.22),
                color = woodColor,
                material = opts.material or Enum.Material.Wood,
                offset = CFrame.new(),
            },
            {
                name = "UpperLimb",
                shape = "Cylinder",
                relativeTo = "Grip",
                size = Vector3.new(limbLen, 0.16, 0.16),
                color = woodColor,
                material = opts.material or Enum.Material.Wood,
                offset = CFrame.new(0, limbLen / 2 + 0.3, 0) * CFrame.Angles(0, 0, math.rad(12)),
            },
            {
                name = "LowerLimb",
                shape = "Cylinder",
                relativeTo = "Grip",
                size = Vector3.new(limbLen, 0.16, 0.16),
                color = woodColor,
                material = opts.material or Enum.Material.Wood,
                offset = CFrame.new(0, -(limbLen / 2 + 0.3), 0) * CFrame.Angles(0, 0, math.rad(-12)),
            },
            {
                name = "String",
                shape = "Cylinder",
                relativeTo = "Grip",
                size = Vector3.new(limbLen * 2 + 0.5, 0.03, 0.03),
                color = Color3.fromRGB(230, 230, 220),
                material = Enum.Material.Neon,
                offset = CFrame.new(0, 0, 0.28) * CFrame.Angles(0, 0, math.rad(90)),
            },
        },
    }
end

Items["wooden_staff"] = {
    id = "wooden_staff",
    name = "Wooden Staff",
    description = "Tongkat kayu sederhana",
    type = "equipment",
    slot = "weapon2h",
    price = 100,
    sellPrice = 50,
    levelReq = 1,
    jobReq = {"Mage"},
    stats = {matk = 8, mp = 10},
    range = 25,
    visual = makeStaffVisual({
        shaftColor = Color3.fromRGB(139, 90, 43),
        orbColor = Color3.fromRGB(80, 150, 255),
        length = 4,
    }),
    icon = "rbxassetid://0",
}

Items["iron_staff"] = {
    id = "iron_staff",
    name = "Iron Staff",
    description = "Tongkat besi dengan kekuatan magic",
    type = "equipment",
    slot = "weapon2h",
    price = 400,
    sellPrice = 200,
    levelReq = 5,
    jobReq = {"Mage"},
    stats = {matk = 18, mp = 25},
    range = 25,
    visual = makeStaffVisual({
        shaftColor = Color3.fromRGB(100, 100, 110),
        shaftMaterial = Enum.Material.Metal,
        orbColor = Color3.fromRGB(150, 50, 255),
        orbSize = Vector3.new(0.7, 0.7, 0.7),
        length = 4.5,
    }),
    icon = "rbxassetid://0",
}

Items["great_axe"] = {
    id = "great_axe",
    name = "Great Axe",
    description = "Kapak besar yang menghancurkan",
    type = "equipment",
    slot = "weapon2h",
    price = 500,
    sellPrice = 250,
    levelReq = 7,
    jobReq = {"Warrior"},
    stats = {atk = 30, def = -3},
    range = 10,
    visual = makeAxeVisual({
        headColor = Color3.fromRGB(200, 200, 210),
        handleColor = Color3.fromRGB(90, 60, 35),
        length = 3.5,
    }),
    icon = "rbxassetid://0",
}

Items["longbow"] = {
    id = "longbow",
    name = "Longbow",
    description = "Busur panjang dengan jangkauan jauh",
    type = "equipment",
    slot = "weapon2h",
    price = 350,
    sellPrice = 175,
    levelReq = 5,
    jobReq = {"Archer"},
    stats = {atk = 15, spd = 5},
    range = 30,
    visual = makeBowVisual({
        color = Color3.fromRGB(139, 90, 43),
        length = 3.4,
    }),
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - HAT
-- ============================================

-- Helper: topi/helm bulat (dome) + brim (pinggiran) tipis, supaya terlihat
-- seperti topi/helm sungguhan di kepala, bukan kotak yang "mengambang".
local function makeCapVisual(opts)
    opts = opts or {}
    return {
        attachTo = "Head",
        offset = CFrame.new(0, opts.height or 0.5, 0),
        parts = {
            {
                name = "Dome",
                shape = "Ball",
                size = opts.domeSize or Vector3.new(2.1, 1.2, 2.1),
                color = opts.color,
                material = opts.material or Enum.Material.SmoothPlastic,
                offset = CFrame.new(),
            },
            {
                name = "Brim",
                shape = "Cylinder",
                relativeTo = "Dome",
                size = opts.brimSize or Vector3.new(0.18, 2.3, 2.3),
                color = opts.brimColor or opts.color,
                material = opts.material or Enum.Material.SmoothPlastic,
                offset = CFrame.new(0, -0.35, 0) * CFrame.Angles(0, 0, math.rad(90)),
            },
        },
    }
end

-- Helper: topi penyihir runcing. Kerucut didekati dengan menumpuk beberapa
-- Cylinder yang mengecil ke atas, plus brim lebar di dasar.
local function makeWizardHatVisual(opts)
    opts = opts or {}
    local color = opts.color or Color3.fromRGB(50, 50, 150)
    return {
        attachTo = "Head",
        offset = CFrame.new(0, 0.9, 0),
        parts = {
            { name = "Brim", shape = "Cylinder", size = Vector3.new(0.15, 2.4, 2.4), color = color, offset = CFrame.new() * CFrame.Angles(0, 0, math.rad(90)) },
            { name = "Base", shape = "Cylinder", relativeTo = "Brim", size = Vector3.new(1.1, 1.4, 1.4), color = color, offset = CFrame.new(0.5, 0, 0) },
            { name = "Mid",  shape = "Cylinder", relativeTo = "Base", size = Vector3.new(0.9, 0.9, 0.9), color = color, offset = CFrame.new(0.85, 0, 0) },
            { name = "Tip",  shape = "Cylinder", relativeTo = "Mid",  size = Vector3.new(0.7, 0.35, 0.35), color = color, offset = CFrame.new(0.7, 0, 0) },
            {
                name = "Band", shape = "Block", relativeTo = "Base",
                size = Vector3.new(0.2, 1.45, 1.45),
                color = opts.bandColor or Color3.fromRGB(200, 180, 50),
                material = Enum.Material.Metal,
                offset = CFrame.new(-0.15, 0, 0),
            },
        },
    }
end

Items["leather_cap"] = {
    id = "leather_cap",
    name = "Leather Cap",
    description = "Topi kulit ringan",
    type = "equipment",
    slot = "hat",
    price = 80,
    sellPrice = 40,
    levelReq = 1,
    stats = {def = 2},
    visual = makeCapVisual({
        color = Color3.fromRGB(139, 90, 43),  -- coklat kulit
        material = Enum.Material.Leather,
        domeSize = Vector3.new(2.1, 1, 2.1),
        brimSize = Vector3.new(0.15, 2.2, 2.2),
        height = 0.5,
    }),
    icon = "rbxassetid://0",
}

Items["iron_helmet"] = {
    id = "iron_helmet",
    name = "Iron Helmet",
    description = "Helm besi pelindung",
    type = "equipment",
    slot = "hat",
    price = 250,
    sellPrice = 125,
    levelReq = 5,
    stats = {def = 5, hp = 10},
    visual = makeCapVisual({
        color = Color3.fromRGB(160, 160, 170),  -- abu besi
        material = Enum.Material.Metal,
        domeSize = Vector3.new(2.3, 1.4, 2.3),
        brimSize = Vector3.new(0.2, 2.4, 2.4),
        height = 0.35,
    }),
    icon = "rbxassetid://0",
}

Items["mage_hat"] = {
    id = "mage_hat",
    name = "Mage Hat",
    description = "Topi penyihir berujung",
    type = "equipment",
    slot = "hat",
    price = 200,
    sellPrice = 100,
    levelReq = 3,
    stats = {matk = 3, mdef = 2},
    visual = makeWizardHatVisual({
        color = Color3.fromRGB(50, 50, 150),  -- biru gelap
        bandColor = Color3.fromRGB(200, 180, 50),  -- emas
    }),
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - TSHIRT (Body Armor)
-- ============================================

-- Helper: badan armor = dada (block, sedikit lebih kecil dari torso biar
-- kelihatan seperti lapisan/plat, bukan kotak identik torso) + 2 pundak
-- (pauldron) bulat opsional di kiri-kanan supaya lebih "berbentuk armor".
local function makeChestVisual(opts)
    opts = opts or {}
    local parts = {
        {
            name = "Chest",
            shape = "Block",
            size = opts.size or Vector3.new(2.5, 2.4, 1.5),
            color = opts.color,
            material = opts.material or Enum.Material.SmoothPlastic,
            offset = opts.chestOffset or CFrame.new(),
        },
    }
    if opts.pauldrons then
        table.insert(parts, {
            name = "PauldronR", shape = "Ball", relativeTo = "Chest",
            size = opts.pauldronSize or Vector3.new(0.9, 0.7, 0.9),
            color = opts.pauldronColor or opts.color,
            material = opts.material or Enum.Material.SmoothPlastic,
            offset = CFrame.new(-1.3, 1, 0),
        })
        table.insert(parts, {
            name = "PauldronL", shape = "Ball", relativeTo = "Chest",
            size = opts.pauldronSize or Vector3.new(0.9, 0.7, 0.9),
            color = opts.pauldronColor or opts.color,
            material = opts.material or Enum.Material.SmoothPlastic,
            offset = CFrame.new(1.3, 1, 0),
        })
    end
    return {
        attachTo = "Torso",
        offset = CFrame.new(),
        parts = parts,
    }
end

-- Helper: jubah/robe kain -- badan lebih ramping + "kain" yang menjuntai ke
-- bawah (block tipis panjang di belakang/bawah torso) supaya kelihatan
-- seperti jubah, bukan baju kotak biasa.
local function makeRobeVisual(opts)
    opts = opts or {}
    return {
        attachTo = "Torso",
        parts = {
            {
                name = "Chest",
                shape = "Block",
                size = opts.chestSize or Vector3.new(2.3, 1.8, 1.4),
                color = opts.color,
                material = Enum.Material.Fabric,
                offset = CFrame.new(0, 0.4, 0),
            },
            {
                -- bagian bawah jubah yang menjuntai
                name = "Skirt",
                shape = "Block",
                relativeTo = "Chest",
                size = opts.skirtSize or Vector3.new(2.1, 2, 1.3),
                color = opts.skirtColor or opts.color,
                material = Enum.Material.Fabric,
                offset = CFrame.new(0, -1.7, 0.05),
            },
        },
    }
end

Items["leather_armor"] = {
    id = "leather_armor",
    name = "Leather Armor",
    description = "Armor kulit ringan",
    type = "equipment",
    slot = "tshirt",
    price = 150,
    sellPrice = 75,
    levelReq = 1,
    stats = {def = 5},
    visual = {
        -- Top/Jacket free dari Roblox
        -- Top: rbxassetid://9240752338 (Tie-Front Top - White)
        -- Jacket: rbxassetid://7192549218 (Leather Jacket - Black)
        shirtTemplate = "rbxassetid://7192549218",  -- Leather Jacket - cocok untuk armor!
        attachTo = "Torso",
        fullBody = true,
        color = Color3.fromRGB(120, 75, 30),  -- fallback color
    },
    icon = "rbxassetid://0",
}

Items["iron_chestplate"] = {
    id = "iron_chestplate",
    name = "Iron Chestplate",
    description = "Dada besi yang kuat",
    type = "equipment",
    slot = "tshirt",
    price = 500,
    sellPrice = 250,
    levelReq = 7,
    stats = {def = 12, hp = 20},
    visual = {
        shirtTemplate = "rbxassetid://9240757332",  -- Knit Sweater - Black (mirip armor)
        attachTo = "Torso",
        fullBody = true,
        color = Color3.fromRGB(140, 140, 150),
    },
    icon = "rbxassetid://0",
}

Items["cloth_robe"] = {
    id = "cloth_robe",
    name = "Cloth Robe",
    description = "Jubah kain penyihir",
    type = "equipment",
    slot = "tshirt",
    price = 200,
    sellPrice = 100,
    levelReq = 3,
    stats = {def = 2, matk = 3, mp = 15},
    visual = {
        shirtTemplate = "rbxassetid://8648380153",  -- Trench Coat - White (cocok untuk robe!)
        attachTo = "Torso",
        fullBody = true,
        color = Color3.fromRGB(40, 40, 120),
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - PANTS
-- ============================================

-- Helper: celana = pinggang (block) + 2 paha (cylinder tegak, kiri-kanan)
-- supaya kelihatan seperti 2 kaki bercelana, bukan 1 kotak utuh.
local function makePantsVisual(opts)
    opts = opts or {}
    return {
        attachTo = "Torso",
        parts = {
            {
                name = "Waist", shape = "Block",
                size = opts.waistSize or Vector3.new(2.2, 0.7, 1.3),
                color = opts.color, material = opts.material or Enum.Material.SmoothPlastic,
                offset = CFrame.new(0, -0.8, 0),
            },
            {
                name = "LegR", shape = "Cylinder", relativeTo = "Waist",
                size = opts.legSize or Vector3.new(1.6, 0.65, 0.65),
                color = opts.color, material = opts.material or Enum.Material.SmoothPlastic,
                offset = CFrame.new(-0.55, -0.7, 0) * CFrame.Angles(0, 0, math.rad(90)),
            },
            {
                name = "LegL", shape = "Cylinder", relativeTo = "Waist",
                size = opts.legSize or Vector3.new(1.6, 0.65, 0.65),
                color = opts.color, material = opts.material or Enum.Material.SmoothPlastic,
                offset = CFrame.new(0.55, -0.7, 0) * CFrame.Angles(0, 0, math.rad(90)),
            },
        },
    }
end

Items["leather_pants"] = {
    id = "leather_pants",
    name = "Leather Pants",
    description = "Celana kulit",
    type = "equipment",
    slot = "pants",
    price = 100,
    sellPrice = 50,
    levelReq = 1,
    stats = {def = 3},
    visual = {
        pantsTemplate = "rbxassetid://6984763785",  -- Casual Sweats - Black
        attachTo = "Torso",
        color = Color3.fromRGB(100, 65, 25),
    },
    icon = "rbxassetid://0",
}

Items["iron_leggings"] = {
    id = "iron_leggings",
    name = "Iron Leggings",
    description = "Legging besi pelindung",
    type = "equipment",
    slot = "pants",
    price = 300,
    sellPrice = 150,
    levelReq = 5,
    stats = {def = 6, spd = -1},
    visual = {
        pantsTemplate = "rbxassetid://6984740059",  -- Cargo Pants - Brown
        attachTo = "Torso",
        color = Color3.fromRGB(130, 130, 140),
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - SHOES
-- ============================================

-- Helper: sepatu = sol (block rata) + ujung sepatu meruncing (wedge) +
-- manset pergelangan (cylinder) supaya berbentuk sepatu, bukan kotak.
-- `mirror = true` otomatis membangun ulang set part yang sama persis di
-- kaki sebelahnya (lihat EquipmentVisuals.lua, sudah mendukung composite).
local function makeBootVisual(opts, side)
    opts = opts or {}
    return {
        attachTo = side == "Right" and "Right Leg" or "Left Leg",
        mirror = true,  -- otomatis dibuatkan juga di kaki sebelahnya
        parts = {
            {
                name = "Sole", shape = "Block",
                size = opts.soleSize or Vector3.new(1, 0.35, 1.4),
                color = opts.soleColor or Color3.fromRGB(40, 30, 25),
                material = Enum.Material.SmoothPlastic,
                offset = CFrame.new(0, -1, 0.1),
            },
            {
                name = "Cuff", shape = "Cylinder", relativeTo = "Sole",
                size = opts.cuffSize or Vector3.new(0.6, 0.85, 0.85),
                color = opts.color, material = opts.material or Enum.Material.SmoothPlastic,
                offset = CFrame.new(0, 0.5, -0.3) * CFrame.Angles(0, 0, math.rad(90)),
            },
            {
                name = "Toe", shape = "Wedge", relativeTo = "Sole",
                size = opts.toeSize or Vector3.new(0.55, 0.3, 1),
                color = opts.color, material = opts.material or Enum.Material.SmoothPlastic,
                offset = CFrame.new(0, 0.16, 0.75) * CFrame.Angles(0, math.rad(90), 0),
            },
        },
    }
end

Items["leather_boots"] = {
    id = "leather_boots",
    name = "Leather Boots",
    description = "Sepatu kulit nyaman",
    type = "equipment",
    slot = "shoes",
    price = 80,
    sellPrice = 40,
    levelReq = 1,
    stats = {def = 1, spd = 2},
    visual = makeBootVisual({
        color = Color3.fromRGB(90, 55, 20),  -- coklat gelap
        material = Enum.Material.Leather,
    }, "Left"),
    icon = "rbxassetid://0",
}

Items["iron_boots"] = {
    id = "iron_boots",
    name = "Iron Boots",
    description = "Sepatu besi berat",
    type = "equipment",
    slot = "shoes",
    price = 200,
    sellPrice = 100,
    levelReq = 5,
    stats = {def = 4, spd = -1},
    visual = makeBootVisual({
        color = Color3.fromRGB(130, 130, 140),  -- abu besi
        material = Enum.Material.Metal,
        soleColor = Color3.fromRGB(60, 60, 65),
        cuffSize = Vector3.new(0.7, 0.95, 0.95),
    }, "Left"),
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - RINGS
-- ============================================

-- Helper: cincin = band pipih (Cylinder tipis lebar) di jari, jauh lebih
-- terlihat seperti "cincin" daripada kotak kecil.
local function makeRingVisual(opts)
    opts = opts or {}
    return {
        attachTo = "Right Arm",
        offset = CFrame.new(0, -0.15, 0) * CFrame.Angles(0, 0, math.rad(90)),
        parts = {
            {
                name = "Band",
                shape = "Cylinder",
                size = Vector3.new(0.14, 0.45, 0.45),
                color = opts.color,
                material = opts.material or Enum.Material.Metal,
                offset = CFrame.new(),
            },
        },
    }
end

Items["copper_ring"] = {
    id = "copper_ring",
    name = "Copper Ring",
    description = "Cincin tembaga sederhana",
    type = "equipment",
    slot = "ring",
    price = 50,
    sellPrice = 25,
    levelReq = 1,
    stats = {atk = 1, def = 1},
    visual = makeRingVisual({
        color = Color3.fromRGB(180, 120, 50),  -- tembaga
    }),
    icon = "rbxassetid://0",
}

Items["silver_ring"] = {
    id = "silver_ring",
    name = "Silver Ring",
    description = "Cincin perak berkilau",
    type = "equipment",
    slot = "ring",
    price = 200,
    sellPrice = 100,
    levelReq = 5,
    stats = {atk = 3, def = 2, luk = 2},
    visual = makeRingVisual({
        color = Color3.fromRGB(200, 200, 210),  -- perak
    }),
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - NECKLACE
-- ============================================

-- Helper: kalung = rantai tipis melingkar leher (cylinder pipih) + liontin
-- (Ball) yang menggantung di depan dada.
local function makeNecklaceVisual(opts)
    opts = opts or {}
    return {
        attachTo = "Torso",
        offset = CFrame.new(0, 1.2, -0.75),
        parts = {
            {
                name = "Chain",
                shape = "Cylinder",
                size = Vector3.new(0.06, 1.1, 1.1),
                color = opts.chainColor or Color3.fromRGB(200, 200, 210),
                material = Enum.Material.Metal,
                offset = CFrame.new(0, 0.3, 0.1) * CFrame.Angles(0, 0, math.rad(90)),
            },
            {
                name = "Gem",
                shape = "Ball",
                relativeTo = "Chain",
                size = opts.gemSize or Vector3.new(0.35, 0.35, 0.25),
                color = opts.color,
                material = opts.material or Enum.Material.Neon,
                offset = CFrame.new(0, -0.65, 0.05),
            },
        },
    }
end

Items["wooden_pendant"] = {
    id = "wooden_pendant",
    name = "Wooden Pendant",
    description = "Liontin kayu pelindung",
    type = "equipment",
    slot = "necklace",
    price = 60,
    sellPrice = 30,
    levelReq = 1,
    stats = {mdef = 3, hp = 5},
    visual = makeNecklaceVisual({
        color = Color3.fromRGB(139, 90, 43),  -- coklat kayu
        material = Enum.Material.Wood,
        chainColor = Color3.fromRGB(120, 100, 70),
    }),
    icon = "rbxassetid://0",
}

Items["silver_necklace"] = {
    id = "silver_necklace",
    name = "Silver Necklace",
    description = "Kalung perak berkilau",
    type = "equipment",
    slot = "necklace",
    price = 300,
    sellPrice = 150,
    levelReq = 5,
    stats = {mdef = 5, hp = 15, mp = 10},
    visual = makeNecklaceVisual({
        color = Color3.fromRGB(120, 200, 255),  -- gem biru muda
        chainColor = Color3.fromRGB(200, 200, 210),
        gemSize = Vector3.new(0.4, 0.4, 0.3),
    }),
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - WINGS/ROPE
-- ============================================

-- Helper: sayap = 3 "bulu" (Wedge meruncing) per sisi yang disusun mengipas
-- dari punggung, kiri & kanan, jauh lebih berbentuk sayap daripada 1 papan
-- datar.
local function makeWingsVisual(opts)
    opts = opts or {}
    local color = opts.color or Color3.fromRGB(255, 255, 255)
    local parts = {}
    local featherAngles = {-20, 0, 20}  -- kipas 3 bulu per sisi
    for i, ang in ipairs(featherAngles) do
        table.insert(parts, {
            name = "FeatherR" .. i,
            shape = "Wedge",
            size = opts.featherSize or Vector3.new(1.6, 0.15, 1.1),
            color = color,
            material = opts.material or Enum.Material.SmoothPlastic,
            offset = CFrame.new(-0.3, 0.3, 0.3)
                * CFrame.Angles(0, math.rad(180 + ang), math.rad(-90)),
        })
        table.insert(parts, {
            name = "FeatherL" .. i,
            shape = "Wedge",
            size = opts.featherSize or Vector3.new(1.6, 0.15, 1.1),
            color = color,
            material = opts.material or Enum.Material.SmoothPlastic,
            offset = CFrame.new(0.3, 0.3, 0.3)
                * CFrame.Angles(0, math.rad(-ang), math.rad(90)),
        })
    end
    return {
        attachTo = "Torso",
        offset = CFrame.new(0, 0.3, 0.9),
        parts = parts,
    }
end

Items["basic_wings"] = {
    id = "basic_wings",
    name = "Basic Wings",
    description = "Sayap sederhana untuk terbang rendah",
    type = "equipment",
    slot = "wings",
    price = 500,
    sellPrice = 250,
    levelReq = 10,
    stats = {spd = 10},
    visual = makeWingsVisual({
        color = Color3.fromRGB(255, 255, 255),  -- putih
    }),
    icon = "rbxassetid://0",
}

Items["rope_climbing"] = {
    id = "rope_climbing",
    name = "Climbing Rope",
    description = "Tali panjat untuk area tinggi",
    type = "equipment",
    slot = "wings",
    price = 200,
    sellPrice = 100,
    levelReq = 3,
    stats = {spd = 3, def = 1},
    visual = {
        color = Color3.fromRGB(180, 150, 100),  -- coklat tali
        size = Vector3.new(2, 0.22, 0.22),  -- tali bulat, bukan kotak
        shape = "Cylinder",
        offset = CFrame.new(0, 0, 1) * CFrame.Angles(0, 0, math.rad(90)),
        attachTo = "Torso",
    },
    icon = "rbxassetid://0",
}

-- ============================================
-- EQUIPMENT - COSTUME (Visual only)
-- ============================================

-- Helper: kostum full-body + jubah/cape tipis di punggung supaya tidak
-- terasa cuma "recolor kotak" tapi ada elemen kostum yang jelas kelihatan.
local function makeCostumeVisual(opts)
    opts = opts or {}
    return {
        attachTo = "Torso",
        fullBody = true,  -- tetap ganti warna seluruh tubuh
        color = opts.color,
        parts = {
            {
                name = "Overlay",
                shape = "Block",
                size = opts.overlaySize or Vector3.new(2.4, 3.2, 1.4),
                color = opts.color,
                material = opts.material or Enum.Material.SmoothPlastic,
                offset = CFrame.new(0, -0.5, 0),
            },
            {
                -- jubah menjuntai di punggung
                name = "Cape",
                shape = "Block",
                relativeTo = "Overlay",
                size = opts.capeSize or Vector3.new(2, 2.6, 0.15),
                color = opts.capeColor or opts.color,
                material = opts.material or Enum.Material.SmoothPlastic,
                offset = CFrame.new(0, -0.9, 0.85) * CFrame.Angles(math.rad(8), 0, 0),
            },
        },
    }
end

Items["costume_ninja"] = {
    id = "costume_ninja",
    name = "Ninja Costume",
    description = "Kostum ninja hitam",
    type = "equipment",
    slot = "costume",
    price = 1000,
    sellPrice = 500,
    levelReq = 1,
    stats = {},
    visual = makeCostumeVisual({
        color = Color3.fromRGB(30, 30, 30),  -- hitam
        capeColor = Color3.fromRGB(15, 15, 15),
        capeSize = Vector3.new(1.8, 2.2, 0.1),  -- jubah ninja lebih ramping
    }),
    icon = "rbxassetid://0",
}

Items["costume_knight"] = {
    id = "costume_knight",
    name = "Knight Costume",
    description = "Kostum ksatria kerajaan",
    type = "equipment",
    slot = "costume",
    price = 1000,
    sellPrice = 500,
    levelReq = 1,
    stats = {},
    visual = makeCostumeVisual({
        color = Color3.fromRGB(180, 170, 140),  -- emas pucat
        capeColor = Color3.fromRGB(140, 20, 20),  -- merah kerajaan
    }),
    icon = "rbxassetid://0",
}

return Items
