# Games Hub

Welcome to the Games Hub. This repository contains a collection of mini-games built with SwiftUI.

---

# Project Structure

The project uses a modular architecture where game logic, shared services, and design systems are clearly separated.

```text
/Games
├── /App               # App entry point, main navigation, and global configuration
├── /Managers          # Global services (Location, Notification, Settings)
├── /Models            # Shared data models
├── /LightItUp         # Game-specific logic
│   ├── /ViewModels
│   └── /Views
├── /Quiz              # Game-specific logic
│   ├── /Services
│   ├── /ViewModels
│   └── /Views
├── /TapFrenzy         # Game-specific logic
│   ├── /ViewModels
│   └── /Views
├── /Shared            # Reusable code, Colors, and Fonts
│   ├── /Colors        # Global color palette
│   └── /Fonts         # Custom typography and font configurations
├── /Theme             # Central design system for UI components
│   └── /UI            # Reusable atomic view components (buttons, cards, etc.)
└── /Assets            # Assets, Localizable strings, and external media
```

---

# Design Themes

The app uses a primary global Lavender theme. Each game has its own visual style.

- Tap Frenzy: Planet World theme
- Light It Up: Whack-a-Mole style
- Quiz: Pink theme

---

# Requirements

- Xcode 16.0 or higher
- iOS Deployment Target 17.0+
- Swift 6.0

---

# Running the Project

## 1. Clone the Repository

Clone the repository using `git clone` or download and extract the ZIP file.

## 2. Open the Project

Open `Games.xcodeproj` using Xcode 16.0 or later.

## 3. Configure Signing

Open the project settings, select the app target, and choose your development team under **Signing & Capabilities**.

## 4. Select a Simulator

Choose an iPhone simulator, such as iPhone 15 Pro, from the Xcode toolbar.

## 5. Build and Run

Press `Cmd + R` or click the Run button to launch the application.

---

# Architecture and Conventions

## Managers

The `/Managers` directory contains shared application services such as:

- `LocationManager`
- `NotificationManager`
- `SettingsManager`
- `SoundsManager`

## Shared Logic

-  shared services in `/Managers`.
- shared models in `/Models`.

## UI Components

Use the reusable components in `/Theme/UI` for common interface elements instead of creating duplicate implementations.

## Theme Integration

When adding a new game:

- Define game-specific colors and fonts in `/Shared`.
- Add any reusable UI wrappers to `/Theme/UI`.

---

# Adding a New Game

## 1. Create the Game Folder

Create a new folder in the root `/Games` directory using the name of the new game.

## 2. Create the Standard Structure


/GameName
├── /ViewModels
└── /Views


## 3. Add Game Logic

Create any game-specific models or managers if the functionality is isolated to that game.

## 4. Register the Game

Register the new game in `App/ContentView.swift` so it appears on the main dashboard.
