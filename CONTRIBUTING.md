# Contributing to KrabWidget 🦀

Thank you for your interest in contributing to KrabWidget! This document provides guidelines and instructions for contributing.

## 🌟 Ways to Contribute

### 1. Report Bugs
- Check if the bug is already reported in [Issues](https://github.com/Sleywill/KrabWidget/issues)
- If not, create a new issue with:
  - macOS version
  - Steps to reproduce
  - Expected vs actual behavior
  - Screenshots/videos if helpful

### 2. Suggest Features
- Open an issue with `[Feature Request]` in the title
- Describe the feature and why it would be useful
- Include mockups or examples if possible

### 3. Submit Code
- Fork the repository
- Create a feature branch
- Write clean, documented code
- Test your changes
- Submit a pull request

### 4. Improve Documentation
- Fix typos or unclear explanations
- Add examples
- Translate to other languages

### 5. Create Content
- Write blog posts about KrabWidget
- Make tutorial videos
- Share on social media

---

## 🛠️ Development Setup

### Prerequisites
- macOS 14.0+
- Xcode 15.0+
- Git

### Getting Started

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/KrabWidget.git
cd KrabWidget

# Open in Xcode
open KrabWidget.xcodeproj

# Build and run (⌘R)
```

### Project Structure

```
KrabWidget/
├── KrabWidgetApp.swift      # App entry, window setup
├── ContentView.swift        # Main view coordinator
├── Models.swift             # Data structures
├── Managers/                # Business logic
│   ├── SpeechManager        # Voice input
│   ├── VoiceManager         # Voice output
│   ├── TelegramManager      # Telegram API
│   ├── AIBackendManager     # AI integrations
│   ├── NotificationManager  # Pop-up system
│   ├── CrabStatusManager    # Status widget
│   └── EasterEggManager     # Fun surprises
├── Views/                   # UI components
└── Components/              # Reusable UI pieces
```

---

## 📝 Code Style Guidelines

### Swift Style

- Use SwiftUI and modern Swift 5.9 features
- Follow [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Add comments for complex logic

### Example

```swift
// ✅ Good
func fetchUserMessages(for userId: String) async throws -> [Message] {
    // Fetch messages from the server
    let response = try await apiClient.get("/users/\(userId)/messages")
    return try decoder.decode([Message].self, from: response.data)
}

// ❌ Bad
func fetch(_ id: String) async throws -> [Message] {
    let r = try await api.get("/users/\(id)/messages")
    return try d.decode([Message].self, from: r.data)
}
```

### SwiftUI Style

```swift
// ✅ Good - Modular, reusable
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            content
            if !message.isFromUser { Spacer() }
        }
    }
    
    private var content: some View {
        Text(message.text)
            .padding()
            .background(bubbleColor)
            .cornerRadius(16)
    }
    
    private var bubbleColor: Color {
        message.isFromUser ? .blue : .gray
    }
}

// ❌ Bad - Everything inline
struct MessageBubble: View {
    let message: Message
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            Text(message.text).padding().background(message.isFromUser ? .blue : .gray).cornerRadius(16)
            if !message.isFromUser { Spacer() }
        }
    }
}
```

---

## 🧪 Testing

### Manual Testing Checklist

Before submitting a PR, test:

- [ ] Voice input works
- [ ] Voice output works
- [ ] Telegram connection (if you have a bot)
- [ ] All themes display correctly
- [ ] Windows drag and resize properly
- [ ] Settings save and load correctly
- [ ] App launches without errors
- [ ] No memory leaks (use Instruments)

### Running Tests

```bash
# In Xcode: ⌘U
# Or command line:
xcodebuild test -scheme KrabWidget -destination 'platform=macOS'
```

---

## 🔀 Pull Request Process

### 1. Before Creating PR

- [ ] Code compiles without errors
- [ ] Tested on macOS 14+
- [ ] Updated documentation if needed
- [ ] Added comments for complex code
- [ ] No hardcoded secrets or API keys

### 2. PR Title Format

```
[Type] Brief description

Types:
- [Feature] New functionality
- [Fix] Bug fix
- [Docs] Documentation only
- [Style] Code style/formatting
- [Refactor] Code restructuring
- [Test] Adding tests
```

### 3. PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How did you test this?

## Screenshots
(If applicable)

## Checklist
- [ ] Code compiles
- [ ] Tested manually
- [ ] Documentation updated
```

### 4. Review Process

1. Submit your PR
2. Maintainers will review within a few days
3. Address any requested changes
4. Once approved, it will be merged!

---

## 🎨 Design Guidelines

### Visual Style

- **Glass morphism** - Translucent, blurred backgrounds
- **Smooth animations** - Spring animations, 0.3s duration
- **Consistent spacing** - Use 8pt grid
- **Accessible colors** - Good contrast ratios

### Color Palette

```swift
// Primary theme colors (adjust per theme)
let backgroundColor = Color(red: 0.05, green: 0.1, blue: 0.15)
let primaryColor = Color(red: 0.1, green: 0.4, blue: 0.6)
let accentColor = Color(red: 0.3, green: 0.7, blue: 0.9)
```

### Typography

- System font (SF Pro) for UI
- Monospaced for code/terminal
- Size hierarchy: title (24), headline (17), body (15), caption (12)

---

## 🦀 Adding Easter Eggs

Want to add a fun easter egg? Here's how:

### 1. Define the Easter Egg

In `EasterEggManager.swift`:

```swift
enum EasterEgg: String, CaseIterable {
    // ... existing cases
    case myNewEgg = "my_new_egg"  // Add here
}
```

### 2. Add Trigger

In `secretPhrases`:

```swift
private let secretPhrases: [String: EasterEgg] = [
    // ... existing phrases
    "my secret phrase": .myNewEgg,
]
```

### 3. Add Effect

In `trigger(_ egg:)`:

```swift
case .myNewEgg:
    triggerMyNewEgg()
```

### 4. Implement Effect

```swift
private func triggerMyNewEgg() {
    // Your fun effect here!
    VoiceManager().speak("You found it!")
    showConfetti = true
}
```

---

## 📜 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on the code, not the person
- Have fun! 🦀

---

## 📞 Contact

- **Issues**: [GitHub Issues](https://github.com/Sleywill/KrabWidget/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Sleywill/KrabWidget/discussions)

---

Thank you for helping make KrabWidget better! 🦀❤️
