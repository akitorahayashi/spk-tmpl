# fastlane/lanes/build.rb
# Build-related lanes and helpers

# === Build Lanes ===
desc "Build unsigned debug archive"
lane :build_debug do |options|
  options ||= {}
  build_app_with_config(
    configuration: CONFIGURATIONS[:debug],
    xcargs: options[:xcargs]
  )
end

desc "Build unsigned release archive"
lane :build_release do |options|
  options ||= {}
  build_app_with_config(
    configuration: CONFIGURATIONS[:release],
    xcargs: options[:xcargs]
  )
end

# === Private Build Helpers ===

def config_paths(configuration)
  case configuration
  when CONFIGURATIONS[:release]
    {
      archive_path: RELEASE_ARCHIVE_PATH,
      derived_data_path: RELEASE_BUILD_DERIVED_DATA_PATH,
    }
  when CONFIGURATIONS[:debug]
    {
      archive_path: DEBUG_ARCHIVE_PATH,
      derived_data_path: DEBUG_BUILD_DERIVED_DATA_PATH,
    }
  else
    UI.user_error!(
      "Unknown configuration: #{configuration}. Must be one of #{CONFIGURATIONS.values.join(', ')}"
    )
  end
end

private_lane :build_app_with_config do |options|
  configuration = options[:configuration]
  paths = config_paths(configuration)

  FileUtils.mkdir_p(File.dirname(paths[:archive_path]))
  FileUtils.mkdir_p(paths[:derived_data_path])
  FileUtils.mkdir_p(BUILD_LOGS_PATH)

  passed_xcargs = options[:xcargs].to_s.strip
  passed_xcargs += " -skipMacroValidation" if ENV["CI"]

  build_app(
    project: PROJECT_PATH,
    scheme: SCHEMES[:app],
    configuration: configuration,
    clean: !ENV["CI"],
    skip_codesigning: true,
    skip_package_ipa: true,
    derived_data_path: paths[:derived_data_path],
    archive_path: paths[:archive_path],
    export_team_id: ENV["TEAM_ID"],
    buildlog_path: BUILD_LOGS_PATH,
    suppress_xcode_output: true,
    xcargs: passed_xcargs,
  )
end
