import ComposableArchitecture
import Foundation

/// A feature that manages the title screen ramp-in before gameplay.
///
/// The title view simply pulses a "tap to start" prompt and delegates up to the
/// parent so routing can continue to the home screen.
@Reducer
public struct TitleFeature: Sendable {
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
    case onAppear
    case startTapped
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
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
