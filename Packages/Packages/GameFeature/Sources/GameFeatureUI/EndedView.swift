import GameFeatureDomain
import SwiftUI

/// The ended screen view displaying the game result and return prompt.
public struct EndedView: View {
  let result: GameResult
  let onReturn: () -> Void

  public init(result: GameResult, onReturn: @escaping () -> Void) {
    self.result = result
    self.onReturn = onReturn
  }

  public var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()

      VStack(spacing: 40) {
        Text(self.result == .won ? "YOU WIN!" : "GAME OVER")
          .font(.system(size: 48, weight: .bold, design: .default))
          .foregroundColor(self.result == .won ? .green : .red)

        Text("Tap to Continue")
          .font(.system(size: 24, weight: .bold))
          .foregroundColor(.white)
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      self.onReturn()
    }
  }
}

#if DEBUG
  #Preview("Won") {
    EndedView(result: .won, onReturn: {})
  }

  #Preview("Lost") {
    EndedView(result: .lost, onReturn: {})
  }
#endif
