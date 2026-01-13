#if canImport(UIKit)
  import ComposableArchitecture
  import SwiftUI
  import TitleFeatureCore

  /// Simple title splash sequence that funnels the player toward the home menu.
  public struct TitleView: View {
    @Bindable var store: StoreOf<TitleFeature>

    public init(store: StoreOf<TitleFeature>) {
      self.store = store
    }

    public var body: some View {
      ZStack {
        Color.black
          .ignoresSafeArea()

        VStack(spacing: 40) {
          Text("SPACE BATTLE")
            .font(.system(size: 48, weight: .bold, design: .default))
            .foregroundStyle(.white)

          Text("Tap to Start")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.yellow)
            .opacity(self.store.pulseOpacity)
            .animation(
              .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
              value: self.store.pulseOpacity
            )
        }
        .padding(.horizontal, 24)
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
      TitleView(
        store: Store(initialState: TitleFeature.State()) {
          TitleFeature()
        }
      )
    }
  #endif
#endif
