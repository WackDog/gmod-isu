# ISU – Interrogation & Surveillance Utility

A modular and lore-consistent Combine intelligence system for HL2RP in Garry’s Mod.

Designed to support factional control, persistent dossiers, and immersive interrogation roleplay. Easily extensible and customizable.

## Features

- Persistent per-character dossiers
- Interrogation terminal for logging Q&A sessions
- Combine HUD overlays showing citizen threat flags
- Admin-only flagging and metadata editing tools
- Integrated dossier search and .txt export system
- Full Combine-only access control with team config
- Optional in-world entity placement (Combine Terminal)

---

## 📁 File Structure

```
isu/
├── lua/
│   ├── autorun/
│   │   └── isu_init.lua
│   ├── isu/
│   │   ├── cl_menu.lua
│   │   ├── cl_surveillance.lua
│   │   ├── sh_config.lua
│   │   ├── sv_dossiers.lua
│   │   ├── sv_terminals.lua
│
├── entities/
│   └── ent_isu_terminal/
│       ├── init.lua
│       ├── cl_init.lua
│       └── shared.lua
│
├── data/
│   └── isu/
│       ├── dossiers.json
│       └── logs/
│           └── dossier_history.txt
└── README.md
```

---

## ⚙️ Configuration

Edit `lua/isu/sh_config.lua`:

```lua
ISU_Config.DataPath = "isu/"
ISU_Config.CombineTeams = {
    ["MPF"] = true,
    ["OTA"] = true,
    ["Combine"] = true
}
```

Adjust team access or data storage path as needed. Support for MySQL or external storage is planned.

---

## 🔌 UI Integration

To access the dossier system:

- Use the `ISU Terminal` from the spawnmenu (Entities > ISU)
- Combine players can open dossiers automatically or via interaction
- Includes built-in search, export, and metadata editor

Dossiers include:
- Flag status (color-coded threat)
- Officer logs (with timestamp)
- Metadata (Faction, Location, Comment)

---

## 📚 Available Hooks

| Hook Name                 | Description                                   |
|--------------------------|-----------------------------------------------|
| `ISU_DossierCreated`     | Fired when a new dossier is created           |
| `ISU_FlagChanged`        | Called when a character’s flag is updated     |
| `ISU_InterrogationStarted` | When officer begins interrogation on target |

---

## ✅ Requirements

- Garry’s Mod (x64 strongly recommended)
- Default SQLite database (for persistence)
- DarkRP, Helix, or schema with Combine teams

---

## 🧪 Export & Logs

- Dossier logs are saved to: `data/isu/logs/CHARID.txt`
- Global flag actions recorded in `dossier_history.txt`
- Export via in-game UI → no command required

---

## 🚧 Development Roadmap

Coming soon:

- 🎛️ Cooperation meter during interrogations
- 🔐 Clearance level restrictions for "Classified" dossiers
- 📁 Better UI feedback, animations, and sound integration
- 🗃️ MySQL backend support (optional)
- 🗂️ Dossier grouping, filters, and rank-based exports

---

## 🧑‍💻 Author

- Created by WackDog for immersive roleplay and portfolio development.
- Not for resale or commercial GModStore listing.
