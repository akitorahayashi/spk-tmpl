import Foundation

/// The current phase of the application's game lifecycle.
public enum AppPhase: Equatable, Sendable {
  /// The home screen is displayed, waiting for user to start.
  case home

  /// The game is actively being played.
  case playing

  /// The game has ended with a result.
  case ended(GameResult)
}
