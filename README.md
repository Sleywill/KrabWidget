# 🦀 KrabWidget

<div align="center">

![KrabWidget Banner](https://img.shields.io/badge/🦀-KrabWidget-orange?style=for-the-badge&labelColor=1a1a2e)

**Your AI companion, always listening**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat-square)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%2014+-blue.svg?style=flat-square)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

*Talk to your AI, it talks back!*

</div>

---

## ✨ What is KrabWidget?

KrabWidget is a **voice-first AI assistant** for macOS that lives on your desktop. It's not another boring widget – it's your personal companion that **listens**, **speaks**, and **helps** you throughout your day.

### 🎤 Voice In, Voice Out

```
You: "Hey Krab, tell me a joke"
Krab: "Why don't crabs ever share? Because they're shellfish! 🦀"
```

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

## 📸 Screenshots

<div align="center">

### Onboarding
*Krab greets you with voice and helps set everything up!*

### Chat Window
*Beautiful glassmorphism design with voice waveform*

### Quick Actions
*Customizable action grid for common tasks*

### Voice Pack Selection
*Preview different personalities before choosing*

</div>

## 🛠️ Installation

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
3. (Optional) Add your Telegram bot token
4. Start talking to Krab! 🦀

## ⚙️ Configuration

### Telegram Bot Setup
1. Open Telegram, search for `@BotFather`
2. Send `/newbot` and follow instructions
3. Copy the bot token
4. Paste in KrabWidget Settings → Telegram

### Hotkey Customization
Default: `⌘⌥Space`

Available presets:
- ⌘⌥Space
- ⌘⇧K
- ⌘⌥L
- ⌘⌃Return

### Wake Word
Default: "Hey Krab"

You can customize this in Settings → Voice → Wake Word

## 🎯 Voice Commands

Built-in commands Krab understands:

| Say | Krab does |
|-----|-----------|
| "What time is it?" | Tells current time |
| "Tell me a joke" | Crab jokes! 🦀 |
| "Motivate me" | Inspirational crab wisdom |
| "Hello/Hi/Hey" | Friendly greeting |

## 🏗️ Architecture

```
KrabWidget/
├── KrabWidgetApp.swift      # App entry point
├── ContentView.swift        # Main view coordinator
├── Models.swift             # Data models
├── Managers/
│   ├── SpeechManager.swift      # Speech-to-text
│   ├── VoiceManager.swift       # Text-to-speech
│   ├── TelegramManager.swift    # Telegram API
│   ├── ModularWindowManager.swift
│   └── HotkeyManager.swift      # Global hotkeys
├── Views/
│   ├── ChatView.swift
│   ├── OnboardingView.swift
│   ├── SettingsView.swift
│   ├── QuickActionsView.swift
│   ├── CommandOutputView.swift
│   └── VoicePackView.swift
└── Components/
    ├── WaveformView.swift       # Audio visualization
    └── GlassMorphism.swift      # Visual effects
```

## 🔒 Privacy

KrabWidget respects your privacy:
- **No data sent to servers** (except Telegram if configured)
- **Speech processing** happens locally via Apple's Speech framework
- **Your conversations** stay on your device
- **Telegram token** stored locally in UserDefaults

## 🤝 Contributing

Contributions welcome! Ideas for the future:
- [ ] More voice pack options
- [ ] OpenAI/Claude integration for smarter responses
- [ ] Calendar integration
- [ ] Reminders
- [ ] Custom wake words
- [ ] Plugin system

## 📄 License

MIT License - feel free to use, modify, and distribute!

## 🦀 Credits

Made with ❤️ by [Sleywill](https://github.com/Sleywill)

*"Every shell you break through makes you stronger!"* - Krab 🦀

---

<div align="center">

**[⭐ Star this repo](https://github.com/Sleywill/KrabWidget)** if you like it!

</div>
