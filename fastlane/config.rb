
# fastlane/config.rb
# Fastlane configuration values

# === Paths ===
FASTLANE_DIR = File.expand_path(__dir__)
REPO_ROOT = File.expand_path("..", FASTLANE_DIR)

# === Project ===
PROJECT_PATH = File.join(REPO_ROOT, "TemplateApp.xcodeproj")

# === Scheme Constants ===
SCHEMES = {
  app: "TemplateApp",
  unit_test: "TemplateAppTests",
  ui_test: "TemplateAppUITests",
  intg_test: "TemplateAppIntgTests"
}.freeze

# === Test Paths ===
BUILD_PATH = File.join(REPO_ROOT, "fastlane/build")
LOGS_PATH = File.join(REPO_ROOT, "fastlane/logs")
TEST_LOGS_PATH = "#{LOGS_PATH}/test"
BUILD_LOGS_PATH = "#{LOGS_PATH}/build"

TEST_RESULTS_PATH = "#{BUILD_PATH}/test-results"
UNIT_TEST_RESULT_PATH = "#{TEST_RESULTS_PATH}/unit/TestResults.xcresult"
UI_TEST_RESULT_PATH = "#{TEST_RESULTS_PATH}/ui/TestResults.xcresult"
INTG_TEST_RESULT_PATH = "#{TEST_RESULTS_PATH}/intg/TestResults.xcresult"

# === Archive Paths ===
DEBUG_EXPORT_BASE = "#{BUILD_PATH}/debug"
RELEASE_EXPORT_BASE = "#{BUILD_PATH}/release"
DEBUG_ARCHIVE_PATH = "#{DEBUG_EXPORT_BASE}/archive/TemplateApp.xcarchive"
RELEASE_ARCHIVE_PATH = "#{RELEASE_EXPORT_BASE}/archive/TemplateApp.xcarchive"

# === Build DerivedData Paths ===
TEST_DERIVED_DATA_PATH = "#{TEST_RESULTS_PATH}/DerivedData"
DEBUG_BUILD_DERIVED_DATA_PATH = "#{DEBUG_EXPORT_BASE}/archive/DerivedData"
RELEASE_BUILD_DERIVED_DATA_PATH = "#{RELEASE_EXPORT_BASE}/archive/DerivedData"

# === Configurations ===
CONFIGURATIONS = {
  debug: "Debug",
  release: "Release",
}.freeze

# === Export Methods ===
EXPORT_METHODS = {
  app_store: "app-store",
  ad_hoc: "ad-hoc",
  enterprise: "enterprise",
  development: "development"
}.freeze
