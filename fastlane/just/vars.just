# ==============================================================================
# Shared Variables
# ==============================================================================
# This file contains variables shared across all just modules
# Project specific paths

APP_NAME := "TemplateApp"
TEST_DERIVED_DATA_PATH := "fastlane/build/test-results/DerivedData"
DEBUG_APP_PATH := TEST_DERIVED_DATA_PATH + "/Debug/Build/Products/Debug-iphonesimulator/" + APP_NAME + ".app"
RELEASE_APP_PATH := TEST_DERIVED_DATA_PATH + "/Release/Build/Products/Release-iphonesimulator/" + APP_NAME + ".app"
APP_BUNDLE_ID := "com.akitorahayashi.TemplateApp"

# Environment variables

DEV_SIMULATOR_UDID := env("DEV_SIMULATOR_UDID", "")
TEST_SIMULATOR_UDID := env("TEST_SIMULATOR_UDID", "")
