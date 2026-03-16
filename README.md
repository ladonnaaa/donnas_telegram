
# 📜 Donna's Telegram System for RedM

An advanced, fully immersive Telegram and Postal system for RedM servers using the **RSG Core** framework. It brings a true Western vibe to player communication with custom UI, sound effects, and NPC clerk interactions.

## ✨ Features
* **Custom Western UI:** Beautiful, immersive journal-style UI for reading and writing telegrams.
* **Inbox & Outbox:** Players can easily track sent and received messages.
* **Address Book:** Save your friends' CitizenIDs with custom names for quick sending.
* **NPC Interaction:** Office clerks feature immersive animations (writing, stamping documents) and configured working hours/breaks.
* **Custom Sounds:** Authentic page flipping, pen scratching, coin jingling, and stamp pressing sound effects.
* **Ox Target Integration:** Seamless third-eye target interaction for telegraph offices.
* **Optimized:** Runs at 0.00ms idle on client resmon.

## 📦 Dependencies
* [rsg-core](https://github.com/Rexshack-RedM/rsg-core)
* [ox_target](https://github.com/overextended/ox_target)

## 🛠️ Installation

1. **Download** the latest version from this repository.
2. **Extract** the folder and rename it to `donnas_telegram` (or whatever matches your export setup).
3. **Database:** Run the provided `install.sql` file in your database (using HeidiSQL, phpMyAdmin, etc.).
4. **Server.cfg:** Add the following line to your `server.cfg`:
   ```text
   ensure donnas_telegram

```

5. **Sounds (Optional but highly recommended):** Place the `.mp3` files (page flip, stamp, coins, etc.) into the `html/sounds/` folder to enable the full audio experience.

## ⚙️ Configuration

You can easily add new Telegraph offices, change NPC working hours, adjust telegram sending costs, and modify the target distance inside the `shared/config.lua` file.

## ⚖️ License

This project is licensed under the **GNU GPLv3 License**.

* **You MAY:** Use, modify, and share this script for free.
* **You MUST NOT:** Sell this script, re-upload it behind a paywall, or claim it as your own original work.

*Created with ❤️ by LaDonna*


