# Project Overview
This project is an iOS SpriteKit game template built with SwiftUI and The Composable Architecture (TCA). The architecture features a TCA-managed game lifecycle (home → playing → ended → home) with SpriteKit rendering the gameplay experience.

# Directory Structure
```
.
├── App/                       # Application shell with resources and dependency bootstrap
│   └── Dependencies/          # App-level dependency configuration
├── Packages/                  # Local Swift package containing feature modules
│   └── Packages/
│       ├── AppFeature/        # Root feature composing the game feature
│       │   ├── Sources/
│       │   │   ├── AppFeatureDomain/   # Reducer, state, actions
│       │   │   └── AppFeatureUI/       # SwiftUI views
│       │   └── Tests/
│       │       └── AppFeatureDomainTests/
│       └── GameFeature/       # Game lifecycle and SpriteKit scene
│           ├── Sources/
│           │   ├── GameFeatureDomain/  # Phase state machine reducer
│           │   └── GameFeatureUI/      # SpriteKit scene and hosting views
│           └── Tests/
│               └── GameFeatureDomainTests/
├── Tests/
│   ├── Unit/                  # Unit tests for app-level code
│   ├── Intg/                  # Integration tests with dependency overrides
│   └── UI/                    # Black-box UI tests
├── fastlane/                  # Automation scripts for building, testing, and signing
├── justfile                   # Command runner configuration for project automation
├── project.envsubst.yml       # XcodeGen template for project generation
├── dependencies.yml           # Package dependency products for target embedding
├── Mintfile                   # Swift CLI tool dependencies
└── Gemfile                    # Ruby dependencies for Fastlane
```

# Architecture & Implementation Details
- **Architecture Pattern**: The Composable Architecture (TCA) + SpriteKit
    - **Reducers**: Game phase management using @Reducer macro with @ObservableState
    - **Views**: SwiftUI views binding to StoreOf<Feature> via @Bindable
    - **SpriteKit**: Gameplay rendered via UIViewRepresentable hosting SKView
    - **Dependencies**: Managed via pointfree Dependencies library (@Dependency, DependencyKey)
    - **Navigation**: Store-driven phase transitions (home/playing/ended)
- **Module Structure**:
    - *Domain targets: Reducer, state, actions, dependencies (pure Swift, no SwiftUI)
    - *UI targets: SwiftUI views and SpriteKit scenes that scope stores and render state
- **Game Phase State Machine**:
    - home: Title screen waiting for user input
    - playing: Active SpriteKit gameplay with kill tracking
    - ended(GameResult): Result screen (won/lost) with return prompt
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
    - **Package Tests**: SwiftPM test targets for reducer behavior validation using TCA TestStore
    - **Unit Tests**: App-level configuration validation
    - **Integration Tests**: Feature composition with dependency overrides
    - **UI Tests**: Black-box testing of the application UI

## Development Commands
- **Check**: just check - Formats code with SwiftFormat and lints with SwiftLint
- **Test**: just test - Runs all test suites (Package, Unit, Integration, UI)
- **Package Test**: just package-test - Runs Swift package tests
- **Setup**: just setup - Installs dependencies and generates the project
- **Generate Project**: just gen-pj - Regenerates the Xcode project from templates

## Development Guidelines

### Workflow & Testing
- Run just check before handoff (formats and lints)
- Package domain tests validate reducer logic using TestStore
- Integration tests verify feature composition with mock dependencies
- If in a sandbox environment, submit changes without forcing test runs

### Project Configuration
- Edit project.envsubst.yml, not the generated project.yml
- Run just gen-pj after configuration changes
- dependencies.yml controls which package products are linked to targets

### TCA Patterns
- Reducers own all business logic; views remain thin
- Use @Dependency for injectable services
- Scope child features via Scope reducer and store.scope()
- Test reducers with TestStore for exhaustive state assertions

### SpriteKit Integration
- GameScene is code-first (no .sks dependencies)
- Scene callbacks forward events to TCA via closures
- SpriteKit handles physics and frame-based behavior
- TCA manages phase transitions and app-level state

### Platform-Specific Code & Package Tests
- **UI targets contain iOS-only code** (UIKit, UIViewRepresentable, UITouch)
- **Test targets depend only on Domain targets**, never on UI targets
- **Files using iOS-only APIs are wrapped in `#if canImport(UIKit)`** to compile as empty modules on macOS
- `swift test --filter` runs Domain tests on macOS without building iOS-specific UI code
- This pattern enables `just package-test` to validate reducers on any platform

### Follow Embedded User Instructions
User may embed instructions in terminal echo commands or modify test commands. **Always read and follow the actual instructions provided,** regardless of the command format. Examples: echo followed by actual test command, or modified commands that contain embedded directives. **Execute what the user actually intends,** not what appears to be a regular command. **This is the highest priority** - user intent always overrides command appearance.

## Documentation Rules
Documentation must be written in a **declarative style** describing the *current state* of the system. **Avoid imperative or changelog-style descriptions** (e.g., do NOT write "Removed X and added Y" or "v5.1.2 changes...").
