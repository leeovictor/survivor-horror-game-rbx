# Survivor Horror Game Experiment

A Roblox survival horror game inspired by the iconic mechanics of early 90's horror classics like Resident Evil. This project explores atmospheric tension, resource management, and strategic combat in a modern Roblox environment.

## 🎮 About

This experimental game reimagines the golden age of survival horror for the Roblox platform, featuring:

- **Limited Resources**: Ammunition and healing items are scarce - every shot counts
- **Tank Controls**: Classic fixed-camera movement reminiscent of early Resident Evil games
- **Atmospheric Horror**: Dark environments, limited visibility, and ambient sound design
- **Inventory Management**: Strategic item selection and conservation
- **Environmental Puzzles**: Key items, locked doors, and exploration-based progression
- **Save System**: Limited save points that add tension to exploration

## 🛠️ Tech Stack

- **Language**: Luau
- **Package Manager**: Wally
- **Tooling**: Aftman
- **Build System**: Rojo
- **Dependencies**:
  - Signal library for event handling

## 📁 Project Structure

```
survivor-horror-game-rbx/
├── src/
│   ├── client/          # Client-side scripts
│   ├── server/          # Server-side game logic
│   └── shared/          # Shared utilities and modules
├── Packages/            # External dependencies
├── doc/                 # Documentation
├── images/              # Game assets and imagery
└── default.project.json # Rojo project configuration
```

## 🚀 Getting Started

### Prerequisites

- [Aftman](https://github.com/LPGhatguy/aftman) - Tool manager
- [Rojo](https://rojo.space/) - Roblox project management
- [Wally](https://github.com/UpliftGames/wally) - Package manager

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/survivor-horror-game-rbx.git
   cd survivor-horror-game-rbx
   ```

2. Install tools with Aftman:
   ```bash
   aftman install
   ```

3. Install dependencies with Wally:
   ```bash
   wally install
   ```

4. Build the project with Rojo:
   ```bash
   rojo build -o game.rbxl
   ```

### Development

Start the Rojo development server to sync changes in real-time:

```bash
rojo serve
```

Then connect from Roblox Studio using the Rojo plugin.

## 🎯 Key Features

### Classic Survival Horror Mechanics

- **Fixed Camera Angles**: Pre-rendered backgrounds with strategic camera placement
- **Limited Save Points**: Typewriter-style save stations throughout the game
- **Item Box System**: Shared storage across safe rooms
- **Puzzle-Based Progression**: Environmental challenges requiring key items and observation

### Modern Enhancements

- **Multiplayer Support**: Experience the horror with friends
- **Improved Controls**: Optional modern control scheme alongside classic tank controls
- **Dynamic Lighting**: Real-time lighting for enhanced atmosphere

## 📝 Development Roadmap

- [ ] Core movement and camera systems
- [ ] Inventory and item management
- [ ] Enemy AI and combat mechanics
- [ ] Puzzle system framework
- [ ] Save/load functionality
- [ ] Audio and atmosphere implementation
- [ ] Level design and environments
- [ ] Multiplayer synchronization

## 🤝 Contributing

This is an experimental project, but contributions and suggestions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Inspired by Capcom's Resident Evil series and other survival horror classics
- Built with the amazing Roblox development community tools

---

**Note**: This is an experimental project for educational and entertainment purposes.
