# ==============================================================================
# justfile for TemplateApp automation
# ==============================================================================

set dotenv-load := true

# --- PROJECT SETTINGS ---

PROJECT_FILE := "TemplateApp.xcodeproj"
APP_BUNDLE_ID := "com.akitorahayashi.TemplateApp"

# --- PROJECT SPECIFIC PATHS ---

HOME_DIR := env("HOME")
TEST_DERIVED_DATA_PATH := "fastlane/build/test-results/DerivedData"
DEBUG_APP_PATH := TEST_DERIVED_DATA_PATH + "/Debug/Build/Products/Debug-iphonesimulator/TemplateApp.app"
RELEASE_APP_PATH := TEST_DERIVED_DATA_PATH + "/Release/Build/Products/Release-iphonesimulator/TemplateApp.app"

# --- SWIFT PACKAGE OPTIONS ---

SWIFTPM_ROOT := env("SWIFTPM_ROOT", HOME_DIR + "/.cache/swiftpm/spk-tmpl")
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
    @echo "Generating assets and Xcode project..."
    @just gen

# Resolve Swift package dependencies
resolve-packages cache_path=SWIFTPM_DEP_CACHE:
    #!/usr/bin/env bash
    set -e
    echo "Using dependency cache at: {{ cache_path }}"
    mkdir -p "{{ cache_path }}"
    echo "🔄 Resolving dependencies for Packages..."
    swift package resolve --package-path Packages --cache-path "{{ cache_path }}"
    echo "✅ Package resolution complete."
    echo "Resolving Xcode project dependencies..."
    xcodebuild -resolvePackageDependencies -project {{ PROJECT_FILE }}
    echo "✅ Xcode dependencies resolved."

# Reset SwiftPM cache, dependencies, and build artifacts
resolve-pkg:
    @echo "Removing SwiftPM build and cache..."
    @rm -rf .build
    @rm -rf Packages/.build
    @rm -rf {{ SWIFTPM_ROOT }}
    @echo "✅ SwiftPM build and cache removed."
    @echo "Resolving Swift package dependencies..."
    @just resolve-packages
    @echo "✅ Package dependencies resolved."

# Open project in Xcode
open:
    @xed {{ PROJECT_FILE }}

# ==============================================================================
# Local Simulator
# ==============================================================================

# Boot local simulator
boot:
    @if [ -z "{{ DEV_SIMULATOR_UDID }}" ]; then \
        echo "DEV_SIMULATOR_UDID is not set. Please set it in your .env"; \
        exit 1; \
    fi
    @echo "Booting development simulator: UDID: {{ DEV_SIMULATOR_UDID }}"
    @if xcrun simctl list devices | grep -q "{{ DEV_SIMULATOR_UDID }} (Booted)"; then \
        echo "⚡️ Simulator is already booted."; \
    else \
        xcrun simctl boot {{ DEV_SIMULATOR_UDID }}; \
        echo "✅ Simulator booted."; \
    fi
    @open -a Simulator

# Boot test simulator
boot-test:
    @if [ -z "{{ TEST_SIMULATOR_UDID }}" ]; then \
        echo "TEST_SIMULATOR_UDID is not set. Please set it in your .env"; \
        exit 1; \
    fi
    @echo "Booting test simulator: UDID: {{ TEST_SIMULATOR_UDID }}"
    @if xcrun simctl list devices | grep -q "{{ TEST_SIMULATOR_UDID }} (Booted)"; then \
        echo "⚡️ Simulator is already booted."; \
    else \
        xcrun simctl boot {{ TEST_SIMULATOR_UDID }}; \
        echo "✅ Simulator booted."; \
    fi
    @open -a Simulator

# List available simulators
siml:
    @xcrun simctl list devices available

# ==============================================================================
# Code Generation
# ==============================================================================

# Generate all (assets + Xcode project)
gen: gen-as gen-pj

# Generate asset code using SwiftGen
gen-as:
    @mint run swiftgen

# Generate Xcode project
gen-pj:
    #!/usr/bin/env bash
    set -e
    echo "Generating Xcode project with TEAM_ID: {{ TEAM_ID }}"
    TEAM_ID={{ TEAM_ID }} envsubst < project.envsubst.yml > project.yml
    mint run xcodegen generate

# ==============================================================================
# Lint & Format
# ==============================================================================

# Format code
fix:
    @just --fmt --unstable
    @mint run swiftformat .
    @mint run swiftlint lint --fix . 2>&1 | tail -5

# Check code format
check: fix
    @just --fmt --check --unstable
    @mint run swiftformat --lint .
    @mint run swiftlint lint --strict 2>&1 | tail -5

# ==============================================================================
# CLEANUP
# ==============================================================================

# Clean build artifacts, caches, and generated files
clean:
    @rm -rf {{ PROJECT_FILE }}
    @rm -rf fastlane/build
    @rm -rf fastlane/logs
    @rm -rf fastlane/report.xml
    @rm -rf .build
    @rm -rf Packages/.build
    @rm -rf {{ SWIFTPM_ROOT }}

# ==============================================================================
# Testing
# ==============================================================================
# Usage: just pkg-test [filter] [ci] [extra_args]
# filter: Optional regex to filter tests (e.g., "GameFeatureCoreTests")
# ci: Optional CI mode flag ("true" limits workers to 1)

# extra_args: Additional arguments passed to swift test (e.g. "--skip-build")
pkg-test filter="" ci="false" *extra_args:
    #!/usr/bin/env bash
    set -e
    mkdir -p {{ SWIFTPM_DEP_CACHE }}
    mkdir -p {{ SWIFTPM_ARTIFACT_ROOT }}
    echo "🧪 Testing Packages..."

    ARGS_ARRAY=()
    for arg in {{ extra_args }}; do
        ARGS_ARRAY+=("$arg")
    done

    if [ -n "{{ filter }}" ];
    then
        ARGS_ARRAY+=(--filter "{{ filter }}")
        echo "📋 Filtering tests with: {{ filter }}"
    else
        echo "📋 Running all tests"
    fi

    if [ "{{ ci }}" = "true" ];
    then
        echo "🔧 CI Mode: Running with 1 worker to save resources..."
        ARGS_ARRAY+=(--parallel --num-workers 1)
    else
        echo "🚀 Local Mode: Running in parallel..."
        WORKERS=$(sysctl -n hw.ncpu)
        ARGS_ARRAY+=(--parallel --num-workers "$WORKERS")
    fi

    echo "Running: swift test ${ARGS_ARRAY[@]}"
    swift test --package-path Packages \
               --cache-path "{{ SWIFTPM_DEP_CACHE }}" \
               --scratch-path "{{ SWIFTPM_ARTIFACT_ROOT }}/Packages" \
               "${ARGS_ARRAY[@]}"
    echo "✅ Tests complete."

# Run all tests (package + Xcode)
test:
    @just gen
    @just pkg-test
    @just fastlane::test-all

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
