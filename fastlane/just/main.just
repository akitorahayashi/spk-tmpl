# ==============================================================================
# Fastlane Module Entry Point
# ==============================================================================

# --- MODULE VARIABLES ---
# These variables are encapsulated within the fastlane module

# Project specific paths (originally from root justfile)
TEST_DERIVED_DATA_PATH := "fastlane/build/test-results/DerivedData"
DEBUG_APP_PATH := TEST_DERIVED_DATA_PATH + "/Debug/Build/Products/Debug-iphonesimulator/TemplateApp.app"
RELEASE_APP_PATH := TEST_DERIVED_DATA_PATH + "/Release/Build/Products/Release-iphonesimulator/TemplateApp.app"
APP_BUNDLE_ID := "com.akitorahayashi.TemplateApp"

# Environment variables
DEV_SIMULATOR_UDID := env("DEV_SIMULATOR_UDID", "")
TEST_SIMULATOR_UDID := env("TEST_SIMULATOR_UDID", "")

# ==============================================================================
# Imports
# ==============================================================================
import 'module.just'
import 'build.just'
import 'test.just'
import 'sign.just'
