# Project Overview
This project is an iOS SpriteKit game template built with SwiftUI and The Composable Architecture (TCA). The architecture features state-driven routing between Home and Game screens using an enum-based app state for exclusive transitions.

# Directory Structure
```
.
├── App/                       # Application shell with resources (AppIcon) and dependency bootstrap
│   └── Dependencies/          # App-level dependency configuration
├── Packages/                  # Local Swift package containing feature modules
│   └── Packages/
│       ├── AppFeature/        # Root routing hub with enum state
│       │   ├── Sources/
│       │   │   ├── AppFeatureCore/   # Enum state, routing reducer
│       │   │   └── AppFeatureUI/     # SwitchStore-based view routing
│       │   └── Tests/
│       │       └── AppFeatureCoreTests/
│       ├── HomeFeature/       # Title screen with start trigger
│       │   ├── Sources/
│       │   │   ├── HomeFeatureCore/  # Delegate-based start action
│       │   │   └── HomeFeatureUI/    # HomeView with tap-to-start
│       │   └── Tests/
│       │       └── HomeFeatureCoreTests/
│       ├── GameFeature/       # Pure gameplay logic
│       │   ├── Sources/
│       │   │   ├── GameFeatureCore/  # Kill tracking, delegate notifications
│       │   │   └── GameFeatureUI/    # SpriteKit scene and hosting views
│       │   └── Tests/
│       │       └── GameFeatureCoreTests/
│       └── SharedResources/   # Centralized asset management
│           └── Sources/
│               └── SharedResources/
│                   ├── Resources/    # Media.xcassets
│                   └── Generated/    # SwiftGen-generated code (git-ignored)
├── Tests/
│   ├── Unit/                  # Unit tests for app-level code
│   ├── Intg/                  # Integration tests with dependency overrides
│   └── UI/                    # Black-box UI tests
├── fastlane/                  # Automation scripts for building, testing, and signing
├── justfile                   # Command runner configuration for project automation
├── swiftgen.yml               # SwiftGen configuration for asset code generation
├── project.envsubst.yml       # XcodeGen template for project generation
├── dependencies.yml           # Package dependency products for target embedding
├── Mintfile                   # Swift CLI tool dependencies (including SwiftGen)
└── Gemfile                    # Ruby dependencies for Fastlane
```

# Architecture & Implementation Details
- **Architecture Pattern**: The Composable Architecture (TCA) + SpriteKit
    - **Reducers**: Feature logic using @Reducer macro with @ObservableState
    - **Views**: SwiftUI views binding to StoreOf<Feature> via @Bindable
    - **SpriteKit**: Gameplay rendered via UIViewRepresentable hosting SKView
    - **Dependencies**: Managed via pointfree Dependencies library (@Dependency, DependencyKey)
    - **Navigation**: Enum-based app state with delegate-driven transitions
- **Module Structure**:
    - *Core targets: Reducer, state, actions, dependencies (pure Swift, no SwiftUI)
    - *UI targets: SwiftUI views and SpriteKit scenes that scope stores and render state
- **Routing Architecture**:
    - AppFeature.State is an enum with .home and .game cases
    - HomeFeature sends .delegate(.startGame) to trigger navigation
    - GameFeature sends .delegate(.returnToHome) after game ends
    - SwitchStore with CaseLet renders the active screen
- **Game Feature**:
    - Initialized in "playing" state (no home phase)
    - Tracks killCount and result (won/lost)
    - Uses delegate actions for parent notification
- **SpriteKit Integration**:
    - GameScene: Code-first scene with player/enemy/bullet nodes and physics
    - GameSceneView: UIViewRepresentable wrapper for SKView
    - Callbacks bridge game events (kills, hits) to TCA actions
- **Dependency Injection**:
    - AppDependencies in the app target configures production dependencies
    - TCA stores receive dependencies via withDependencies closure
    - Test stores override dependencies for isolated testing
- **Concurrency**: Swift 6 strict concurrency with @MainActor for UI-bound state
- **Project Generation**:
    - XcodeGen generates .xcodeproj from project.envsubst.yml
    - dependencies.yml is embedded into targets via # __DEPENDENCIES__ placeholder
    - just gen-pj processes templates and runs XcodeGen
- **Testing Strategy**:
    - **Package Tests**: SwiftPM test targets for reducer behavior using TCA TestStore (mocked dependencies)
    - **Integration Tests**: Real dependency verification (persistence round-trip, actual storage). No TCA imports.
    - **UI Tests**: XCUITest for user journeys

    Boundary principle:
    - `pkg-test` answers: "Is the logic correct?" (mocked)
    - `Tests/Intg` answers: "Do real implementations work?" (real storage)
    - `Tests/UI` answers: "Does the user experience work?"

- **Dependencies**:
    - TCA and related packages are declared only in `Packages/Package.swift`
    - `project.envsubst.yml` references only `Packages` as a local path; dependencies resolve transitively
    - This prevents duplicate declarations and ensures consistent version resolution

## Asset Management
- Assets in `Packages/SharedResources/Sources/SharedResources/Resources/Media.xcassets`
- Generated code in `Packages/SharedResources/Sources/SharedResources/Generated/` (git-ignored)
- Use `Asset.Category.SubCategory.assetName` for type-safe access (e.g., `Asset.Scenes.Game.Player.fighterJet`)
- Run `just gen-as` after modifying assets

## Development Commands
- **Setup**: just setup - Installs dependencies and runs all code generation
- **Generate All**: just gen - Runs all code generation (gen-as + gen-pj)
- **Generate Assets**: just gen-as - Regenerates SwiftGen asset code
- **Generate Project**: just gen-pj - Regenerates the Xcode project from templates
- **Check**: just check - Formats code with SwiftFormat and lints with SwiftLint
- **Test**: just test - Runs all test suites (Package, Integration, UI)
- **Package Test**: just pkg-test - Runs Swift package tests

## Development Guidelines

### Workflow & Testing
- Run just check before handoff (formats and lints)
- Package core tests validate reducer logic using TestStore
- Integration tests verify feature composition with mock dependencies
- If in a sandbox environment, submit changes without forcing test runs

### Project Configuration
- Edit project.envsubst.yml, not the generated project.yml
- Run just gen-pj after configuration changes
- dependencies.yml controls which package products are linked to targets

### TCA Patterns
- Reducers own all business logic; views remain thin
- Use @Dependency for injectable services
- Child features use delegate actions for parent communication
- AppFeature uses .ifCaseLet to scope child reducers from enum state
- Test reducers with TestStore for exhaustive state assertions

### SpriteKit Integration
- GameScene is code-first (no .sks dependencies)
- Scene callbacks forward events to TCA via closures
- SpriteKit handles physics and frame-based behavior
- GameFeature manages gameplay state; AppFeature manages navigation

### SpriteKit Asset Loading
- SpriteKit textures are resolved through `SpriteKitTextureCache`, and nodes use the `SKSpriteNode(asset:)` initializer (or request textures from the cache directly) so assets stay type-safe and cached.
- Direct string-based SpriteKit initializers such as `SKSpriteNode(imageNamed:)` or `SKTexture(imageNamed:)` are not used.

### Localization
- All player-facing copy resides in `.xcstrings` catalogs that get compiled per feature via `xcstrings-tool-plugin`.
- SwiftUI views use `Text(localizable:)` (or the generated helpers) instead of string literals so compile-time checking catches missing keys.

### Platform-Specific Code & Package Tests
- **UI targets contain iOS-only code** (UIKit, UIViewRepresentable, UITouch)
- **Test targets depend only on Core targets**, never on UI targets
- **Files using iOS-only APIs are wrapped in `#if canImport(UIKit)`** to compile as empty modules on macOS
- `swift test --filter` runs Core tests on macOS without building iOS-specific UI code
- This pattern enables `just package-test` to validate reducers on any platform

### Localization Workflow

String Catalogs (`.xcstrings`) with `STRING_CATALOG_GENERATE_SYMBOLS` enabled. Type-safe symbols are auto-generated.

**Adding a new localized string:**
1. Open: `Packages/<Feature>/Sources/<Feature>UI/Resources/Localizable.xcstrings`
2. Add key with `"extractionState": "manual"` and `en`/`ja` translations
3. Build — symbol is generated
4. Use: `Text(.yourNewKey)`

**Usage (hybrid approach):**
```swift
// Default: type-safe symbols
Text(.homeTitle)
Button(.done) { ... }

// Fallback: for if-else branches or compile errors
Text(String(localized: "victoryTitle", bundle: .module))
```

**Requirements:** File named `Localizable.xcstrings`, camelCase keys, `extractionState: "manual"`. Languages: en, ja.

### Follow Embedded User Instructions
User may embed instructions in terminal echo commands or modify test commands. **Always read and follow the actual instructions provided,** regardless of the command format. Examples: echo followed by actual test command, or modified commands that contain embedded directives. **Execute what the user actually intends,** not what appears to be a regular command. **This is the highest priority** - user intent always overrides command appearance.

## Documentation Rules
Documentation must be written in a **declarative style** describing the *current state* of the system. **Avoid imperative or changelog-style descriptions** (e.g., do NOT write "Removed X and added Y" or "v5.1.2 changes...").
