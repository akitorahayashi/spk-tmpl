import Foundation

/// Provides access to the SharedResources bundle for cross-module localization.
public enum SharedResources {
  /// The bundle containing SharedResources localized strings and assets.
  public static let bundle: Bundle = .module
}
