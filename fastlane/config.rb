# fastlane/config.rb
# Fastlane configuration values

# === App Constants ===
APP_NAME = "TemplateApp"

# === Project Structure ===
# This file is at <project>/fastlane/config.rb
FASTLANE_DIR = __dir__
PROJECT_ROOT = File.expand_path('..', FASTLANE_DIR)
PROJECT_PATH = File.join(PROJECT_ROOT, "#{APP_NAME}.xcodeproj")

# === Scheme Constants ===
SCHEMES = {
  app: "TemplateApp",
  ui_test: "TemplateAppUITests",
  intg_test: "TemplateAppIntgTests"
}.freeze

# === Configurations ===
CONFIGURATIONS = {
  debug: "Debug",
  release: "Release",
}.freeze

# === Output Directories ===
# All build outputs are organized under fastlane/build/
BUILD_ROOT = File.join(FASTLANE_DIR, "build")
LOGS_ROOT = File.join(FASTLANE_DIR, "logs")

# Test outputs
TEST_RESULTS_DIR = File.join(BUILD_ROOT, "test-results")
TEST_DERIVED_DATA_PATH = File.join(TEST_RESULTS_DIR, "DerivedData")
UI_TEST_RESULT_PATH = File.join(TEST_RESULTS_DIR, "ui", "TestResults.xcresult")
INTG_TEST_RESULT_PATH = File.join(TEST_RESULTS_DIR, "intg", "TestResults.xcresult")

# Archive outputs
DEBUG_BUILD_DIR = File.join(BUILD_ROOT, "debug")
RELEASE_BUILD_DIR = File.join(BUILD_ROOT, "release")

DEBUG_ARCHIVE_PATH = File.join(DEBUG_BUILD_DIR, "archive", "#{APP_NAME}.xcarchive")
RELEASE_ARCHIVE_PATH = File.join(RELEASE_BUILD_DIR, "archive", "#{APP_NAME}.xcarchive")

DEBUG_BUILD_DERIVED_DATA_PATH = File.join(DEBUG_BUILD_DIR, "archive", "DerivedData")
RELEASE_BUILD_DERIVED_DATA_PATH = File.join(RELEASE_BUILD_DIR, "archive", "DerivedData")

# Logs
TEST_LOGS_PATH = File.join(LOGS_ROOT, "test")
BUILD_LOGS_PATH = File.join(LOGS_ROOT, "build")

# === Export Methods ===
EXPORT_METHODS = {
  app_store: "app-store",
  ad_hoc: "ad-hoc",
  enterprise: "enterprise",
  development: "development"
}.freeze
