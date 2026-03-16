Config = {}
Config.Debug = false
Config.Framework = "rsg-core"
Config.Interaction = "ox_target"

Config.Economy = {
    BaseCost = 1.00
}

Config.Animations = {
    WriteBook = { dict = "amb_work@world_human_write_notebook@male_a@base", anim = "base" },
    ReadBook = { dict = "amb_misc@world_human_reading@book@male_a@base", anim = "base" },
    ClerkIdle = { dict = "amb_work@world_human_clerk@male_a@idle", anim = "idle_a" },
    ClerkStamp = { dict = "amb_work@world_human_clerk@male_a@idle", anim = "idle_b" }
}

Config.Sounds = {
    OpenBook = "book_open.mp3",
    CloseBook = "book_close.mp3",
    PageFlip = "page_flip.mp3",
    Writing = "pen_scratch.mp3",
    Stamp = "stamp_press.mp3",
    Bell = "desk_bell.mp3",
    Coins = "coins.mp3"
}

Config.NPCSchedules = {
    WorkStart = 8,
    BreakStart = 12,
    BreakEnd = 13,
    WorkEnd = 18
}

Config.Locales = {
    ui_ledger_title = "Telegraph Ledger",
    ui_inbox = "Inbox",
    ui_outbox = "Outbox",
    ui_contacts = "Contacts",
    ui_compose = "Compose",
    ui_new_dispatch = "New Dispatch",
    ui_recipient = "Recipient ID:",
    ui_message = "Message:",
    ui_send_btn = "Send Telegraph",
    ui_burn_btn = "Burn",
    ui_empty_state = "Select a dispatch to read,<br>or compose a new one.",
    ui_add_contact_title = "Add Contact",
    ui_contact_name = "Name:",
    ui_contact_id = "Citizen ID:",
    ui_save_btn = "Save",
    ui_fee = "Fee: $1.00",
    
    ui_stamp_approved = "DISPATCHED",
    ui_stamp_no_funds = "INSUFFICIENT FUNDS",
    ui_stamp_not_found = "UNKNOWN RECIPIENT",
    ui_stamp_spam = "WAIT 15 SECONDS",
    
    target_telegram = "Telegraph Services",
    notify_received = "A fresh dispatch just came down the wire for ya.",
    notify_clerk_break = "Clerk's out back smokin'. Hold yer horses.",
    notify_not_found = "Ain't no soul with that identity on the wire, partner.",
    notify_no_funds = "You're a mite short on coin for this dispatch.",
    notify_spam = "You are sending telegrams too fast! Wait a moment."
}

Config.Offices = {
    ["Valentine"] = {
        name = "Valentine Telegraph Office",
        coords = vector4(-177.8434, 628.0618, 114.0896, 270.0),
        npcModel = `U_M_M_ValTownfolk_01`,
        zoneRadius = 2.0,
        active = true
    },
    ["SaintDenis"] = {
        name = "Saint Denis Main Telegraph",
        coords = vector4(2695.5, -1435.6, 45.2, 90.0),
        npcModel = `U_M_M_SDTownfolk_01`,
        zoneRadius = 2.0,
        active = true
    },
    ["Rhodes"] = {
        name = "Rhodes Station Telegraph",
        coords = vector4(1235.1, -1455.3, 72.1, 180.0),
        npcModel = `U_M_M_RhdTownfolk_01`,
        zoneRadius = 2.0,
        active = true
    },
    ["Blackwater"] = {
        name = "Blackwater Express",
        coords = vector4(-765.4, -1266.1, 42.6, 0.0),
        npcModel = `U_M_M_BwtTownfolk_01`,
        zoneRadius = 2.0,
        active = true
    },
    ["Strawberry"] = {
        name = "Strawberry Telegraph",
        coords = vector4(-1805.5, -355.2, 163.5, 45.0),
        npcModel = `U_M_O_StrTownfolk_01`,
        zoneRadius = 2.0,
        active = true
    }
}