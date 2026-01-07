import ComposableArchitecture
import Dependencies
import Foundation
import GameFeatureDomain

/// The root feature that composes the game feature.
@Reducer
public struct AppFeature: Sendable {
  public init() {}

  @ObservableState
  public struct State: Equatable, Sendable {
    public var game: GameFeature.State

    public init(game: GameFeature.State = GameFeature.State()) {
      self.game = game
    }
  }

  public enum Action: Equatable, Sendable {
    case game(GameFeature.Action)
    case onAppear
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.game, action: \.game) {
      GameFeature()
    }
    Reduce { _, action in
      switch action {
        case .game:
          .none

        case .onAppear:
          .none
      }
    }
  }
}
