# CSG — Combine Surveillance Grid

A modular, lore-friendly surveillance camera network for HL2RP servers in Garry’s Mod.

Empowers Combine units to deploy, monitor, and manage a persistent grid of cameras with a polished in-game terminal UI.

## Features

- Placeable, spawnable surveillance cameras  
- In-world Combine terminal with tabbed, Combine-themed UI  
- Live feed viewing via `CalcView`, exit with ESC  
- Rename cameras on-the-fly, persisted to JSON  
- Ping cameras for alerts, logged with timestamps  
- Full view/ping logs in “Logs” tab  
- Automatic cleanup: remove cameras from registry on deletion  

---

## 📁 File Structure

```
csg/
├── lua/
│   ├── autorun/
│   │   └── csg_init.lua
│   ├── csg/
│   │   ├── sh_config.lua
│   │   ├── sv_cameras.lua
│   │   └── cl_viewer.lua
├── entities/
│   ├── ent_csg_camera/
│   │   ├── shared.lua
│   │   ├── init.lua
│   │   └── cl_init.lua
│   └── ent_csg_terminal/
│       ├── shared.lua
│       ├── init.lua
│       └── cl_init.lua
├── data/
│   └── csg/
│       ├── cameras.json
│       └── logs/
│           └── camera_pings.txt
└── README.md
```

---

## ⚙️ Configuration

Edit `lua/csg/sh_config.lua`:

```lua
CSG_Config.DataPath = "csg/"
CSG_Config.CombineTeams = {
    ["MPF"]     = true,
    ["OTA"]     = true,
    ["Combine"] = true
}
CSG_Config.MaxCamerasPerUnit = 5
```

Adjust team access, storage path, or per-unit camera limits.

---

## 🔌 UI Integration

- Spawn the **Surveillance Terminal** from the spawnmenu under `Entities > Combine Surveillance`.  
- Use the terminal to open the camera management UI.  
- **Tabs**:
  - **Cameras**: View, ping, rename cameras  
  - **Logs**: Scrollable history of views & pings  

While viewing a camera, press **RMB** or **ESC** to exit.

---

## 📚 Available Hooks

| Hook Name                   | Description                                      |
|-----------------------------|--------------------------------------------------|
| `CSG_LogCameraViewed`       | Fired when a player views a camera feed          |
| `CSG_PingCamera`            | Fired when a player pings a camera               |
| `CSG_RequestCameraList`     | Trigger terminal UI to request current registry  |

---

## ✅ Requirements

- Garry’s Mod (x64 recommended)  
- Default SQLite/JSON data storage  
- HL2RP schema or gamemode with Combine teams  

---

## 🧪 Logs & Persistence

- All camera metadata is saved to `data/csg/cameras.json`.  
- View and ping logs append to `data/csg/logs/camera_pings.txt`.  
- Cameras remove themselves from the registry when deleted.

---

## 🚧 Development Roadmap

Coming soon:

- 🔐 **Clearance Levels**: Restrict certain cameras to senior ranks  
- 🤖 **Motion Detection**: Auto-ping on detected movement  
- 🗂️ **Sector Tags**: Assign sectors to cameras for filtering  
- 🗃️ **MySQL Backend**: Cross-server persistence option  
- 🔊 **Audio/SFX**: Combine beeps, alerts, and scanline effects  

---

## 🧑‍💻 Author

- Created by WackDog for immersive HL2RP surveillance systems.  
- Not for resale or GModStore distribution.  