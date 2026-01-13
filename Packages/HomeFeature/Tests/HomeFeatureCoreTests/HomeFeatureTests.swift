import ComposableArchitecture
import XCTest

@testable import HomeFeatureCore

@MainActor
final class HomeFeatureTests: XCTestCase {
  func testInitialState() {
    let state = HomeFeature.State()
    XCTAssertEqual(state.pulseOpacity, 1.0)
  }

  func testOnAppear() async {
    let store = TestStore(initialState: HomeFeature.State()) {
      HomeFeature()
    }

    await store.send(.onAppear) {
      $0.pulseOpacity = 0.3
    }
  }

  func testStartTapped() async {
    let store = TestStore(initialState: HomeFeature.State()) {
      HomeFeature()
    }

    await store.send(.startTapped)
    await store.receive(.delegate(.startGame))
  }
}
