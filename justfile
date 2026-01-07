# ==============================================================================
# justfile for TemplateApp automation
# ==============================================================================

set dotenv-load

# --- PROJECT SETTINGS ---
PROJECT_FILE := "TemplateApp.xcodeproj"
APP_BUNDLE_ID := "com.akitorahayashi.TemplateApp"

# --- PROJECT SPECIFIC PATHS ---
HOME_DIR := env("HOME")
TEST_DERIVED_DATA_PATH := "fastlane/build/test-results/DerivedData"
DEBUG_APP_PATH := TEST_DERIVED_DATA_PATH + "/Debug/Build/Products/Debug-iphonesimulator/TemplateApp.app"
RELEASE_APP_PATH := TEST_DERIVED_DATA_PATH + "/Release/Build/Products/Release-iphonesimulator/TemplateApp.app"

# --- SWIFT PACKAGE OPTIONS ---
SWIFTPM_ROOT := env("SWIFTPM_ROOT", HOME_DIR + "/.cache/swiftpm/tca-tmpl")
SWIFTPM_DEP_CACHE := SWIFTPM_ROOT + "/dependencies"
SWIFTPM_ARTIFACT_ROOT := SWIFTPM_ROOT + "/artifacts"

# --- ENVIRONMENT VARIABLES ---
TEAM_ID := env("TEAM_ID", "")
DEV_SIMULATOR_UDID := env("DEV_SIMULATOR_UDID", "")
TEST_SIMULATOR_UDID := env("TEST_SIMULATOR_UDID", "")

# ==============================================================================
# Modules
# ==============================================================================
# Load implementations under the fastlane directory as a module named 'fastlane'
mod fastlane "fastlane/just/main.just"

# ==============================================================================
# Main
# ==============================================================================

# default recipe
default: help

# Show available recipes
help:
    @echo "Usage: just [recipe]"
    @echo "Available recipes:"
    @just --list | tail -n +2 | awk '{printf "  \033[36m%-30s\033[0m %s\n", $1, substr($0, index($0, $2))}'

# ==============================================================================
# Environment Setup
# ==============================================================================

# Initialize project: install dependencies and generate project files
setup:
    @echo "Installing Ruby gems..."
    @bundle install
    @if [ ! -f .env ]; then \
        cp .env.example .env && \
        echo "📝 Created .env file from .env.example."; \
    else \
        echo "📝 .env file already exists."; \
    fi
    @echo "Bootstrapping Mint packages..."
    @mint bootstrap
    @echo "Generating Xcode project..."
    @just gen-pj

# Generate Xcode project
gen-pj:
    #!/usr/bin/env bash
    set -e
    echo "Generating Xcode project with TEAM_ID: {{TEAM_ID}}"
    # First, do envsubst for TEAM_ID
    TEAM_ID={{TEAM_ID}} envsubst < project.envsubst.yml > project.yml.tmp
    # Read dependencies and indent them for embedding (6 spaces for YAML array items under dependencies:)
    DEPS_FILE=$(mktemp)
    sed 's/^/      /' dependencies.yml > "$DEPS_FILE"
    # Replace all placeholder occurrences with the dependencies content
    awk -v depsfile="$DEPS_FILE" '
        /# __DEPENDENCIES__/ {
            while ((getline line < depsfile) > 0) print line
            close(depsfile)
            next
        }
        { print }
    ' project.yml.tmp > project.yml
    rm -f project.yml.tmp "$DEPS_FILE"
    mint run xcodegen generate

# Resolve Swift package dependencies
resolve-packages cache_path=SWIFTPM_DEP_CACHE:
    #!/usr/bin/env bash
    set -e
    echo "Using dependency cache at: {{cache_path}}"
    mkdir -p "{{cache_path}}"
    echo "🔄 Resolving dependencies for Packages..."
    swift package resolve --package-path Packages --cache-path "{{cache_path}}"
    echo "✅ Package resolution complete."
    echo "Resolving Xcode project dependencies..."
    xcodebuild -resolvePackageDependencies -project {{PROJECT_FILE}}
    echo "✅ Xcode dependencies resolved."

# Reset SwiftPM cache, dependencies, and build artifacts
resolve-pkg:
    @echo "Removing SwiftPM build and cache..."
    @rm -rf .build
    @rm -rf Packages/.build
    @rm -rf {{SWIFTPM_ROOT}}
    @echo "✅ SwiftPM build and cache removed."
    @echo "Resolving Swift package dependencies..."
    @just resolve-packages
    @echo "✅ Package dependencies resolved."

# Open project in Xcode
open:
    @xed {{PROJECT_FILE}}

# ==============================================================================
# Local Simulator
# ==============================================================================

# Boot local simulator
boot:
    @if [ -z "{{DEV_SIMULATOR_UDID}}" ]; then \
        echo "DEV_SIMULATOR_UDID is not set. Please set it in your .env"; \
        exit 1; \
    fi
    @echo "Booting development simulator: UDID: {{DEV_SIMULATOR_UDID}}"
    @if xcrun simctl list devices | grep -q "{{DEV_SIMULATOR_UDID}} (Booted)"; then \
        echo "⚡️ Simulator is already booted."; \
    else \
        xcrun simctl boot {{DEV_SIMULATOR_UDID}}; \
        echo "✅ Simulator booted."; \
    fi
    @open -a Simulator

# Boot test simulator
boot-test:
    @if [ -z "{{TEST_SIMULATOR_UDID}}" ]; then \
        echo "TEST_SIMULATOR_UDID is not set. Please set it in your .env"; \
        exit 1; \
    fi
    @echo "Booting test simulator: UDID: {{TEST_SIMULATOR_UDID}}"
    @if xcrun simctl list devices | grep -q "{{TEST_SIMULATOR_UDID}} (Booted)"; then \
        echo "⚡️ Simulator is already booted."; \
    else \
        xcrun simctl boot {{TEST_SIMULATOR_UDID}}; \
        echo "✅ Simulator booted."; \
    fi
    @open -a Simulator

# List available simulators
siml:
    @xcrun simctl list devices available

# ==============================================================================
# Lint & Format
# ==============================================================================

# Format code
fix:
    @mint run swiftformat .
    @mint run swiftlint lint --fix .

# Check code format
check: fix
    @mint run swiftformat --lint .
    @mint run swiftlint lint --strict

# ==============================================================================
# CLEANUP
# ==============================================================================

# Clean build artifacts, caches, and generated files
clean:
    @rm -rf {{PROJECT_FILE}}
    @rm -rf fastlane/build
    @rm -rf fastlane/logs
    @rm -rf fastlane/report.xml
    @rm -rf .build
    @rm -rf Packages/.build
    @rm -rf {{SWIFTPM_ROOT}}

# ==============================================================================
# Test Interface (Delegated to fastlane module)
# ==============================================================================

# Run all tests (unit, integration, UI, and package tests)
test:
    @just package-test
    @just fastlane::test-all

# Run Swift package tests
package-test:
    @echo "Running Swift package tests..."
    @swift test --package-path Packages
    @echo "✅ Package tests complete."

# Run a specific package test target
# Usage: just pkg-test <target> [use_cache] [extra_args]
pkg-test target use_cache="false" extra_args="":
    #!/usr/bin/env bash
    set -e
    echo "🧪 Running tests for {{target}}..."
    CACHE_ARGS=""
    if [ "{{use_cache}}" = "true" ]; then
        CACHE_ARGS="--cache-path {{SWIFTPM_DEP_CACHE}} --scratch-path {{SWIFTPM_ARTIFACT_ROOT}}/Packages"
    fi
    swift test --package-path Packages --filter "{{target}}" $CACHE_ARGS {{extra_args}}

# Run unit tests
unit-test:
    @just fastlane::unit-test

# Run unit tests without building
unit-test-without-building:
    @just fastlane::unit-test-without-building

# Run integration tests
intg-test:
    @just fastlane::intg-test

# Run integration tests without building
intg-test-without-building:
    @just fastlane::intg-test-without-building

# Run UI tests
ui-test:
    @just fastlane::ui-test

# Run UI tests without building
ui-test-without-building:
    @just fastlane::ui-test-without-building

# ==============================================================================
# Build Interface (Delegated to fastlane module)
# ==============================================================================

# Build Debug archive (unsigned)
build-debug:
    @just fastlane::build-debug

# Build Release archive (unsigned)
build-release:
    @just fastlane::build-release

# Build debug, install, and launch on local simulator
run-debug:
    @just fastlane::run-debug

# Build release, install, and launch on local simulator
run-release:
    @just fastlane::run-release

# Build for testing
build-test:
    @just fastlane::build-test

# ==============================================================================
# Signing Interface (Delegated to fastlane module)
# ==============================================================================

# Sign debug archive for development
sign-debug-development:
    @just fastlane::sign-debug-development

# Sign release archive for development
sign-release-development:
    @just fastlane::sign-release-development

# Sign release archive for App Store
sign-release-app-store:
    @just fastlane::sign-release-app-store

# Sign release archive for Ad Hoc
sign-release-ad-hoc:
    @just fastlane::sign-release-ad-hoc

# Sign release archive for Enterprise
sign-release-enterprise:
    @just fastlane::sign-release-enterprise
