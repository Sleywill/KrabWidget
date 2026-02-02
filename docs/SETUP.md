# 🦀 KrabWidget Setup Guide

This guide will walk you through setting up KrabWidget step by step. No coding experience required!

---

## 📋 Table of Contents

1. [System Requirements](#-system-requirements)
2. [Installing KrabWidget](#-installing-krabwidget)
3. [First Launch](#-first-launch)
4. [Setting Up AI](#-setting-up-ai-optional)
5. [Setting Up Telegram](#-setting-up-telegram-optional)
6. [Customizing KrabWidget](#-customizing-krabwidget)
7. [Troubleshooting](#-troubleshooting)

---

## 💻 System Requirements

- **macOS 14.0 (Sonoma)** or later
- A working **microphone** (built-in or external)
- **Internet connection** (only if using cloud AI or Telegram)
- About **100MB** of disk space

---

## 📥 Installing KrabWidget

### Option A: Download Pre-built App (Easiest)

1. Go to [Releases](https://github.com/Sleywill/KrabWidget/releases)
2. Download the latest `KrabWidget.app.zip`
3. Unzip the file
4. Drag `KrabWidget.app` to your **Applications** folder
5. Double-click to launch!

### Option B: Build from Source (For Developers)

1. Make sure you have **Xcode 15** or later installed
2. Open Terminal and run:
   ```bash
   git clone https://github.com/Sleywill/KrabWidget.git
   cd KrabWidget
   open KrabWidget.xcodeproj
   ```
3. In Xcode, press **⌘R** to build and run

---

## 🚀 First Launch

### Step 1: Allow Microphone Access

When you first launch KrabWidget, macOS will ask for microphone permission.

1. A dialog will appear: "KrabWidget would like to access the microphone"
2. Click **OK** to allow
3. If you accidentally clicked "Don't Allow", go to:
   - System Settings → Privacy & Security → Microphone
   - Enable KrabWidget

### Step 2: Complete the Onboarding Wizard

Krab will greet you with voice! Follow the wizard:

1. **Welcome Screen** - Learn about features
2. **Voice Pack Selection** - Choose Krab's personality
   - Click any voice pack to hear a preview
   - Select the one you like
3. **Telegram Setup** (Optional) - Skip if you don't want Telegram
4. **Layout Selection** - Choose your window setup

### Step 3: Grant Speech Recognition Permission

When you first try to use voice:
1. A dialog will appear asking for speech recognition permission
2. Click **OK** to allow

---

## 🤖 Setting Up AI (Optional)

KrabWidget can connect to AI for smarter responses. Here are your options:

### 🏠 Option 1: Ollama (Free, Local, Private)

**Best for:** Privacy-conscious users, offline use

**Step 1: Install Ollama**

1. Open Terminal (Applications → Utilities → Terminal)
2. Install Homebrew (if you don't have it):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Install Ollama:
   ```bash
   brew install ollama
   ```

**Step 2: Start Ollama**

```bash
ollama serve
```
(Keep this terminal window open)

**Step 3: Download an AI Model**

Open a NEW terminal window and run:
```bash
ollama pull llama3.2
```
(This downloads ~2GB, may take a few minutes)

**Step 4: Connect KrabWidget**

1. Open KrabWidget Settings (⌘,)
2. Go to "AI Backend" tab
3. Select "Ollama (Local)"
4. URL should be: `http://localhost:11434`
5. Model: `llama3.2`
6. Click "Connect"
7. You should see a green "Connected" status!

---

### ☁️ Option 2: OpenAI (Paid, Cloud)

**Best for:** Best quality responses, quick setup

**Step 1: Get an API Key**

1. Go to [platform.openai.com](https://platform.openai.com/)
2. Sign up or log in
3. Go to API Keys section
4. Click "Create new secret key"
5. Copy the key (starts with `sk-...`)

**Step 2: Add Payment Method**

1. Go to Settings → Billing
2. Add a payment method
3. Add some credits ($5-10 is plenty to start)

**Step 3: Connect KrabWidget**

1. Open KrabWidget Settings (⌘,)
2. Go to "AI Backend" tab
3. Select "OpenAI"
4. Paste your API key
5. Select model (recommend "GPT-4o Mini" for speed)
6. Click "Connect"

**Cost:** About $0.001 per message (very cheap!)

---

### 🔌 Option 3: OpenClaw

**Best for:** Users who already have OpenClaw set up

1. Start your OpenClaw gateway
2. Open KrabWidget Settings (⌘,)
3. Go to "AI Backend" tab
4. Select "OpenClaw"
5. Enter your gateway URL
6. Enter your API token
7. Click "Connect"

---

## 📱 Setting Up Telegram (Optional)

Receive Telegram messages directly in KrabWidget!

### Step 1: Create a Telegram Bot

1. Open Telegram
2. Search for **@BotFather** (the official bot creator)
3. Send the message: `/newbot`
4. BotFather will ask for a name. Type something like: `My Krab Assistant`
5. BotFather will ask for a username. Type something ending in `bot`, like: `my_krab_bot`
6. BotFather will give you a token that looks like:
   ```
   123456789:ABCdefGHIjklMNOpqrsTUVwxyz
   ```
7. **Copy this token!**

### Step 2: Connect to KrabWidget

1. Open KrabWidget Settings (⌘,)
2. Go to "Telegram" tab
3. Paste your bot token
4. Click "Connect"
5. You should see "Connected" status!

### Step 3: Test It

1. Open Telegram
2. Search for your bot by its username
3. Start a conversation with it
4. Send any message
5. You should see it appear in KrabWidget!

---

## 🎨 Customizing KrabWidget

### Changing Voice

1. Settings → Voice
2. Click "Change" next to current voice
3. Preview different voices by clicking them
4. Select the one you like

### Changing Theme

1. Settings → Appearance
2. Click any theme to preview
3. Themes: Deep Ocean, Coral Reef, Midnight, Sunset

### Adjusting Transparency

1. Settings → Appearance
2. Use the "Window Transparency" slider
3. Lower = more see-through

### Changing Hotkey

1. Settings → Hotkeys
2. Select from presets or use default (⌘⌥Space)

### Window Management

- **Drag** any window by its title bar
- **Resize** by dragging edges
- **Add windows** with the + button
- **Remove windows** with the X button

---

## 🔧 Troubleshooting

### "Krab isn't hearing me"

1. Check microphone permissions:
   - System Settings → Privacy & Security → Microphone
   - Make sure KrabWidget is enabled
2. Check your microphone is working:
   - System Settings → Sound → Input
   - Speak and check the level meter moves
3. Try restarting KrabWidget

### "AI isn't responding"

1. Check your AI backend is connected:
   - Settings → AI Backend
   - Should show green "Connected"
2. For Ollama: Make sure `ollama serve` is running
3. For OpenAI: Check your API key is valid

### "Telegram messages aren't showing"

1. Check connection status in Settings → Telegram
2. Make sure you copied the full bot token
3. Try disconnecting and reconnecting

### "App won't launch"

1. Make sure you're on macOS 14 or later
2. Try right-clicking the app → Open (bypasses security)
3. Check System Settings → Privacy & Security for any blocks

### "Speech recognition not available"

1. Check internet connection (required for Apple's speech recognition)
2. System Settings → Privacy & Security → Speech Recognition
3. Enable KrabWidget

---

## 🆘 Getting Help

Still having issues? Here's how to get help:

1. **Check the FAQ** in the GitHub Wiki
2. **Search existing issues** on GitHub
3. **Open a new issue** with:
   - Your macOS version
   - What you tried
   - Any error messages
   - Screenshots if helpful

---

## 🎉 You're Ready!

Congratulations! You've set up KrabWidget. Here are some things to try:

- Say "Hey Krab, tell me a joke"
- Say "Hey Krab, what time is it?"
- Try different voice packs
- Discover easter eggs (hint: say "crab rave"!)
- Customize your window layout

**Have fun with your new AI crab companion! 🦀**
