# fastlane/lanes/sign.rb
# Signing-related lanes

# === Signing Lanes ===
desc "Sign debug archive for development"
lane :sign_debug_development do
  sign_archive(
    archive_path: DEBUG_ARCHIVE_PATH,
    export_method: EXPORT_METHODS[:development],
    configuration: CONFIGURATIONS[:debug]
  )
end

desc "Sign release archive with specified export method (development, app_store, ad_hoc, enterprise)"
lane :sign_release do |options|
  options ||= {}
  sign_archive(
    archive_path: RELEASE_ARCHIVE_PATH,
    export_method: options[:export_method],
    configuration: CONFIGURATIONS[:release]
  )
end

# === Private Signing Helpers ===

private_lane :sign_archive do |options|
  export_base = case options[:configuration]
                when CONFIGURATIONS[:release] then RELEASE_BUILD_DIR
                when CONFIGURATIONS[:debug] then DEBUG_BUILD_DIR
                else
                  UI.user_error!("Unknown configuration: #{options[:configuration]}")
                end

  build_app(
    project: PROJECT_PATH,
    scheme: SCHEMES[:app],
    archive_path: options[:archive_path],
    export_method: options[:export_method],
    skip_build_archive: true,
    output_directory: File.join(export_base, options[:export_method].to_s),
    export_team_id: ENV["TEAM_ID"]
  )
end
