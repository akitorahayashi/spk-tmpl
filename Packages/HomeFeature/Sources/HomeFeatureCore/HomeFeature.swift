import ComposableArchitecture
import Foundation

/// A feature that manages the home screen with title display and game start trigger.
///
/// The home screen displays the game title and waits for user input to start the game.
/// It delegates the actual navigation to its parent (AppFeature) via delegate actions.
@Reducer
public struct HomeFeature: Sendable {
  public init() {}

  @ObservableState
  public struct State: Equatable, Sendable {
    /// Controls the pulsing animation opacity for the "Tap to Start" text.
    public var pulseOpacity: Double

    public init(pulseOpacity: Double = 1.0) {
      self.pulseOpacity = pulseOpacity
    }
  }

  public enum Action: Equatable, Sendable {
    /// View appeared, start animations.
    case onAppear

    /// User tapped to start the game.
    case startTapped

    /// Delegate actions to communicate with parent.
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      /// Request parent to start the game.
      case startGame
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .onAppear:
          state.pulseOpacity = 0.3
          return .none

        case .startTapped:
          return .send(.delegate(.startGame))

        case .delegate:
          return .none
      }
    }
  }
}
