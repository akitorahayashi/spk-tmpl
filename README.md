## Overview

This is an iOS SpriteKit game template built with SwiftUI and The Composable Architecture (TCA). The app features state-driven routing between Home and Game screens using an enum-based app state for exclusive transitions.

## Architecture

### TCA + SpriteKit Design
- **Reducers** manage feature logic using `@Reducer` macro
- **Views** bind to stores via `StoreOf<Feature>` and `@Bindable`
- **SpriteKit** renders gameplay via `UIViewRepresentable` hosting `SKView`
- **Dependencies** use the pointfree `Dependencies` library for injection
- **Navigation** follows delegate-driven transitions with enum-based app state

### Package Structure
- `App/`: Application shell with resources (AppIcon) and dependency bootstrap
- `Packages/`: Local Swift package containing feature modules
  - `AppFeature/`: Root routing hub with enum state (home/game)
  - `HomeFeature/`: Title screen with start trigger and delegate pattern
  - `GameFeature/`: Pure gameplay logic with kill tracking and delegate notifications
  - `SharedResources/`: Centralized asset management with SwiftGen-generated type-safe accessors
- `Tests/Unit/`: Unit tests for app-level code
- `Tests/Intg/`: Integration tests with dependency overrides
- `Tests/UI/`: Black-box UI tests

### Asset Management
Assets are managed via the `SharedResources` SPM module. SwiftGen generates type-safe Swift code from `Media.xcassets`.
- Assets: `Packages/Packages/SharedResources/Sources/SharedResources/Resources/Media.xcassets`
- Generated code: `Packages/Packages/SharedResources/Sources/SharedResources/Generated/` (git-ignored)
- Run `just gen-as` to regenerate asset code after modifying assets

### Module Conventions
Each feature follows a Domain/UI split:
- `*Core`: Reducer, state, actions, and dependencies (no SwiftUI imports)
- `*UI`: SwiftUI views and SpriteKit scenes that bind to stores

## Game Feature

### Gameplay Logic
The game operates as pure gameplay logic:
- GameFeature is initialized in "playing" state
- Tracks kill count and notifies parent via delegate actions on game end
- Win condition: 10 kills
- Loss condition: Single hit

### SpriteKit Gameplay
The game scene implements:
- Player movement via touch drag (X-axis following)
- Automatic firing for player and enemy (periodic bullets)
- Collision detection (player bullet ↔ enemy, enemy bullet ↔ player)

### SpriteKit Hosting
SpriteKit is hosted via `UIViewRepresentable` wrapping `SKView`:
- Scene creation triggered by SwiftUI geometry
- Debug overlays (FPS/node count) in Debug builds
- Callbacks bridge game events to TCA actions

## Customization Steps

When starting a new project from this template, follow these steps to set project-specific values.

### 1. Configure Environment Variables

Copy `.env.example` to `.env` and update the values as needed.

#### Simulator Configuration

This project uses separate simulators for development and testing:

- `DEV_SIMULATOR_UDID`: UDID of the simulator used for app execution and debugging
- `TEST_SIMULATOR_UDID`: UDID of the simulator used for automated test execution

To find your simulator UDID, run `xcrun simctl list devices` and copy the UUID of the desired simulator.

### 2. Update Configuration Files

#### project.envsubst.yml

This is the source file for the Xcode project (`.xcodeproj`).

| Setting Item | Current Value | Change Example |
|---|---|---|
| `name` | `TemplateApp` | `NewApp` |
| `packages.Packages.path` | `Packages` | `Packages` |
| `PRODUCT_BUNDLE_IDENTIFIER` | `com.akitorahayashi.TemplateApp` | `com.yourcompany.NewApp` |

**Note:** After changing `project.envsubst.yml`, run `just gen-pj` to regenerate the project.

#### dependencies.yml

Update package references if you rename the package.

#### Packages/Package.swift

Update the package name and all target/product names.

#### justfile

| Variable Name | Current Value | Change Example |
|---|---|---|
| `PROJECT_FILE` | `"TemplateApp.xcodeproj"` | `"NewApp.xcodeproj"` |
| `APP_BUNDLE_ID` | `"com.akitorahayashi.TemplateApp"` | `"com.yourcompany.NewApp"` |

#### fastlane/config.rb

| Constant Name | Current Value | Change Example |
|---|---|---|
| `PROJECT_PATH` | `"TemplateApp.xcodeproj"` | `"NewApp.xcodeproj"` |
| `SCHEMES[:app]` | `"TemplateApp"` | `"NewApp"` |
| `SCHEMES[:unit_test]` | `"TemplateAppTests"` | `"NewAppTests"` |
| `SCHEMES[:ui_test]` | `"TemplateAppUITests"` | `"NewAppUITests"` |

## Development Commands

| Command | Description |
|---|---|
| `just setup` | Initialize project: install dependencies and generate all code |
| `just gen` | Run all code generation (assets + Xcode project) |
| `just gen-as` | Generate asset Swift code using SwiftGen |
| `just gen-pj` | Regenerate Xcode project from templates |
| `just check` | Format and lint code |
| `just test` | Run all tests (package + Xcode) |
| `just pkg-test` | Run Swift package tests only |
| `just unit-test` | Run Xcode unit tests |
| `just intg-test` | Run integration tests |
| `just ui-test` | Run UI tests |
| `just clean` | Remove build artifacts and caches |
