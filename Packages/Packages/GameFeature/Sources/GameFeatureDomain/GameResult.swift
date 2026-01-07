import Foundation

/// The outcome of a completed game session.
public enum GameResult: Equatable, Sendable {
  /// The player achieved the win condition (killed enough enemies).
  case won

  /// The player was hit by an enemy bullet.
  case lost
}
