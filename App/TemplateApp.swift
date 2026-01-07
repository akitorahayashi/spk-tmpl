import AppFeatureCore
import AppFeatureUI
import ComposableArchitecture
import SwiftUI

@main
struct TemplateApp: App {
  private let store: StoreOf<AppFeature>

  init() {
    self.store = Self.makeStore(dependencies: AppDependencies.live())
  }

  /// Initializer for tests and previews to inject dependencies.
  init(dependencies: AppDependencies) {
    self.store = Self.makeStore(dependencies: dependencies)
  }

  var body: some Scene {
    WindowGroup {
      ContentView(store: self.store)
    }
  }
}

private extension TemplateApp {
  static func makeStore(dependencies: AppDependencies) -> StoreOf<AppFeature> {
    Store(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      dependencies.configure(&$0)
    }
  }
}
