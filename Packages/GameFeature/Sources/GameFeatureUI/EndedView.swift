#if canImport(UIKit)
  import ComposableArchitecture
  import GameFeatureCore
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
          if self.store.result == .won {
            Text(String(localized: "victoryTitle", bundle: .module))
              .font(.system(size: 48, weight: .bold, design: .default))
              .foregroundColor(.green)
              .accessibilityIdentifier(GameAccessibilityID.victoryTitle)
          } else {
            Text(String(localized: "gameOverTitle", bundle: .module))
              .font(.system(size: 48, weight: .bold, design: .default))
              .foregroundColor(.red)
              .accessibilityIdentifier(GameAccessibilityID.defeatTitle)
          }

          Text(String(localized: "tapToContinue", bundle: .module))
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .accessibilityIdentifier(GameAccessibilityID.tapToContinue)
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
