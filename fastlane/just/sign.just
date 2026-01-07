# ==============================================================================
# Signing (Fastlane)
# ==============================================================================

# Sign debug archive for development
[no-cd]
sign-debug-development:
    @bundle exec fastlane sign_debug_development

# Sign release archive for development
[no-cd]
sign-release-development:
    @bundle exec fastlane sign_release export_method:development

# Sign release archive for App Store
[no-cd]
sign-release-app-store:
    @bundle exec fastlane sign_release export_method:app_store

# Sign release archive for Ad Hoc
[no-cd]
sign-release-ad-hoc:
    @bundle exec fastlane sign_release export_method:ad_hoc

# Sign release archive for Enterprise
[no-cd]
sign-release-enterprise:
    @bundle exec fastlane sign_release export_method:enterprise
