# SideQuest

A lightweight macOS menu bar app for the moments when you have free time but cannot remember what you could do.

SideQuest is intentionally **not** a todo list. Everything in it is optional. Open the menu bar, tell it roughly how much time/energy you have, and either browse a few ideas or let **Pick for me** choose one.

## MVP

- Native macOS menu bar app with SwiftUI `MenuBarExtra`
- Activities tagged by duration, energy, category, and screen usage
- Quick filters for available time, Low Energy, No Screen, and Fun
- `Pick for me` random recommendation
- Automatic Night Mode after 10:30 PM
- Night Mode hides high-focus activities such as coding, interview prep, investing research, and work
- Add and remove your own activities
- Local persistence only; no account and no AI dependency

## Run

Requirements: macOS 13+ and Xcode 15+ / Swift 5.9+.

```bash
swift run
```

Or open `Package.swift` in Xcode and run the `SideQuest` executable target.

Run tests with:

```bash
swift test
```

## Product principle

> Optional things should feel like a menu, not obligations.

The app should reduce decision cost, especially at night. It should never turn free-time ideas into another backlog that creates guilt.

## Next ideas

- Custom night cutoff time
- Favorites / weighted recommendations
- Recently-picked cooldown so the same quest does not repeat too often
- Global keyboard shortcut
- Import/export activity presets
- Optional iCloud sync
