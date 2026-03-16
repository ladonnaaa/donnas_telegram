local Translations = {
    ui_ledger_title = "Telegraph Ledger",
    ui_inbox = "Inbox",
    ui_outbox = "Outbox",
    ui_compose = "Compose",
    ui_new_dispatch = "New Dispatch",
    ui_recipient = "Recipient ID:",
    ui_destination = "Destination:",
    ui_priority = "Priority:",
    ui_message = "Message:",
    ui_send_btn = "Send Telegraph",
    ui_burn_btn = "Burn",
    ui_empty_state = "Select a dispatch to read,<br>or compose a new one.",
    ui_standard = "Standard",
    ui_express = "Express",
    ui_stamp_approved = "DISPATCHED",
    ui_stamp_denied = "DENIED",
    ui_stamp_not_found = "NOT FOUND",
    ui_hint_open = "Open Ledger",
    ui_hint_loading = "Dipping pen in ink...",

    target_telegram = "Telegraph Services",

    notify_received = "You have received a new telegram at the office.",
    notify_clerk_break = "The clerk is currently on break. Please return later.",
    notify_clerk_closed = "The telegraph office is closed for the day.",
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})