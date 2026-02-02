# 🦀 KrabWidget

<div align="center">

![KrabWidget Banner](https://img.shields.io/badge/🦀-KrabWidget-orange?style=for-the-badge&labelColor=1a1a2e)

**Your AI companion, always listening**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat-square)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%2014+-blue.svg?style=flat-square)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

*Talk to your AI, it talks back!*

[Features](#-features) • [Installation](#-installation) • [AI Setup](#-ai-backend-setup) • [Easter Eggs](#-easter-eggs) • [Contributing](#-contributing)

</div>

---

## ✨ What is KrabWidget?

KrabWidget is a **voice-first AI assistant** for macOS that lives on your desktop. It's not another boring widget – it's your personal companion that **listens**, **speaks**, and **helps** you throughout your day.

### 🎤 Voice In, Voice Out

```
You: "Hey Krab, tell me a joke"
Krab: "Why don't crabs ever share? Because they're shellfish! 🦀"
```

---

## 🚀 Features

### 🎙️ Voice Commands
- **Always listening mode** with "Hey Krab" wake word
- **Global hotkey** (⌘⌥Space) to toggle listening
- Real-time **waveform visualization** while speaking
- Uses Apple's Speech framework for accurate recognition

### 🔊 Voice Packs (Personalities!)
Choose how Krab talks to you:

| Voice Pack | Personality | Description |
|------------|-------------|-------------|
| 😊 Friendly Krab | Warm & Welcoming | Your buddy who's always happy to help |
| 🎓 Professor Crab | Professional | Sophisticated and knowledgeable |
| 🎉 Pinchy | Playful & Fun | Energetic and ready for adventures! |
| 🌊 Coral | Calm & Soothing | Like gentle ocean waves |
| 🤖 Shell-9000 | Robotic | Beep boop. Very serious AI crab. |

### 🦀 Crab Status Widget (NEW!)
Always-visible status showing what Krab is doing:
- 🔍 "Researching anime recommendations..."
- 📧 "Checking your emails..."
- 🎮 "Found cool gaming news!"
- 😴 "Chilling, waiting for you..."
- 💤 "Zzz... (low energy, tap to wake!)"

Features:
- **Mood indicator** - See Krab's emotional state
- **Energy bar** - Krab gets tired from hard work!
- **Activity history** - Recent tasks
- **Fun idle thoughts** - Krab daydreams when idle

### 📬 Pop-up Notifications
- Dynamic notifications with smooth animations
- News, recommendations, alerts, and tips
- Queue system for multiple notifications
- Auto-dismiss or click to dismiss

### 📱 Telegram Integration
- Receive messages in real-time
- Visual and audio notifications
- Krab reads messages aloud to you
- Beautiful chat bubbles with sender info

### 🪟 Modular Windows
Create your perfect workspace:
- **Chat Window** - Voice chat with Krab + Telegram messages
- **Quick Actions** - Customizable action buttons
- **Command Output** - Mini terminal with crab facts!
- **Custom Info** - Your notes and info panels

All windows are:
- ✅ Draggable
- ✅ Resizable
- ✅ Glassmorphism styled
- ✅ Save/load layouts

### 🎨 Themes
- **Deep Ocean** (Default) - Calm blue depths
- **Coral Reef** - Warm orange tones
- **Midnight** - Dark purple elegance
- **Sunset** - Golden hour vibes

### 🥚 Easter Eggs
Secret surprises hidden throughout the app! Try:
- Clicking the crab many times...
- Saying certain phrases...
- The Konami Code (⬆️⬆️⬇️⬇️⬅️➡️⬅️➡️BA)
- Discovering 13 hidden easter eggs!

---

## 📥 Installation

### Requirements
- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- Microphone permissions

### Build from Source

```bash
# Clone the repository
git clone https://github.com/Sleywill/KrabWidget.git
cd KrabWidget

# Open in Xcode
open KrabWidget.xcodeproj

# Build and run (⌘R)
```

### First Launch
1. Grant microphone permission when prompted
2. Complete the onboarding wizard
3. (Optional) Set up AI backend
4. (Optional) Add your Telegram bot token
5. Start talking to Krab! 🦀

---

## 🤖 AI Backend Setup

KrabWidget can connect to various AI backends for intelligent responses!

### Option 1: 🏠 Ollama (Recommended - Free & Local)

Run AI completely locally on your Mac:

```bash
# Install Ollama
brew install ollama

# Start Ollama service
ollama serve

# Pull a model (in another terminal)
ollama pull llama3.2
```

In KrabWidget: Settings → AI Backend → Ollama
- URL: `http://localhost:11434` (default)
- Model: `llama3.2`

**Pros:** Free, private, no internet required
**Cons:** Uses local CPU/GPU resources

### Option 2: 🔌 OpenClaw

Connect to your existing OpenClaw gateway:

1. Start your OpenClaw gateway
2. In KrabWidget: Settings → AI Backend → OpenClaw
3. Enter your gateway URL (e.g., `http://localhost:3000`)
4. Enter your API token
5. Click Connect

### Option 3: ☁️ OpenAI

Use GPT-4 and other OpenAI models:

1. Get an API key from [platform.openai.com](https://platform.openai.com/api-keys)
2. In KrabWidget: Settings → AI Backend → OpenAI
3. Paste your API key
4. Select model (GPT-4o Mini recommended for speed)

**Pricing:** Pay-per-use, ~$0.001 per message

### Option 4: 🧠 Anthropic Claude

Use Claude models:

1. Get an API key from [console.anthropic.com](https://console.anthropic.com/)
2. In KrabWidget: Settings → AI Backend → Anthropic
3. Paste your API key
4. Select model

### Option 5: 🎨 Custom API

Connect to any OpenAI-compatible endpoint:

1. In KrabWidget: Settings → AI Backend → Custom
2. Enter your API URL
3. Add bearer token if required
4. API should accept: `{"message": "..."}`
5. API should return: `{"response": "..."}`

---

## 📱 Telegram Setup

### Creating a Telegram Bot

1. **Open Telegram** and search for `@BotFather`
2. **Send** `/newbot`
3. **Choose a name** for your bot (e.g., "My Krab Assistant")
4. **Choose a username** (must end in `bot`, e.g., `my_krab_bot`)
5. **Copy the token** BotFather gives you
6. **In KrabWidget:** Settings → Telegram → Paste token → Connect

### Testing Your Bot

1. Search for your bot in Telegram
2. Start a conversation with it
3. Send a message
4. You should see it appear in KrabWidget!

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘⌥Space | Toggle voice listening |
| ⌘, | Open Settings |
| ⌘N | New window |
| ⌘Q | Quit |

---

## 🥚 Easter Eggs

KrabWidget has 13 hidden easter eggs! Here are some hints:

| Easter Egg | Hint |
|------------|------|
| 🎵 Crab Rave | Crabs love to dance! |
| 🌀 Barrel Roll | Try asking Krab to do something acrobatic... |
| 💜 Disco Mode | Remember the 70s? |
| 42 | What's the meaning of life? |
| 🎮 Konami Code | A classic cheat code... |
| 👆 Click Master | Click the crab... a lot |
| ❤️ Crab Love | Express your feelings! |
| ??? | 6 more to discover... |

Track your discoveries in Settings → Easter Eggs!

---

## 🏗️ Architecture

```
KrabWidget/
├── KrabWidgetApp.swift          # App entry point
├── ContentView.swift            # Main view coordinator
├── Models.swift                 # Data models
├── Managers/
│   ├── SpeechManager.swift      # Speech-to-text
│   ├── VoiceManager.swift       # Text-to-speech
│   ├── TelegramManager.swift    # Telegram API
│   ├── AIBackendManager.swift   # AI connections (NEW)
│   ├── NotificationManager.swift # Pop-up system (NEW)
│   ├── CrabStatusManager.swift  # Status widget (NEW)
│   ├── EasterEggManager.swift   # Fun surprises (NEW)
│   ├── ModularWindowManager.swift
│   └── HotkeyManager.swift
├── Views/
│   ├── ChatView.swift
│   ├── OnboardingView.swift
│   ├── SettingsView.swift
│   ├── AIBackendSettingsView.swift (NEW)
│   ├── QuickActionsView.swift
│   ├── CommandOutputView.swift
│   └── VoicePackView.swift
└── Components/
    ├── WaveformView.swift       # Audio visualization
    └── GlassMorphism.swift      # Visual effects
```

---

## 🔒 Privacy

KrabWidget respects your privacy:
- **Local speech processing** via Apple's Speech framework
- **Your conversations** stay on your device
- **AI backends** are your choice - use local Ollama for complete privacy
- **Telegram token** stored locally in UserDefaults
- **No analytics or tracking**

---

## 🤝 Contributing

Contributions are welcome! Ideas for the future:

- [ ] More voice pack options
- [ ] Plugin system for custom commands
- [ ] Calendar integration
- [ ] Reminders & alarms
- [ ] Custom wake words
- [ ] More easter eggs!
- [ ] Localization (more languages)
- [ ] Menu bar mode (hide dock icon)

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## 📄 License

MIT License - feel free to use, modify, and distribute!

---

## 🦀 Credits

Made with ❤️ by [Sleywill](https://github.com/Sleywill)

Special thanks to:
- Apple for SwiftUI and Speech frameworks
- The macOS developer community
- Everyone who discovers all the easter eggs! 🥚

*"Every shell you break through makes you stronger!"* - Krab 🦀

---

<div align="center">

**[⭐ Star this repo](https://github.com/Sleywill/KrabWidget)** if you like it!

🦀 **KrabWidget** - Your AI companion, always listening 🦀

</div>
