import ComposableArchitecture
import Foundation

/// A feature that manages pure gameplay logic.
///
/// The game is considered "playing" from initialization. It tracks score,
/// time elapsed, and notifies the parent when the game ends (win or loss)
/// via delegate actions.
@Reducer
public struct GameFeature: Sendable {
  public init() {}

  // MARK: - Dependencies

  @Dependency(\.continuousClock) var clock

  // MARK: - State

  @ObservableState
  public struct State: Equatable, Sendable {
    /// The rules for this game.
    public var rule: GameRule

    /// The current score.
    public var score: Int

    /// The time elapsed in seconds since the game started.
    public var timeElapsed: TimeInterval

    /// The result of the game, set when the game ends.
    public var result: GameResult?

    /// Whether the game is still in progress (no result yet).
    public var isPlaying: Bool { self.result == nil }

    public init(
      rule: GameRule = .defaultRule,
      score: Int = 0,
      timeElapsed: TimeInterval = 0,
      result: GameResult? = nil
    ) {
      self.rule = rule
      self.score = score
      self.timeElapsed = timeElapsed
      self.result = result
    }
  }

  // MARK: - Actions

  public enum Action: Equatable, Sendable {
    /// Start the game timer.
    case task

    /// Timer tick event (fires every second).
    case timerTick

    /// Score was incremented by a certain amount.
    case scoreIncremented(amount: Int)

    /// Player died (game over).
    case playerDied

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

  // MARK: - Reducer

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .task:
          return .run { send in
            for await _ in self.clock.timer(interval: .seconds(1)) {
              await send(.timerTick)
            }
          }

        case .timerTick:
          guard state.isPlaying else { return .none }
          state.timeElapsed += 1
          return self.checkRule(state: &state)

        case let .scoreIncremented(amount):
          guard state.isPlaying else { return .none }
          state.score += amount
          return self.checkRule(state: &state)

        case .playerDied:
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

  // MARK: - Private Helpers

  /// Checks the game status based on current rule and state.
  /// Returns an effect if the game should end, otherwise returns .none.
  private func checkRule(state: inout State) -> Effect<Action> {
    // 1. Check win condition first (to avoid race conditions with time limit)
    switch state.rule.winCondition {
      case let .scoreTarget(target):
        if state.score >= target {
          state.result = .won
          return .send(.delegate(.gameEnded(.won)))
        }

      case let .survival(duration):
        if state.timeElapsed >= duration {
          state.result = .won
          return .send(.delegate(.gameEnded(.won)))
        }

      case .none:
        // No win condition, only loss conditions apply
        break
    }

    // 2. Check time limit (common for all modes)
    if let limit = state.rule.timeLimit, state.timeElapsed >= limit {
      state.result = .lost
      return .send(.delegate(.gameEnded(.lost)))
    }

    return .none
  }
}
