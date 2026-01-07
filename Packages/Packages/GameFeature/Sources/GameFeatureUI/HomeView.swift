import SwiftUI

/// The home screen view displaying the game title and start prompt.
public struct HomeView: View {
  @State private var pulseOpacity: Double = 1.0

  let onStart: () -> Void

  public init(onStart: @escaping () -> Void) {
    self.onStart = onStart
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
          .opacity(self.pulseOpacity)
          .animation(
            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
            value: self.pulseOpacity
          )
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      self.onStart()
    }
    .onAppear {
      self.pulseOpacity = 0.3
    }
  }
}

#if DEBUG
  #Preview {
    HomeView(onStart: {})
  }
#endif
