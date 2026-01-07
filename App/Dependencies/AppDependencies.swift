import AppFeatureDomain
import ComposableArchitecture
import Foundation

/// DI container that manages all app dependencies for TCA stores.
struct AppDependencies: Sendable {
  /// Creates dependencies for the production environment.
  static func live() -> AppDependencies {
    AppDependencies()
  }

  /// Configures the TCA store with production dependencies.
  func configure(_: inout DependencyValues) {
    // Add production dependency overrides here
    // Example: dependencies.apiClient = .live
  }
}

#if DEBUG
  extension AppDependencies {
    /// Creates mock dependencies for testing and previews.
    static func mock() -> AppDependencies {
      AppDependencies()
    }

    /// Configures the TCA store with mock dependencies.
    func configureMock(_: inout DependencyValues) {
      // Add mock dependency overrides here
      // Example: dependencies.apiClient = .mock
    }
  }
#endif
