import ComposableArchitecture
import Dependencies
import Foundation

/// A feature that manages a simple counter with increment and decrement actions.
@Reducer
public struct CounterFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public var count: Int

    public init(count: Int = 0) {
      self.count = count
    }
  }

  public enum Action: Equatable {
    case incrementButtonTapped
    case decrementButtonTapped
    case resetButtonTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .incrementButtonTapped:
          state.count += 1
          return .none

        case .decrementButtonTapped:
          state.count -= 1
          return .none

        case .resetButtonTapped:
          state.count = 0
          return .none
      }
    }
  }
}
