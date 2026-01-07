import ComposableArchitecture
import CounterFeatureDomain
import Dependencies
import Foundation

/// The root feature that composes all child features.
@Reducer
public struct AppFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public var counter: CounterFeature.State

    public init(counter: CounterFeature.State = CounterFeature.State()) {
      self.counter = counter
    }
  }

  public enum Action: Equatable {
    case counter(CounterFeature.Action)
    case onAppear
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.counter, action: \.counter) {
      CounterFeature()
    }
    Reduce { _, action in
      switch action {
        case .counter:
          .none

        case .onAppear:
          .none
      }
    }
  }
}
