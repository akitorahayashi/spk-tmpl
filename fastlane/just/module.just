# ==============================================================================
# Fastlane Common Module
# ==============================================================================

# @hidden
# Helper to run fastlane lanes with CI/UDID logic and common arguments
[no-cd]
_run_fastlane lane udid="" xcargs="-skipMacroValidation":
    @set -e; \
    if [ -n "${CI:-}" ]; then \
        echo "Running fastlane {{lane}} (CI Mode) xcargs: {{xcargs}}"; \
        bundle exec fastlane {{lane}} xcargs:"{{xcargs}}"; \
    else \
        TARGET_UDID="{{ if udid != "" { udid } else { env('TEST_SIMULATOR_UDID', '') } }}"; \
        if [ -z "$TARGET_UDID" ]; then \
            echo "❌ UDID is not set. Please set TEST_SIMULATOR_UDID in .env or pass udid argument."; \
            exit 1; \
        fi; \
        echo "Running fastlane {{lane}} with udid:$TARGET_UDID xcargs: {{xcargs}}"; \
        bundle exec fastlane {{lane}} udid:$TARGET_UDID xcargs:"{{xcargs}}"; \
    fi
