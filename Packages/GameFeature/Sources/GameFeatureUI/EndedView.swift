#if canImport(UIKit)
  import ComposableArchitecture
  import GameFeatureCore
  import SharedResources
  import SwiftUI

  /// The ended screen view displaying the game result and return prompt.
  public struct EndedView: View {
    let store: StoreOf<GameFeature>

    public init(store: StoreOf<GameFeature>) {
      self.store = store
    }

    public var body: some View {
      ZStack {
        Color.black
          .ignoresSafeArea()

        VStack(spacing: 40) {
          Text(
            self.store.result == .won
              ? String(localized: .victoryTitle, bundle: .module)
              : String(localized: .gameOverTitle, bundle: .module)
          )
          .font(.system(size: 48, weight: .bold, design: .default))
          .foregroundColor(self.store.result == .won ? .green : .red)

          Text(String(localized: .tapToContinue, bundle: SharedResources.bundle))
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
        self.store.send(.continueTapped)
      }
    }
  }

  #if DEBUG
    #Preview("Won") {
      EndedView(
        store: Store(initialState: GameFeature.State(result: .won)) {
          GameFeature()
        }
      )
    }

    #Preview("Lost") {
      EndedView(
        store: Store(initialState: GameFeature.State(result: .lost)) {
          GameFeature()
        }
      )
    }
  #endif
#endif
