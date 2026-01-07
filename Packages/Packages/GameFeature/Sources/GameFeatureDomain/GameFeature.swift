import ComposableArchitecture
import Dependencies
import Foundation

/// A feature that manages the game lifecycle with phase-based state transitions.
///
/// The game follows a simple state machine:
/// - `home`: Title screen waiting for user input
/// - `playing`: Active gameplay with kill tracking
/// - `ended`: Game over screen showing result
@Reducer
public struct GameFeature: Sendable {
  public init() {}

  /// The number of enemy kills required to win the game.
  public static let killsToWin = 10

  @ObservableState
  public struct State: Equatable, Sendable {
    /// The current phase of the game lifecycle.
    public var phase: AppPhase

    /// The number of enemies killed in the current game session.
    public var killCount: Int

    public init(
      phase: AppPhase = .home,
      killCount: Int = 0
    ) {
      self.phase = phase
      self.killCount = killCount
    }
  }

  public enum Action: Equatable, Sendable {
    /// User tapped to start a new game from the home screen.
    case startGame

    /// Player's bullet hit an enemy.
    case playerKilledEnemy

    /// Enemy bullet hit the player.
    case playerWasHit

    /// User tapped to return to home from the ended screen.
    case returnToHome
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .startGame:
          guard state.phase == .home else { return .none }
          state.phase = .playing
          state.killCount = 0
          return .none

        case .playerKilledEnemy:
          guard state.phase == .playing else { return .none }
          state.killCount += 1
          if state.killCount >= Self.killsToWin {
            state.phase = .ended(.won)
          }
          return .none

        case .playerWasHit:
          guard state.phase == .playing else { return .none }
          state.phase = .ended(.lost)
          return .none

        case .returnToHome:
          guard case .ended = state.phase else { return .none }
          state.phase = .home
          state.killCount = 0
          return .none
      }
    }
  }
}
