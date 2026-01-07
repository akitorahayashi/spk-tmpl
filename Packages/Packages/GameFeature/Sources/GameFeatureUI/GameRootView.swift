#if canImport(UIKit)
  import ComposableArchitecture
  import GameFeatureDomain
  import SwiftUI

  /// The root view that switches between game phases based on store state.
  ///
  /// This view acts as the phase-driven router, displaying:
  /// - HomeView when in .home phase
  /// - GameContainerView when in .playing phase
  /// - EndedView when in .ended phase
  public struct GameRootView: View {
    @Bindable var store: StoreOf<GameFeature>

    public init(store: StoreOf<GameFeature>) {
      self.store = store
    }

    public var body: some View {
      Group {
        switch self.store.phase {
          case .home:
            HomeView(onStart: {
              self.store.send(.startGame)
            })

          case .playing:
            GameContainerView(
              onPlayerKilledEnemy: {
                self.store.send(.playerKilledEnemy)
              },
              onPlayerWasHit: {
                self.store.send(.playerWasHit)
              }
            )

          case let .ended(result):
            EndedView(result: result, onReturn: {
              self.store.send(.returnToHome)
            })
        }
      }
    }
  }

  #if DEBUG
    #Preview("Home") {
      GameRootView(
        store: Store(initialState: GameFeature.State(phase: .home)) {
          GameFeature()
        }
      )
    }

    #Preview("Playing") {
      GameRootView(
        store: Store(initialState: GameFeature.State(phase: .playing)) {
          GameFeature()
        }
      )
    }

    #Preview("Won") {
      GameRootView(
        store: Store(initialState: GameFeature.State(phase: .ended(.won))) {
          GameFeature()
        }
      )
    }
  #endif
#endif
