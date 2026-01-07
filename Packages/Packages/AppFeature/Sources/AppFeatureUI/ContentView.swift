#if canImport(UIKit)
  import AppFeatureDomain
  import ComposableArchitecture
  import GameFeatureUI
  import SwiftUI

  /// The root view of the application, hosting the game feature.
  public struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
      self.store = store
    }

    public var body: some View {
      GameRootView(store: self.store.scope(state: \.game, action: \.game))
        .task {
          self.store.send(.onAppear)
        }
    }
  }

  #if DEBUG
    #Preview {
      ContentView(
        store: Store(initialState: AppFeature.State()) {
          AppFeature()
        }
      )
    }
  #endif
#endif
