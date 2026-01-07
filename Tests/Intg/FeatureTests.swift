import AppFeatureDomain
import ComposableArchitecture
import CounterFeatureDomain
import XCTest

@testable import TemplateApp

@MainActor
final class FeatureTests: XCTestCase {
  func testAppFeatureCounterIncrement() async {
    // Goal: Verify that the app feature correctly composes the counter feature.
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.counter(.incrementButtonTapped)) {
      $0.counter.count = 1
    }
  }

  func testAppFeatureCounterDecrement() async {
    let store = TestStore(initialState: AppFeature.State(counter: CounterFeature.State(count: 10))) {
      AppFeature()
    }

    await store.send(.counter(.decrementButtonTapped)) {
      $0.counter.count = 9
    }
  }

  func testAppFeatureCounterReset() async {
    let store = TestStore(initialState: AppFeature.State(counter: CounterFeature.State(count: 42))) {
      AppFeature()
    }

    await store.send(.counter(.resetButtonTapped)) {
      $0.counter.count = 0
    }
  }

  func testAppDependenciesConfiguration() async {
    // Goal: Verify that dependencies can be configured on the store.
    let dependencies = AppDependencies.live()
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      dependencies.configure(&$0)
    }

    await store.send(.onAppear)
  }
}
