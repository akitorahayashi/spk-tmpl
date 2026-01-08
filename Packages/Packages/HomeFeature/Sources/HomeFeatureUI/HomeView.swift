#if canImport(UIKit)
  import ComposableArchitecture
  import HomeFeatureCore
  import SwiftUI

  /// The home screen view displaying the game title and start prompt.
  public struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
      self.store = store
    }

    public var body: some View {
      ZStack {
        Color.black
          .ignoresSafeArea()

        VStack(spacing: 40) {
          Text("SHOT GAME")
            .font(.system(size: 48, weight: .bold, design: .default))
            .foregroundColor(.white)

          Text("Tap to Start")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.yellow)
            .opacity(self.store.pulseOpacity)
            .animation(
              .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
              value: self.store.pulseOpacity
            )
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
        self.store.send(.startTapped)
      }
      .onAppear {
        self.store.send(.onAppear)
      }
    }
  }

  #if DEBUG
    #Preview {
      HomeView(
        store: Store(initialState: HomeFeature.State()) {
          HomeFeature()
        }
      )
    }
  #endif
#endif
