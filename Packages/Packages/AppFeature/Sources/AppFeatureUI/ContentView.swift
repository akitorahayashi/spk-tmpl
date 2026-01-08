#if canImport(UIKit)
  import AppFeatureCore
  import ComposableArchitecture
  import GameFeatureCore
  import GameFeatureUI
  import HomeFeatureCore
  import HomeFeatureUI
  import SwiftUI

  /// The root view of the application, hosting the app feature with routing.
  public struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
      self.store = store
    }

    public var body: some View {
      SwitchStore(self.store) { state in
        switch state {
          case .home:
            CaseLet(\AppFeature.State.home, action: AppFeature.Action.home) { homeStore in
              HomeView(store: homeStore)
            }
          case .game:
            CaseLet(\AppFeature.State.game, action: AppFeature.Action.game) { gameStore in
              GameRootView(store: gameStore)
            }
        }
      }
      .task {
        self.store.send(.onAppear)
      }
    }
  }

  /// A view that switches between gameplay and ended screens based on game state.
  struct GameRootView: View {
    @Bindable var store: StoreOf<GameFeature>

    var body: some View {
      if self.store.isPlaying {
        GameContainerView(store: self.store)
      } else {
        EndedView(store: self.store)
      }
    }
  }

  #if DEBUG
    #Preview("Home") {
      ContentView(
        store: Store(initialState: AppFeature.State.home(HomeFeature.State())) {
          AppFeature()
        }
      )
    }

    #Preview("Playing") {
      ContentView(
        store: Store(initialState: AppFeature.State.game(GameFeature.State())) {
          AppFeature()
        }
      )
    }

    #Preview("Ended") {
      ContentView(
        store: Store(initialState: AppFeature.State.game(GameFeature.State(result: .won))) {
          AppFeature()
        }
      )
    }
  #endif
#endif
