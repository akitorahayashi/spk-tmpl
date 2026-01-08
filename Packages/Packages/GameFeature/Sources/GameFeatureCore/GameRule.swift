import Foundation

/// Defines the rules for a game, including win conditions and constraints.
public struct GameRule: Equatable, Sendable {
  /// A default rule, useful for previews and tests.
  public static let defaultRule = GameRule(winCondition: .scoreTarget(10))

  /// The win condition for this game.
  public var winCondition: WinCondition

  /// The time limit in seconds. If exceeded, the game is lost. Nil means no time limit.
  public var timeLimit: TimeInterval?

  public init(winCondition: WinCondition, timeLimit: TimeInterval? = nil) {
    self.winCondition = winCondition
    self.timeLimit = timeLimit
  }
}

/// Defines the win condition for a game.
public enum WinCondition: Equatable, Sendable {
  /// Reach a target score to win (puzzle, action games, etc.).
  case scoreTarget(Int)

  /// Survive for a specified duration to win (survival games).
  case survival(duration: TimeInterval)

  /// No win condition (endless run games, only game over is tracked).
  case none
}
