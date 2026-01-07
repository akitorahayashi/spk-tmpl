## Overview

This is an iOS app template built with SwiftUI and The Composable Architecture (TCA). The architecture follows a package-modularized structure where feature logic lives in a local Swift package.

## Architecture

### TCA-First Design
- **Reducers** manage all business logic using `@Reducer` macro
- **Views** bind to stores via `StoreOf<Feature>` and `@Bindable`
- **Dependencies** use the pointfree `Dependencies` library for injection
- **Navigation** follows scope-driven composition patterns

### Package Structure
- `App/`: Application shell with resources and dependency bootstrap
- `Packages/`: Local Swift package containing feature modules
  - `AppFeature/`: Root feature composing child features
  - `CounterFeature/`: Sample counter feature demonstrating TCA patterns
- `Tests/Unit/`: Unit tests for app-level code
- `Tests/Intg/`: Integration tests with dependency overrides
- `Tests/UI/`: Black-box UI tests

### Module Conventions
Each feature follows a Domain/UI split:
- `*Domain`: Reducer, state, actions, and dependencies (no SwiftUI imports)
- `*UI`: SwiftUI views that bind to stores

## Customization Steps

When starting a new project from this template, follow these steps to set project-specific values.

### 1. Change Project Name and Directory

In the project root directory, change the template placeholder names to your new project name. For example, if your new project name is `NewApp`:

1. `App` → `App` (no change needed)
2. `Tests/Unit` → `Tests/Unit` (no change needed)
3. `Tests/Intg` → `Tests/Intg` (no change needed)
4. `Tests/UI` → `Tests/UI` (no change needed)
5. `Packages` → `Packages` (no change needed)

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and update the values as needed.

#### Simulator Configuration

This project uses separate simulators for development and testing:

- `DEV_SIMULATOR_UDID`: UDID of the simulator used for app execution and debugging
- `TEST_SIMULATOR_UDID`: UDID of the simulator used for automated test execution

To find your simulator UDID, run `xcrun simctl list devices` and copy the UUID of the desired simulator.

### 3. Update Configuration Files

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
| `just setup` | Initialize project: install dependencies and generate project |
| `just gen-pj` | Regenerate Xcode project from templates |
| `just check` | Format and lint code |
| `just test` | Run all tests (package + Xcode) |
| `just package-test` | Run Swift package tests only |
| `just unit-test` | Run Xcode unit tests |
| `just intg-test` | Run integration tests |
| `just ui-test` | Run UI tests |
| `just clean` | Remove build artifacts and caches |
