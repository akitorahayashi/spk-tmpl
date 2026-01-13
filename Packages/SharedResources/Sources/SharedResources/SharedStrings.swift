import Foundation

/// Public wrapper for internal LocalizedStringResource symbols.
/// Manually defined because the plugin symbols are not visible externally or to this file.
public extension LocalizedStringResource {
  private static var sharedBundle: LocalizedStringResource.BundleDescription {
    .atURL(Bundle.module.bundleURL)
  }

  // Example:
  // static var shared_ok: LocalizedStringResource {
  //   LocalizedStringResource("ok", defaultValue: "OK", table: "Shared", bundle: sharedBundle)
  // }
}
