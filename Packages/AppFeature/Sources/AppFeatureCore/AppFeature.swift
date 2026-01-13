import ComposableArchitecture
import Dependencies
import Foundation
import GameFeatureCore
import HomeFeatureCore
import TitleFeatureCore

/// The root feature that provides routing between Home and Game screens.
///
/// This feature acts as the routing hub, managing state-driven navigation
/// between the home screen and gameplay using an enum-based state.
@Reducer
public struct AppFeature: Sendable {
  public init() {}

  @ObservableState
  public enum State: Equatable, Sendable {
    /// The title splash is displayed.
    case title(TitleFeature.State)

    /// The home screen is displayed.
    case home(HomeFeature.State)

    /// The game is being played.
    case game(GameFeature.State)

    public init() {
      self = .title(TitleFeature.State())
    }
  }

  public enum Action: Equatable, Sendable {
    case title(TitleFeature.Action)
    case home(HomeFeature.Action)
    case game(GameFeature.Action)
    case onAppear
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .title(.delegate(.startGame)):
          state = .home(HomeFeature.State())
          return .none

        case .title:
          return .none

        case .home(.delegate(.startGame)):
          // Inject the game rule for the level.
          // Template users can customize this to create different game modes.
          state = .game(GameFeature.State(rule: .defaultRule))
          return .none

        case .home:
          return .none

        case .game(.delegate(.returnToHome)):
          state = .home(HomeFeature.State())
          return .none

        case .game(.delegate(.gameEnded)):
          // Game ended, but we stay on game screen to show EndedView
          // The user will tap to continue and trigger returnToHome
          return .none

        case .game:
          return .none

        case .onAppear:
          return .none
      }
    }
    .ifCaseLet(\.title, action: \.title) {
      TitleFeature()
    }
    .ifCaseLet(\.home, action: \.home) {
      HomeFeature()
    }
    .ifCaseLet(\.game, action: \.game) {
      GameFeature()
    }
  }
}
