<p align="center">
  <img src="assets/logo.png" alt="KrabWidget Logo" width="200">
</p>

<h1 align="center">🦀 KrabWidget</h1>
<p align="center"><strong>Your AI companion, always listening</strong></p>
<p align="center"><em>Powered by <a href="https://github.com/openclaw/openclaw">OpenClaw</a></em></p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#setup">Setup</a> •
  <a href="#voice-packs">Voice Packs</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## 🦀 What is KrabWidget?

KrabWidget is a **voice-first AI assistant** for macOS that lives on your desktop. Talk to it, and it talks back! Built on top of [OpenClaw](https://github.com/openclaw/openclaw), the open-source AI agent framework.

**CLACK CLACK!** 🦀

## ✨ Features

### 🎤 Voice Input
- Speech-to-text with "Hey Krab" wake word
- Push-to-talk with global hotkey (⌘⌥Space)
- Visual waveform feedback

### 🔊 Voice Output (Meme Mode!)
Choose your crab personality:
- 🦀 **Meme Krab** - "CLACK CLACK!" "That's claw-some!"
- 💰 **Money Krab** - "Arr arr arr! I like money!"
- 🎵 **Crab Rave** - Party mode activated!
- 😊 **Friendly Krab** - Warm and welcoming
- 🎉 **Pinchy** - Snip snap! Energetic!
- 🤖 **Shell-9000** - Beep boop, crab intelligence

### 💬 Telegram Integration
- Receive messages in real-time
- Beautiful chat bubbles
- Voice note support

### 🖼️ Modular Windows
- Draggable, resizable widget windows
- Chat, commands, quick actions
- Save/load layouts

### 🎨 Beautiful Design
- Glass morphism aesthetic
- Dark mode first
- Smooth animations
- 4 color themes

## 📦 Installation

### Option 1: DMG Installer (Recommended)
```bash
cd KrabWidget
./scripts/create-dmg.sh
```
Then open `dist/KrabWidget-1.0.0.dmg` and drag to Applications.

### Option 2: Build from Source
1. Clone the repo
2. Open `KrabWidget.xcodeproj` in Xcode 15+
3. Build and run (⌘R)

## ⚙️ Setup

### OpenClaw Backend (Recommended)
KrabWidget works best with [OpenClaw](https://github.com/openclaw/openclaw)!

1. Install OpenClaw: `npm install -g openclaw`
2. Start the gateway: `openclaw gateway start`
3. In KrabWidget settings, set API endpoint to your OpenClaw instance

### Telegram Bot
1. Create a bot with [@BotFather](https://t.me/botfather)
2. Copy your bot token
3. Paste in KrabWidget settings

## 🤝 Contributing

PRs welcome! Check out [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

MIT License - feel free to use, modify, and share!

---

<p align="center">
  <strong>Built with 🦀 by the crab community</strong><br>
  <em>Powered by <a href="https://github.com/openclaw/openclaw">OpenClaw</a></em>
</p>
