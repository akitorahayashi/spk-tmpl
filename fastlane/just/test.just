# ==============================================================================
# Testing (Fastlane)
# ==============================================================================

# Run all tests (unit, integration, UI)
[no-cd]
test-all:
    @just fastlane::build-test
    @just fastlane::unit-test-without-building
    @just fastlane::intg-test-without-building
    @just fastlane::ui-test-without-building

# Run unit tests
[no-cd]
unit-test:
    @just fastlane::_run_fastlane "unit_test"

# Run unit tests without building
[no-cd]
unit-test-without-building:
    @just fastlane::_run_fastlane "unit_test_without_building"

# Run integration tests
[no-cd]
intg-test:
    @just fastlane::_run_fastlane "intg_test"

# Run integration tests without building
[no-cd]
intg-test-without-building:
    @just fastlane::_run_fastlane "intg_test_without_building"

# Run UI tests
[no-cd]
ui-test:
    @just fastlane::_run_fastlane "ui_test"

# Run UI tests without building
[no-cd]
ui-test-without-building:
    @just fastlane::_run_fastlane "ui_test_without_building"
