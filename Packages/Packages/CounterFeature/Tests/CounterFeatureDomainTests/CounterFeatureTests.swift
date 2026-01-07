import ComposableArchitecture
import XCTest

@testable import CounterFeatureDomain

@MainActor
final class CounterFeatureTests: XCTestCase {
  func testIncrement() async {
    let store = TestStore(initialState: CounterFeature.State()) {
      CounterFeature()
    }

    await store.send(.incrementButtonTapped) {
      $0.count = 1
    }
    await store.send(.incrementButtonTapped) {
      $0.count = 2
    }
  }

  func testDecrement() async {
    let store = TestStore(initialState: CounterFeature.State(count: 5)) {
      CounterFeature()
    }

    await store.send(.decrementButtonTapped) {
      $0.count = 4
    }
    await store.send(.decrementButtonTapped) {
      $0.count = 3
    }
  }

  func testReset() async {
    let store = TestStore(initialState: CounterFeature.State(count: 42)) {
      CounterFeature()
    }

    await store.send(.resetButtonTapped) {
      $0.count = 0
    }
  }

  func testIncrementFromNegative() async {
    let store = TestStore(initialState: CounterFeature.State(count: -3)) {
      CounterFeature()
    }

    await store.send(.incrementButtonTapped) {
      $0.count = -2
    }
  }

  func testDecrementToNegative() async {
    let store = TestStore(initialState: CounterFeature.State(count: 0)) {
      CounterFeature()
    }

    await store.send(.decrementButtonTapped) {
      $0.count = -1
    }
  }
}
