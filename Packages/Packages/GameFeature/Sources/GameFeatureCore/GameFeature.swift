import ComposableArchitecture
import Foundation

/// A feature that manages pure gameplay logic.
///
/// The game is considered "playing" from initialization. It tracks kills
/// and notifies the parent when the game ends (win or loss) via delegate actions.
@Reducer
public struct GameFeature: Sendable {
  public init() {}

  /// The number of enemy kills required to win the game.
  public static let killsToWin = 10

  @ObservableState
  public struct State: Equatable, Sendable {
    /// The number of enemies killed in the current game session.
    public var killCount: Int

    /// The result of the game, set when the game ends.
    public var result: GameResult?

    /// Whether the game is still in progress (no result yet).
    public var isPlaying: Bool { self.result == nil }

    public init(killCount: Int = 0, result: GameResult? = nil) {
      self.killCount = killCount
      self.result = result
    }
  }

  public enum Action: Equatable, Sendable {
    /// Player's bullet hit an enemy.
    case playerKilledEnemy

    /// Enemy bullet hit the player.
    case playerWasHit

    /// User tapped to continue from the ended screen.
    case continueTapped

    /// Delegate actions to communicate with parent.
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      /// Notify parent that the game has ended with a result.
      case gameEnded(GameResult)

      /// Request parent to return to home.
      case returnToHome
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .playerKilledEnemy:
          guard state.isPlaying else { return .none }
          state.killCount += 1
          if state.killCount >= Self.killsToWin {
            state.result = .won
            return .send(.delegate(.gameEnded(.won)))
          }
          return .none

        case .playerWasHit:
          guard state.isPlaying else { return .none }
          state.result = .lost
          return .send(.delegate(.gameEnded(.lost)))

        case .continueTapped:
          guard state.result != nil else { return .none }
          return .send(.delegate(.returnToHome))

        case .delegate:
          return .none
      }
    }
  }
}
